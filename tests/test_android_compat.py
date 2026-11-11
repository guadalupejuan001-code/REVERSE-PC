"""Compatibility inventory tests. APK/ADB fixtures are synthetic, not Wild Rift."""

import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("android_compat", ROOT / "tools/android_compat.py")
compat = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(compat)


def xml_manifest(package="org.reverse.fixture", version=7, split=""):
    split_attr = f' split="{split}"' if split else ""
    return (f'<manifest xmlns:android="{compat.ANDROID}" package="{package}" android:versionCode="{version}"'
            f' android:versionName="fixture"{split_attr}><uses-sdk android:minSdkVersion="29" android:targetSdkVersion="35"/>'
            '<uses-feature android:glEsVersion="0x00030000"/><application android:debuggable="false"/></manifest>').encode()


def binary_manifest(utf8=True):
    # Build independent AXML start-element chunks following ResourceTypes.h.
    strings = [compat.ANDROID, "manifest", "package", "org.reverse.fixture", "versionCode", "versionName", "fixture",
               "uses-sdk", "minSdkVersion", "targetSdkVersion", "uses-feature", "glEsVersion", "application", "debuggable"]
    def index(value):
        return strings.index(value)
    offsets, content = [], b""
    for value in strings:
        offsets.append(len(content))
        if utf8:
            encoded = value.encode()
            content += bytes([len(value), len(encoded)]) + encoded + b"\0"
        else:
            encoded = value.encode("utf-16le")
            content += struct.pack("<H", len(value)) + encoded + b"\0\0"
    content += b"\0" * (-len(content) % 4)
    pool_size = 28 + 4 * len(strings) + len(content)
    pool = struct.pack("<HHIIIIII", 1, 28, pool_size, len(strings), 0, 0x100 if utf8 else 0, 28 + 4 * len(strings), 0)
    pool += struct.pack("<" + "I" * len(offsets), *offsets) + content
    def node(tag, attributes):
        attrs = b""
        for namespace, name, value_type, value in attributes:
            attrs += struct.pack("<IIIHBBI", index(compat.ANDROID) if namespace else 0xffffffff,
                                 index(name), 0xffffffff, 8, 0, value_type, index(value) if value_type == 3 else value)
        extension = struct.pack("<IIHHHHHH", 0xffffffff, index(tag), 20, 20, len(attributes), 0, 0, 0)
        return struct.pack("<HHIII", 0x102, 16, 16 + len(extension) + len(attrs), 1, 0xffffffff) + extension + attrs
    body = pool + node("manifest", [(False, "package", 3, "org.reverse.fixture"), (True, "versionCode", 0x10, 7),
                                    (True, "versionName", 3, "fixture")])
    body += node("uses-sdk", [(True, "minSdkVersion", 0x10, 29), (True, "targetSdkVersion", 0x10, 35)])
    body += node("uses-feature", [(True, "glEsVersion", 0x11, 0x30000)])
    body += node("application", [(True, "debuggable", 0x12, 0)])
    return struct.pack("<HHI", 3, 8, 8 + len(body)) + body


class ManifestTests(unittest.TestCase):
    def test_binary_utf8_and_utf16_match_metadata(self):
        for utf8 in (True, False):
            with self.subTest(utf8=utf8):
                result = compat.manifest_metadata(binary_manifest(utf8))
                self.assertEqual(result["package"], "org.reverse.fixture")
                self.assertEqual(result["version_code"], 7)
                self.assertEqual(result["sdk"]["minSdkVersion"], 29)
                self.assertEqual(result["gles_requirements"][0]["version"], 0x30000)
                self.assertIs(result["debuggable"], False)

    def test_rejects_truncated_chunks_and_invalid_strings(self):
        for data in (binary_manifest()[:-1], b"\x03\0\x08\0\xff\xff\xff\xff", b"not XML"):
            with self.subTest(size=len(data)):
                with self.assertRaises(compat.InspectionError):
                    compat.manifest_metadata(data)
        data = bytearray(binary_manifest())
        struct.pack_into("<I", data, 8 + 28, 0x7fffffff)
        with self.assertRaises(compat.InspectionError):
            compat.manifest_metadata(data)

    def test_rejects_entity_declarations(self):
        with self.assertRaises(compat.InspectionError):
            compat.manifest_metadata(b'<!DOCTYPE manifest [<!ENTITY x "test">]><manifest/>')


@unittest.skipUnless(shutil.which("g++") and shutil.which("readelf"), "requires g++ and GNU readelf")
class InventoryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.build = tempfile.TemporaryDirectory()
        directory = Path(cls.build.name)
        (directory / "graphics.cpp").write_text('extern "C" void glDrawArrays(unsigned int,int,int) {}\n')
        (directory / "client.cpp").write_text('extern "C" void glDrawArrays(unsigned int,int,int);\nextern "C" void draw_fixture(){glDrawArrays(4,0,3);}\n')
        subprocess.run(["g++", "-shared", "-fPIC", str(directory / "graphics.cpp"), "-Wl,-soname,libGLESv2.so",
                        "-o", str(directory / "libGLESv2.so")], check=True, capture_output=True)
        subprocess.run(["g++", "-shared", "-fPIC", str(directory / "client.cpp"), "-L" + str(directory), "-lGLESv2",
                        "-o", str(directory / "libclient.so")], check=True, capture_output=True)
        cls.native = (directory / "libclient.so").read_bytes()
        machine = struct.unpack_from("<H", cls.native, 18)[0]
        cls.abi = {62: "x86_64", 183: "arm64-v8a"}[machine]

    @classmethod
    def tearDownClass(cls):
        cls.build.cleanup()

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.directory = Path(self.temporary.name)
        self.addCleanup(self.temporary.cleanup)

    def make_apk(self, name="base.apk", version=7, split="", native=None, manifest=None):
        path = self.directory / name
        with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as archive:
            archive.writestr("AndroidManifest.xml", manifest or xml_manifest(version=version, split=split))
            if native is not None:
                archive.writestr("lib/" + self.abi + "/libclient.so", native)
        return path

    def run_inventory(self, *paths, options=()):
        output = self.directory / "report.json"
        code = compat.main(["inspect", *map(str, paths), "-o", str(output), *options])
        return code, json.loads(output.read_text())

    def test_real_elf_linkage_without_execution(self):
        apk = self.make_apk(native=self.native, manifest=binary_manifest())
        before = compat.file_hash(apk)
        code, report = self.run_inventory(apk)
        self.assertEqual(code, 0)
        library = report["apks"][0]["native_libraries"][0]
        self.assertIn("libGLESv2.so", library["elf"]["needed"])
        self.assertIn("glDrawArrays", library["elf"]["graphics_imports"])
        self.assertIn("libGLESv2.so", library["embedded_graphics_library_names"])
        self.assertEqual(compat.file_hash(apk), before)
        self.assertEqual(report["runtime_graphics_backend"], "not_observed")
        self.assertEqual(report["wild_rift_execution"], "not_tested")
        self.assertEqual(report["performance"], "not_measured")

    def test_apks_container_preserves_split_identity(self):
        base = self.make_apk()
        split = self.make_apk("arm.apk", split="config.fixture", native=self.native)
        container = self.directory / "fixture.apks"
        with zipfile.ZipFile(container, "w") as archive:
            archive.write(base, "splits/base.apk")
            archive.write(split, "splits/arm.apk")
        code, report = self.run_inventory(container)
        self.assertEqual(code, 0)
        self.assertEqual(len(report["apks"]), 2)
        self.assertEqual(report["apks"][1]["manifest"]["split"], "config.fixture")

    def test_mixed_versions_and_wrong_target_are_incomplete(self):
        first = self.make_apk()
        second = self.make_apk("new.apk", version=8)
        code, report = self.run_inventory(first, second)
        self.assertEqual(code, 2)
        self.assertEqual(report["status"], "incomplete")
        code, report = self.run_inventory(first, options=("--expect-package", "com.riotgames.league.wildrift"))
        self.assertEqual(code, 2)
        self.assertIn("Input package does not match --expect-package", report["errors"])

    def test_invalid_elf_and_decompression_limit_are_reported(self):
        code, report = self.run_inventory(self.make_apk(native=b"not an ELF"))
        self.assertEqual(code, 2)
        self.assertIn("Invalid ELF", report["errors"][0])
        code, report = self.run_inventory(self.make_apk("large.apk", native=b"x" * (2 * compat.MIB)),
                                          options=("--max-native-mib", "1"))
        self.assertEqual(code, 2)
        self.assertIn("size limit", report["errors"][0])

    def test_zip_traversal_and_duplicate_entries_are_rejected(self):
        path = self.directory / "bad.zip"
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr("../outside.apk", b"invalid")
        code, report = self.run_inventory(path)
        self.assertEqual(code, 2)
        self.assertFalse((self.directory.parent / "outside.apk").exists())
        self.assertIn("unsafe member", report["errors"][0])
        with zipfile.ZipFile(path, "w") as archive:
            archive.writestr("AndroidManifest.xml", xml_manifest())
            with self.assertWarns(UserWarning):
                archive.writestr("AndroidManifest.xml", xml_manifest())
        code, report = self.run_inventory(path)
        self.assertEqual(code, 2)
        self.assertIn("duplicate member", report["errors"][0])

    def test_missing_readelf_is_an_explicit_error(self):
        errors = io.StringIO()
        with contextlib.redirect_stderr(errors):
            code = compat.main(["inspect", str(self.make_apk()), "--readelf", "nonexistent-readelf-fixture"])
        self.assertEqual(code, 2)
        self.assertIn("readelf is required", errors.getvalue())

    def test_cannot_overwrite_input_with_report(self):
        path = self.make_apk()
        before = path.read_bytes()
        with contextlib.redirect_stderr(io.StringIO()):
            code = compat.main(["inspect", str(path), "-o", str(path)])
        self.assertEqual(code, 2)
        self.assertEqual(before, path.read_bytes())


class CollectionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.directory = Path(self.temporary.name)
        self.addCleanup(self.temporary.cleanup)
        self.log = self.directory / "commands.jsonl"
        self.adb = self.directory / "fixture-adb"
        # Synthetic transport exercises command construction; no phone is used.
        self.adb.write_text(f'#!{sys.executable}\n' + '''import json, os, sys
from pathlib import Path
args = sys.argv[1:]
with open(os.environ["FIXTURE_ADB_LOG"], "a") as log:
    log.write(json.dumps(args) + "\\n")
if args[:2] == ["-s", "fixture-device"]:
    args = args[2:]
if args[:3] == ["shell", "pm", "path"]:
    print("package:/data/app/fixture/base.apk")
    print("package:/data/app/fixture/split_config.fixture.apk")
elif args[0] == "pull":
    if os.environ.get("FIXTURE_PULL_FAIL"):
        sys.exit(1)
    Path(args[2]).write_bytes(b"synthetic APK transfer fixture")
else:
    sys.exit(9)
''')
        self.adb.chmod(0o700)

    def test_collects_every_listed_split_using_only_read_operations(self):
        output = self.directory / "copied"
        with patch.dict(os.environ, {"FIXTURE_ADB_LOG": str(self.log)}), contextlib.redirect_stdout(io.StringIO()):
            code = compat.main(["collect", str(output), "--package", "org.reverse.fixture", "--adb", str(self.adb),
                                "--serial", "fixture-device"])
        self.assertEqual(code, 0)
        report = json.loads((output / "collection.json").read_text())
        self.assertEqual(report["status"], "all_listed_apks_copied")
        self.assertEqual(len(report["apks"]), 2)
        commands = [json.loads(line)[2:] for line in self.log.read_text().splitlines()]
        self.assertEqual(commands[0], ["shell", "pm", "path", "org.reverse.fixture"])
        self.assertEqual(commands[-1], commands[0])
        self.assertEqual([command[0] for command in commands], ["shell", "pull", "pull", "shell"])

    def test_failure_keeps_an_incomplete_collection_and_does_not_overwrite(self):
        output = self.directory / "partial"
        with patch.dict(os.environ, {"FIXTURE_ADB_LOG": str(self.log), "FIXTURE_PULL_FAIL": "1"}), contextlib.redirect_stderr(io.StringIO()):
            code = compat.main(["collect", str(output), "--package", "org.reverse.fixture", "--adb", str(self.adb)])
        self.assertEqual(code, 2)
        self.assertEqual(json.loads((output / "collection.json").read_text())["status"], "incomplete")
        with contextlib.redirect_stderr(io.StringIO()):
            code = compat.main(["collect", str(output), "--package", "org.reverse.fixture", "--adb", str(self.adb)])
        self.assertEqual(code, 2)

    def test_package_shell_metacharacters_are_rejected_before_adb(self):
        with contextlib.redirect_stderr(io.StringIO()):
            code = compat.main(["collect", str(self.directory / "unused"), "--package", "org.example;id", "--adb", str(self.adb)])
        self.assertEqual(code, 2)
        self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
