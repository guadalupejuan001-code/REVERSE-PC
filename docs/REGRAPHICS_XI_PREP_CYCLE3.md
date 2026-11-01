# XI scene preparation — bounded multi-program cache

The previous machine interpreter cached only one exact-source parsed program per thread. Switching between camera or paint variants evicted the preceding program and caused the full scene to be tokenized and label-validated again on the next frame.

This change uses a four-entry, exact-source, per-thread LRU cache with a total source-byte budget of 1 MiB and a per-program maximum of 512 KiB. No registers, Ether state, geometry buffers, pixel arrays, or mutable execution state are cached. Parsing and jump validation must finish successfully before admission.

Expected benefit: less repeated preparation when a worker alternates among camera and material variants. It does **not** eliminate per-instruction interpretation, and it cannot accelerate a single unchanged program beyond the existing one-entry cache. Programs larger than 512 KiB still execute without being cached.

Verification required: run XI machine suite and camera-switch workload comparing exact frame hashes and state before merging; measure warm/cold parse latency separately. Do not claim an FPS improvement from this code change alone.
