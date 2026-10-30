# BBY Q X08 in REVERSE

`integration/bbyq-x08/profile.json` pins one BBY-Q revision, its complete canonical training seed and both native XI roles. The REVERSE launcher verifies that revision and every prepared asset, then runs XI through the supplied original interpreter. It uses the durable X08 session API: one state per session, immutable versions, a process lock and request receipts. Repeating a request ID returns its earlier receipt; using that ID for different text is rejected.

This closes the native source and release integration. Android adaptation, APK compilation, phone validation and external model/audio/image evaluations remain outside this change (P13/P14). The existing Android release is not silently relabeled as X08.

Requirements: Linux, Node 24.22.1, `git`, `tar`, `flock`, the original `reverse_pc` executable and a checkout of the BBY-Q revision in the profile. The release is self-contained; it does not fetch conversation attachments or contact an external model. All language interpretation, teaching, book decoding and program decisions execute in XI/Ether. The launcher transports bytes and manages files.

```sh
node integration/bbyq-x08/run.mjs prepare --bbyq /path/BBY-Q --build /path/new-x08-build
node integration/bbyq-x08/run.mjs init --bbyq /path/BBY-Q --build /path/new-x08-build --session /path/new-session
node integration/bbyq-x08/run.mjs turn --bbyq /path/BBY-Q --build /path/new-x08-build --session /path/new-session --runtime /path/reverse_pc --id request-001 --text 'consulta: nomasir caballo'
```

Use `--file /path/message.txt` instead of `--text` to preserve long UTF-8 messages and line breaks. Keep the same request ID when retrying an uncertain result. Prepared training assets stay separate from session state and are never overwritten by a turn.

The `migrate` operation accepts `--state ORIGINAL_X07.rvp --output NEW_X08.rvp --runtime /path/reverse_pc`. It preserves the original and verifies every migration phase. Older states must first follow their X07 migration path; arbitrary states are rejected.

The native profile contains 480 concepts, 960 relations, the 122 normalized source pages and their 1,171 original fragment spans. Translation, grammar, summaries, comparison, writing and reasoning retain their documented limited contracts. Integration does not establish general conversation or autonomous economic reasoning.

Validation: `node integration/bbyq-x08/test.mjs /path/BBY-Q /path/reverse_pc /path/new-tests`. It executes the real XI backend, translation, page retrieval, a multiline summary and a generated XI program, plus receipt and asset-integrity controls.
