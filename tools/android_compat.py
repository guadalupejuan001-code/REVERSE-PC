#!/usr/bin/env python3
"""Read-only APK/split inventory for Android graphics compatibility research.

Python 3.10+ and GNU readelf. No APK or native library is executed.
Static references are evidence of linkage, never proof of a runtime backend.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile

ANDROID = "http://schemas.android.com/apk/res/android"
MIB = 1024 * 1024
MAX_APKS = 128
MAX_ENTRIES = 100000
MAX_MANIFEST = 8 * MIB
MAX_READELF_OUTPUT = 64 * MIB
GRAPHICS_LIBRARIES = ("libEGL.so", "libGLESv1_CM.so", "libGLESv2.so", "libGLESv3.so", "libvulkan.so")
ABI_MACHINES = {"armeabi-v7a": (40, 32), "arm64-v8a": (183, 64), "x86": (3, 32), "x86_64": (62, 64), "riscv64": (243, 64)}


class InspectionError(Exception):
    pass


def unpack(fmt, data, offset, end=None):
    end = len(data) if end is None else end
    if offset < 0 or offset + struct.calcsize(fmt) > end:
        raise InspectionError("Truncated binary structure")
    return struct.unpack_from(fmt, data, offset)


def chunk(data, offset, end):
    kind, header_size, size = unpack("<HHI", data, offset, end)
    if header_size < 8 or size < header_size or offset + size > end:
        raise InspectionError("Invalid Android XML chunk size")
    return kind, header_size, offset + size


def string_pool(data, offset, header, end):
    if header < 28:
        raise InspectionError("Invalid Android string pool header")
    count, styles, flags, start, style_start = unpack("<IIIII", data, offset + 8, end)
    if count > 100000 or styles > 100000 or offset + header + 4 * (count + styles) > end:
        raise InspectionError("Invalid Android string pool count")
    if start < header + 4 * (count + styles) or offset + start > end:
        raise InspectionError("Invalid Android string pool offset")
    strings_end = offset + style_start if style_start else end
    if not offset + start <= strings_end <= end:
        raise InspectionError("Invalid Android string pool extent")

    def length(pos, utf8):
        fmt, mask, shift, step = ("<B", 0x80, 8, 1) if utf8 else ("<H", 0x8000, 16, 2)
        first = unpack(fmt, data, pos, strings_end)[0]
        pos += step
        if first & mask:
            second = unpack(fmt, data, pos, strings_end)[0]
            return ((first & (mask - 1)) << shift) | second, pos + step
        return first, pos

    result = []
    for i in range(count):
        relative = unpack("<I", data, offset + header + 4 * i, end)[0]
        pos = offset + start + relative
        if pos < offset + start or pos >= strings_end:
            raise InspectionError("Android string outside string pool")
        utf8 = bool(flags & 0x100)
        size, pos = length(pos, utf8)
        if utf8:
            size, pos = length(pos, True)
        else:
            size *= 2
        terminator = 1 if utf8 else 2
        if pos + size + terminator > strings_end or any(data[pos + size:pos + size + terminator]):
            raise InspectionError("Truncated or unterminated Android string")
        result.append(data[pos:pos + size].decode("utf-8" if utf8 else "utf-16le"))
    return result


def manifest_nodes(data):
    if len(data) > MAX_MANIFEST:
        raise InspectionError("Manifest exceeds inspection limit")
    if data.lstrip(b"\xef\xbb\xbf \t\r\n").startswith(b"<"):
        if b"<!DOCTYPE" in data.upper() or b"<!ENTITY" in data.upper():
            raise InspectionError("DTD/entity declarations are not supported")
        root = ET.fromstring(data)
        if root.tag != "manifest":
            raise InspectionError("Expected a manifest root element")
        return [(node.tag, dict(node.attrib)) for node in root.iter()], "xml_text"
    kind, header, root_end = chunk(data, 0, len(data))
    if kind != 3 or root_end != len(data):
        raise InspectionError("Expected Android binary XML")
    strings, nodes = None, []

    def text_at(index):
        if strings is None or not 0 <= index < len(strings):
            raise InspectionError("Invalid Android XML string reference")
        return strings[index]

    offset = header
    while offset < root_end:
        kind, size, end = chunk(data, offset, root_end)
        if kind == 1:
            if strings is not None:
                raise InspectionError("Duplicate Android XML string pool")
            strings = string_pool(data, offset, size, end)
        elif kind == 0x102:
            if size < 16:
                raise InspectionError("Invalid Android XML node header")
            extension = offset + size
            _, name, attr_start, attr_size, count, _, _, _ = unpack("<IIHHHHHH", data, extension, end)
            if attr_start < 20 or attr_size < 20 or extension + attr_start + attr_size * count > end:
                raise InspectionError("Invalid Android XML attributes")
            attributes = {}
            for i in range(count):
                pos = extension + attr_start + i * attr_size
                namespace, attr_name, raw, value_size, _, value_type, value = unpack("<IIIHBBI", data, pos, end)
                if value_size != 8:
                    raise InspectionError("Invalid Android XML typed value")
                key = text_at(attr_name)
                if namespace != 0xffffffff:
                    key = "{" + text_at(namespace) + "}" + key
                if raw != 0xffffffff:
                    value = text_at(raw)
                elif value_type == 3:
                    value = text_at(value)
                elif value_type == 0x12:
                    value = bool(value)
                elif value_type not in (0x10, 0x11):
                    value = {"type": value_type, "data": hex(value)}
                if key in attributes:
                    raise InspectionError("Duplicate Android XML attribute")
                attributes[key] = value
            nodes.append((text_at(name), attributes))
        offset = end
    if not nodes or nodes[0][0] != "manifest" or sum(name == "manifest" for name, _ in nodes) != 1:
        raise InspectionError("Expected one manifest root element")
    return nodes, "android_binary_xml"


def manifest_metadata(data):
    nodes, encoding = manifest_nodes(data)
    root = nodes[0][1]

    def attr(node, name, default=None):
        return node.get("{" + ANDROID + "}" + name, default)

    def number(value):
        if isinstance(value, str):
            try:
                return int(value, 16 if value.startswith("0x") else 10)
            except ValueError:
                pass
        return value

    def boolean(value):
        return {"true": True, "false": False}.get(value, value) if isinstance(value, str) else value

    sdk = next((attributes for name, attributes in nodes if name == "uses-sdk"), {})
    app = next((attributes for name, attributes in nodes if name == "application"), {})
    return {
        "encoding": encoding,
        "package": root.get("package"),
        "version_code": number(attr(root, "versionCode")),
        "version_code_major": number(attr(root, "versionCodeMajor", 0)),
        "version_name": attr(root, "versionName"),
        "split": root.get("split"),
        "config_for_split": root.get("configForSplit"),
        "is_feature_split": boolean(attr(root, "isFeatureSplit")),
        "uses_splits": [attr(a, "name") for name, a in nodes if name == "uses-split"],
        "sdk": {key: number(attr(sdk, key)) for key in ("minSdkVersion", "targetSdkVersion", "maxSdkVersion")},
        "gles_requirements": [{"version": number(attr(a, "glEsVersion")), "required": boolean(attr(a, "required", True))}
                              for name, a in nodes if name == "uses-feature" and attr(a, "glEsVersion") is not None],
        "debuggable": boolean(attr(app, "debuggable", False)),
        "application_name": attr(app, "name"),
    }


class Budget:
    def __init__(self, limit):
        self.remaining = limit

    def consume(self, size):
        self.remaining -= size
        if self.remaining < 0:
            raise InspectionError("Total decompression budget exceeded")


def copy_member(archive, info, destination, limit, budget):
    if info.file_size > limit or info.flag_bits & 1:
        raise InspectionError("Member exceeds size limit or is encrypted: " + info.filename)
    total, digest, markers, tail = 0, hashlib.sha256(), set(), b""
    with archive.open(info) as source:
        while True:
            block = source.read(MIB)
            if not block:
                break
            total += len(block)
            budget.consume(len(block))
            if total > limit:
                raise InspectionError("Expanded member exceeds size limit")
            digest.update(block)
            window = tail + block
            markers.update(name for name in GRAPHICS_LIBRARIES if name.encode() + b"\0" in window)
            tail = window[-128:]
            destination.write(block)
    return digest.hexdigest(), sorted(markers)


def file_hash(path):
    digest = hashlib.sha256()
    with open(path, "rb") as source:
        for block in iter(lambda: source.read(MIB), b""):
            digest.update(block)
    return digest.hexdigest()


def inspect_elf(path, readelf):
    with open(path, "rb") as source:
        header = source.read(64)
    if len(header) < 52 or header[:4] != b"\x7fELF" or header[4] not in (1, 2) or header[5] not in (1, 2):
        raise InspectionError("Invalid ELF header")
    bits = 32 if header[4] == 1 else 64
    if bits == 64 and len(header) < 64:
        raise InspectionError("Truncated ELF64 header")
    machine = struct.unpack_from("<H" if header[5] == 1 else ">H", header, 18)[0]
    imports, needed, loaders = set(), set(), set()
    with tempfile.TemporaryFile() as output, tempfile.TemporaryFile() as errors:
        try:
            result = subprocess.run([readelf, "--wide", "--dynamic", "--dyn-syms", "--use-dynamic", str(path)], stdout=output,
                                    stderr=errors, timeout=30, env={**os.environ, "LC_ALL": "C"})
        except (OSError, subprocess.TimeoutExpired) as error:
            raise InspectionError("readelf could not inspect the library: " + str(error)) from error
        if result.returncode or errors.tell():
            errors.seek(0)
            raise InspectionError("readelf rejected or warned about ELF: " + errors.read(2000).decode("utf-8", "replace"))
        if output.tell() > MAX_READELF_OUTPUT:
            raise InspectionError("readelf output exceeds inspection limit")
        output.seek(0)
        for raw in output:
            line = raw.decode("utf-8", "replace")
            match = re.search(r"\(NEEDED\).*Shared library: \[(.+?)\]", line)
            if match:
                needed.add(match[1])
            columns = line.split()
            if len(columns) >= 8 and columns[0].endswith(":") and columns[6] == "UND":
                name = columns[7].split("@")[0]
                if re.match(r"^(?:egl|gl|vk)[A-Z]", name):
                    imports.add(name)
                if name in ("dlopen", "dlsym", "android_dlopen_ext"):
                    loaders.add(name)
    return {"bits": bits, "machine": machine, "needed": sorted(needed), "graphics_imports": sorted(imports),
            "dynamic_lookup_imports": sorted(loaders), "inspection": "static_readelf"}


def check_archive(archive):
    entries = archive.infolist()
    if len(entries) > MAX_ENTRIES:
        raise InspectionError("Archive contains too many entries")
    names = [info.filename for info in entries]
    if len(set(names)) != len(names):
        raise InspectionError("Archive contains duplicate member names")
    for name in names:
        if PurePosixPath(name).is_absolute() or ".." in PurePosixPath(name).parts or "\\" in name or "\0" in name:
            raise InspectionError("Archive contains an unsafe member name")
    return entries


def inspect_apk(path, label, args, budget):
    if path.stat().st_size > args.max_apk_mib * MIB:
        raise InspectionError("APK exceeds configured size limit")
    result = {"name": label, "bytes": path.stat().st_size, "sha256": file_hash(path),
              "native_libraries": [], "dex_files": [], "errors": []}
    with zipfile.ZipFile(path) as archive:
        entries = check_archive(archive)
        try:
            manifest = archive.getinfo("AndroidManifest.xml")
        except KeyError as error:
            raise InspectionError("APK has no AndroidManifest.xml") from error
        if manifest.file_size > MAX_MANIFEST:
            raise InspectionError("Manifest exceeds inspection limit")
        budget.consume(manifest.file_size)
        result["manifest"] = manifest_metadata(archive.read(manifest))
        for info in entries:
            if re.fullmatch(r"classes(?:[2-9]|[1-9][0-9]+)?\.dex", info.filename):
                result["dex_files"].append({"name": info.filename, "bytes": info.file_size})
            match = re.fullmatch(r"lib/([^/]+)/([^/]+\.so)", info.filename)
            if not match:
                continue
            library = {"path": info.filename, "abi": match[1], "bytes": info.file_size}
            try:
                with tempfile.TemporaryDirectory(prefix="reverse-elf-") as directory:
                    native = Path(directory) / "library.so"
                    with native.open("wb") as destination:
                        library["sha256"], library["embedded_graphics_library_names"] = copy_member(
                            archive, info, destination, args.max_native_mib * MIB, budget)
                    library["elf"] = inspect_elf(native, args.readelf)
                    declared = ABI_MACHINES.get(match[1])
                    if declared and declared != (library["elf"]["machine"], library["elf"]["bits"]):
                        raise InspectionError("ELF architecture does not match the declared APK ABI")
            except (InspectionError, OSError, zipfile.BadZipFile, RuntimeError) as error:
                library["error"] = str(error)
                result["errors"].append(info.filename + ": " + str(error))
            result["native_libraries"].append(library)
    return result


def inspect_inputs(args):
    if not shutil.which(args.readelf):
        raise InspectionError("readelf is required; install GNU binutils or pass --readelf /path/to/readelf")
    sources = []
    for raw in args.inputs:
        path = Path(raw).resolve()
        sources.extend(sorted(path.rglob("*.apk")) if path.is_dir() else [path])
    if not sources or len(sources) > MAX_APKS:
        raise InspectionError("Provide between 1 and 128 APKs or one APK container")
    if args.output and Path(args.output).resolve() in sources:
        raise InspectionError("The report must not overwrite an input APK")
    report = {"schema": "reverse-android-compat-v1", "scope": "provided_files_only", "apks": [], "errors": [],
              "runtime_graphics_backend": "not_observed", "renderer_replacement": "not_implemented",
              "wild_rift_execution": "not_tested", "performance": "not_measured",
              "limitations": ["Static references do not establish which graphics API runs on a device.",
                              "Only standard lib/<abi>/*.so entries are inspected; other native payloads may exist.",
                              "Libraries may be loaded dynamically or supplied after installation.",
                              "Java/DEX implementations and runtime graphics calls are not decoded or traced.",
                              "Package metadata does not prove all required splits/assets are present.",
                              "Input signatures are not verified; SHA-256 identifies bytes, not provenance."]}
    budget = Budget(args.max_total_mib * MIB)

    def add(path, label):
        if len(report["apks"]) >= MAX_APKS:
            raise InspectionError("Too many APKs in input set")
        apk = inspect_apk(path, label, args, budget)
        report["apks"].append(apk)
        report["errors"].extend(label + ": " + error for error in apk["errors"])

    for path in sources:
        try:
            if not path.is_file() or path.stat().st_size > args.max_apk_mib * MIB:
                raise InspectionError("Input is missing, not a file, or exceeds the size limit")
            with zipfile.ZipFile(path) as archive:
                entries = check_archive(archive)
                is_apk = "AndroidManifest.xml" in archive.namelist()
                nested = [info for info in entries if info.filename.lower().endswith(".apk")]
                if not is_apk:
                    if not nested or len(nested) + len(report["apks"]) > MAX_APKS:
                        raise InspectionError("Container has no APKs or exceeds the APK count limit")
                    for info in nested:
                        with tempfile.TemporaryDirectory(prefix="reverse-apk-") as directory:
                            extracted = Path(directory) / "input.apk"
                            with extracted.open("wb") as destination:
                                copy_member(archive, info, destination, args.max_apk_mib * MIB, budget)
                            add(extracted, path.name + "!" + info.filename)
            if is_apk:
                add(path, path.name)
        except (InspectionError, OSError, ValueError, UnicodeError, ET.ParseError, struct.error, zipfile.BadZipFile, RuntimeError) as error:
            report["errors"].append(path.name + ": " + str(error))
    packages = sorted({apk["manifest"]["package"] for apk in report["apks"] if isinstance(apk["manifest"].get("package"), str)})
    versions = {(str(apk["manifest"]["version_code_major"]), str(apk["manifest"]["version_code"])) for apk in report["apks"]}
    report["packages"] = packages
    report["expected_package"] = args.expect_package
    if len(packages) != 1 or len(versions) != 1 or any(not apk["manifest"].get("package") for apk in report["apks"]):
        report["errors"].append("Inputs must identify one package and one version; inspect variants separately")
    if args.expect_package and packages != [args.expect_package]:
        report["errors"].append("Input package does not match --expect-package")
    report["status"] = "incomplete" if report["errors"] else "static_inventory_complete"
    return report


def collect_apks(args):
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)+", args.package):
        raise InspectionError("Invalid Android package ID")
    if not shutil.which(args.adb):
        raise InspectionError("ADB is unavailable; install Android SDK Platform Tools")
    destination = Path(args.directory).resolve()
    if destination.exists():
        raise InspectionError("Use a new output directory to preserve existing files")
    command = [args.adb] + (["-s", args.serial] if args.serial else [])
    # Only pm path and pull: never install, root, launch, patch or change settings.
    result = subprocess.run(command + ["shell", "pm", "path", args.package], capture_output=True, text=True, timeout=30)
    if result.returncode:
        raise InspectionError("ADB could not query the selected device: " + result.stderr.strip()[:1000])
    lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    if not lines or any(not line.startswith("package:/") or not line.endswith(".apk") for line in lines):
        raise InspectionError("No complete APK path list returned; check package ID and device authorization")
    paths = [line[len("package:"):] for line in lines]
    if len(paths) > MAX_APKS or len(paths) != len(set(paths)) or any(len(p) > 4096 or any(ord(c) < 32 for c in p) for p in paths):
        raise InspectionError("Invalid or excessive installed APK list")
    destination.mkdir(parents=True, mode=0o700)
    report = {"schema": "reverse-apk-collection-v1", "package": args.package, "status": "incomplete",
              "device_operations": ["shell pm path", "pull"], "apks": []}
    try:
        for index, remote in enumerate(paths):
            filename = f"{index:03d}-" + re.sub(r"[^A-Za-z0-9._-]", "_", PurePosixPath(remote).name)
            local = destination / filename
            result = subprocess.run(command + ["pull", remote, str(local)], capture_output=True, text=True, timeout=180)
            if result.returncode or not local.is_file():
                raise InspectionError("ADB pull failed for " + filename + ": " + result.stderr.strip()[:1000])
            report["apks"].append({"file": filename, "bytes": local.stat().st_size, "sha256": file_hash(local)})
        # Detect an update that replaces the installed split list during copying.
        after = subprocess.run(command + ["shell", "pm", "path", args.package], capture_output=True, text=True, timeout=30)
        after_paths = [line.strip() for line in after.stdout.splitlines() if line.strip()]
        if after.returncode or after_paths != lines:
            raise InspectionError("Installed APK paths changed during collection; retry into a new directory")
        report["status"] = "all_listed_apks_copied"
    finally:
        (destination / "collection.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    return report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    inspect = commands.add_parser("inspect", help="Inventory local APKs, a directory, APKS or XAPK without executing code")
    inspect.add_argument("inputs", nargs="+")
    inspect.add_argument("--output", "-o")
    inspect.add_argument("--expect-package", help="Reject a different package instead of analyzing it as the intended target")
    inspect.add_argument("--readelf", default="readelf")
    for name, default in (("apk", 2048), ("native", 512), ("total", 4096)):
        inspect.add_argument("--max-" + name + "-mib", type=int, default=default)
    collect = commands.add_parser("collect", help="Copy every installed APK listed by a user-authorized ADB device")
    collect.add_argument("directory")
    collect.add_argument("--package", required=True)
    collect.add_argument("--serial")
    collect.add_argument("--adb", default="adb")
    args = parser.parse_args(argv)
    try:
        if args.command == "inspect" and min(args.max_apk_mib, args.max_native_mib, args.max_total_mib) <= 0:
            raise InspectionError("Inspection size limits must be positive")
        report = inspect_inputs(args) if args.command == "inspect" else collect_apks(args)
        encoded = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
        if getattr(args, "output", None):
            path = Path(args.output)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(encoded, encoding="utf-8")
        else:
            print(encoded, end="")
        return 2 if report.get("status") == "incomplete" else 0
    except (InspectionError, OSError, subprocess.TimeoutExpired) as error:
        print("android-compat: " + str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
