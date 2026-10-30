# REVERSE 3.1.0 completo

This release consolidates the delivered 2.9.0 desktop with BBY-Q X09, current
Laplace, REgraphics/Velocity 0.3, Music, REexplorer, Qd and PRISMA. Android Guest
continuations remain separate work in progress.

## Native AI and data preservation

The existing RXE application remains the desktop identity and history carrier.
The Android host now executes the original X09 front/code/dictionary/campaign
roles sharing one RVPC2 state. A new session starts from the verified complete
X09 training fixture. Existing X07 state migrates through the original 270 X08
phases and original campaign migration, on unpublished candidate bytes. The old
state/history is retained if migration or a turn fails. Program dispatch is
persisted before sandbox execution; responses and history commit atomically.

All interpretation, dictionary routing/lookup and campaign reasoning run in XI.
Java provides framing, exact page transport, hashing and file lifecycle. X09
includes the original 236,256-entry dictionary, retained E009 banks and Babylon
pages. This is a bounded native system; it is not a general neural language model.

The primary JNI libraries are byte-identical to the delivered X07 APK. The
separate REgraphics library is the verified Velocity 0.3 library with only its
JNI dynamic-symbol prefix rebound from NativeRuntime to RenderRuntime and
its dynamic lookup hash tables rebuilt. ELF
`.text` remains byte-identical, recorded in `native-lock.json`. This retains
PRISMA's original ABI while avoiding selecting a renderer through the old host.

## Laplace

The packaged market predictor remains M001/XN01. U003/U004's archived 684-state
capture can be verified on the actual Android XI/Ether interpreter; its original
date and seven GDELT failures remain visible. Live remote captures may have
different coverage. X002's five frozen models and retrospective metrics are
available for inspection; their `laplace_temporal` directives are not silently
executed as generic XI or promoted to the live predictor.

The Entrada view captures Coinbase quotes and official Fed documents manually,
retains first receipt and offers a connection to a configured HTTPS I001 health
endpoint. It also displays the dated institutional records. The full I001
Kafka/PostgreSQL/TimescaleDB/NLP/on-chain server implementation is consolidated
in LaPlaceDIG. The mobile adapter does not claim that these server processes or
blockchain nodes run inside Android. Those services require deployment and
configuration by their operator.

## Rebuild

Use the original owner-supplied, hash-verified X09 prepared native directory,
the delivered X07 APK and Velocity 0.3 APK, the retained distribution keystore,
and the official Android 35 compiler-support files. None are replaced by a
smaller fixture. Large restored payloads and credentials are not committed.

1. Restore released desktop source with `import-sources.mjs` using the original
   2.8 source patch + X07 Android patch, delivered X07 APK, current Laplace
   Android source and pinned Velocity source. Apply this release's source changes.
2. Restore X09 native files into `app/src/main/assets/bbyq-x09`, then run
   `node integration/unified/prepare-x09.mjs`. The canonical model hash is pinned.
3. Run `node integration/unified/prepare-native.mjs X07.apk VELOCITY03.apk`.
4. Build with `REVERSE_LOCAL_SIGNING_PASS` set only for the command:
   `node integration/unified/build.mjs COMPILER_SUPPORT NEW_BUILD_DIR KEYSTORE NEW_OUTPUT.apk`.

The ZIP32 alignment helper preserves compressed streams and checks the actual
data offsets: four native libraries use 16 KiB ZIP alignment and resources.arsc is
uncompressed. The retained primary ELF libraries have 4 KiB segment alignment;
this ZIP alignment does not certify compatibility with 16 KiB page devices.
Android's apksigner independently verifies the signed result.
The package is `com.reversepc.complete.workbench`, versionCode 310, and uses the
same signing certificate as REVERSE 2.9.0-X07. Other historical application IDs
are separate installed editions and are not overwritten.

## Validation

- Consolidated LaPlaceDIG: 285 tests passed, zero failures/skips with all three
  original native executors connected.
- Production Android X09 Java transport executed through real JNI: seven
  reference cases, native dictionary in both languages, both campaign banks,
  Babylon retrieval and independently verified generated XI (637 + 284 = 921).
- X07-to-X09 migration preserved a personal definition, original state and book;
  campaign operation, idempotence and malformed/oversize rejection passed.
- Android Laplace adaptation: 13 tests passed, including original M001 parity,
  future-data rejection, real U003 archive hashes and native-proof mismatch rejection.
- The production Java global XI compiler materialized the original 684-state
  snapshot through real JNI: 21,904 bytes, exact roundtrip, zero qubits.
- Java source compiled against official Android API 35. Native library contents,
  packaged model/role hashes, ZIP CRC, data alignment and signature checked.

Full-APK installation/interaction on Android and a physical Galaxy A16 have not
been executed in this environment. Real Android tests from Velocity 0.3 remain
upstream evidence for that earlier APK, not installation evidence for this one.
