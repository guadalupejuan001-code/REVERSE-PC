#!/usr/bin/env python3
"""Package verified XI assets with the unchanged Android 2.2 native shell.

This produces an unsigned, separate test application, never an upgrade signed
with an unrelated identity. Run Android zipalign and apksigner afterwards.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
from zipfile import ZipFile


def manifest_preview(data):
    chunks, offset, strings = [], 8, []
    while offset < len(data):
        kind, header, size = struct.unpack_from('<HHI', data, offset)
        chunk = bytearray(data[offset:offset + size])
        if kind == 1:
            count, styles, flags, start, _ = struct.unpack_from('<5I', chunk, 8)
            if styles:
                raise ValueError('Unexpected styled manifest string pool')
            utf8 = bool(flags & 0x100)
            def length(at, width):
                value = int.from_bytes(chunk[at:at + width], 'little')
                marker = 1 << (8 * width - 1)
                if value & marker:
                    value = ((value & (marker - 1)) << (8 * width)) | int.from_bytes(chunk[at + width:at + 2 * width], 'little')
                    return value, at + 2 * width
                return value, at + width
            for i in range(count):
                at = start + struct.unpack_from('<I', chunk, header + i * 4)[0]
                n, at = length(at, 1 if utf8 else 2)
                if utf8:
                    n, at = length(at, 1)
                strings.append(bytes(chunk[at:at + n * (1 if utf8 else 2)]).decode('utf-8' if utf8 else 'utf-16le'))
            substitutions = {
                'com.reversepc.velocity': 'com.reversepc.velocity.preview',
                '2.2.0-forest-assist-xi': '2.3.0-preview-dynamics-xi',
                'REVERSE VELOCITY': 'VELOCITY 2.3 PRUEBA',
            }
            for old in substitutions:
                if strings.count(old) != 1:
                    raise ValueError('Unexpected original manifest identity: ' + old)
            strings = [substitutions.get(s, s) for s in strings]
            payload, offsets = bytearray(), []
            for text in strings:
                offsets.append(len(payload))
                encoded = text.encode('utf-8' if utf8 else 'utf-16le')
                units = len(text.encode('utf-16le')) // 2
                if utf8:
                    if max(units, len(encoded)) >= 128:
                        raise ValueError('Unexpected long UTF-8 manifest string')
                    payload.extend(bytes([units, len(encoded)]))
                else:
                    payload.extend(struct.pack('<H', units))
                payload.extend(encoded)
                payload.extend(b'\0' if utf8 else b'\0\0')
            while len(payload) % 4:
                payload.append(0)
            pool_start = header + 4 * count
            chunk = bytearray(struct.pack('<HHI5I', 1, header, pool_start + len(payload), count, 0, flags & ~1, pool_start, 0))
            chunk.extend(struct.pack('<' + 'I' * count, *offsets))
            chunk.extend(payload)
        elif kind == 0x102:
            attr_start, attr_size, attr_count = struct.unpack_from('<HHH', chunk, header + 8)
            for i in range(attr_count):
                at = header + attr_start + i * attr_size
                name = strings[struct.unpack_from('<I', chunk, at + 4)[0]]
                if name == 'versionCode':
                    if chunk[at + 15] != 0x10:
                        raise ValueError('versionCode is not an integer')
                    struct.pack_into('<I', chunk, at + 16, 23)
        chunks.append(bytes(chunk))
        offset += size
    rebuilt = b''.join(chunks)
    return struct.pack('<HHI', 3, 8, 8 + len(rebuilt)) + rebuilt


def package(base, assets, output, report):
    hashes, retained = {}, {}
    with ZipFile(base) as original, ZipFile(output, 'w') as target:
        for info in original.infolist():
            if info.filename.startswith('META-INF/') and not info.filename.startswith('META-INF/com/android/'):
                continue
            content = original.read(info.filename)
            if info.filename == 'AndroidManifest.xml':
                content = manifest_preview(content)
            elif info.filename.startswith('assets/velocity/'):
                source = assets / info.filename.split('/')[-1]
                content = source.read_bytes()
                hashes[info.filename] = hashlib.sha256(content).hexdigest()
            else:
                retained[info.filename] = hashlib.sha256(content).hexdigest()
            info.extra = b''
            target.writestr(info, content)
    # The preview must use the exact checked-in executable XI and the original
    # compiled Android/JNI shell. No executable is rebuilt or swapped here.
    with ZipFile(output) as check:
        for name, expected in {**hashes, **retained}.items():
            if hashlib.sha256(check.read(name)).hexdigest() != expected:
                raise ValueError('Packaged bytes differ: ' + name)
    result = {'package': 'com.reversepc.velocity.preview', 'versionCode': 23,
              'versionName': '2.3.0-preview-dynamics-xi', 'nativeShell': 'unchanged 2.2 APK',
              'baseApkSha256': hashlib.sha256(base.read_bytes()).hexdigest(),
              'executableAssetsSha256': hashes, 'retainedEntriesSha256': retained,
              'androidEmulatorTested': False, 'originalSignatureUpgrade': False}
    report.write_text(json.dumps(result, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['base', 'assets', 'output', 'report']:
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    package(args.base, args.assets, args.output, args.report)
