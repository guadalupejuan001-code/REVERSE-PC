# Real Android Cuttlefish vendor + generic initramfs engineering gate

## Baseline / source identity
The most recent successful original XI/Ether kernel + generic first-stage initramfs
checkpoint is **8,890,950 ARM64 guest instructions** ([CI 40799502063](https://github.com/guadalupejuan001-code/REVERSE-PC/actions/runs/40799502063)),
SHA256 `b613833f175dc1adf3a53edd4e9002f69bde5ab2e8ec8fe57372c7394302ffb6`.
That historical state intentionally lacked the vendor ramdisk and Android bootconfig.
It is not rewritten; the next experiment starts a separate authentic Android boot from
its original pinned inputs, with no second XI/Ether memory authority.

Only **one** official build is used: aosp-android-latest-release,
`aosp_cf_arm64_only_phone-userdebug`, build **16644040**.
The authenticated boot.img, init_boot.img and vendor_boot.img are individually SHA256-
pinned in the experimental CI. The vendor_boot header is v4 and contains precisely
**one** ramdisk fragment, of type **PLATFORM** (1), at offset 0, filling the vendor
ramdisk section. No RECOVERY/unknown fragments are silently selected.

## New bounded host-side staging tool (not a CPU)
`tools/aosp_cuttlefish_stage.mjs` uses the existing AOSP v4 parser, validates
the actual Cuttlefish fragment, checks LZ4 legacy magic on both original
compressed ramdisks, and concatenates **original vendor fragment bytes first,
generic init_boot ramdisk second, with no page padding**. It appends the exact
117-byte vendor bootconfig data with Linux's 4-byte aligned bootconfig footer:
`[configuration][zero padding][size_le32][checksum_le32][#BOOTCONFIG\n]`.
The checksum is the uint32 sum of actual bootconfig bytes plus zero padding.
This is a host bootloader-input preparation only; no binary is committed.

The final initramfs is bounded to 64 MiB; the original Linux RVI1 backing to
128 MiB. Original ELF 16 MiB quota and existing finite host memory remain.
New tests verify fragment type/order, exact footer and checksum, no-overwrite,
failure for incompatible FDT, compression and malformed inputs. A separate
CI compares the prefix and suffix to the original extracted vendor and generic
bytes using GNU cmp, validates source hashes, then tests original XI/Ether ARM64
execution and direct-vs-resumed checkpoint equality.

## Independent sources and future architectural blockers
- Android official [vendor boot documentation](https://source.android.com/docs/core/architecture/partitions/vendor-boot-partitions) requires generic ramdisk loaded last, no padding, same compression.
- Android official [bootconfig specification](https://source.android.com/docs/core/architecture/bootloader/implementing-bootconfig) and [Linux kernel bootconfig ABI](https://docs.kernel.org/admin-guide/bootconfig.html) define the trailer.
- The original REVERSE virtual FDT currently fixes bootargs to `console=ttyAMA0 earlycon=pl011,0x09000000 keep_bootcon nokaslr maxcpus=1`. It does **not** contain `bootconfig`, `init=/init` nor the Cuttlefish vendor command line. The new staging tool reports that **bootconfig availability is not equivalent to bootconfig consumption by the guest kernel**. Updating those DTB args would require its own separate, checkpoint-compatible and tested change, not a silent mutation.
- Cuttlefish's 72-byte vendor DTB is only structurally recognized; it is **not** mapped directly to REVERSE's custom PL011/GIC/timer board.
- Before any Android userspace acceptance, REVERSE still needs compatible virtio block, partitions from `super.img`, first-stage fstab, kernel modules, device identities and Android services (Binder/ART/Bionic), plus ADB transport. None may be inferred from CPU transition count.

No Cuttlefish ZIP or game binaries are uploaded to the repo. Neither
`/init` nor ADB nor Wild Rift is declared running without real guest evidence.
