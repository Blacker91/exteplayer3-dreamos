# Sources

The released binaries are built by `build.sh` from exactly these sources.
A source archive of each release is attached to the GitHub release.

| Component | Source | Version | License |
|---|---|---|---|
| exteplayer3 | https://github.com/skyjet18/exteplayer3 | `1df1fdc341b3a4284dc476db872b28be1282d364` (187) + [patches](patches) | GPLv2 or later |
| FFmpeg | https://github.com/skyjet18/FFmpeg, branch `release/6.1-patched` | `ca1f67f9175db4e49af62bf3d539736a727a873f` | LGPLv3 (`--enable-version3`) |
| OpenSSL | https://github.com/openssl/openssl | `openssl-3.5.4` | Apache 2.0 |
| libxml2 | https://github.com/GNOME/libxml2 | `v2.13.8` | MIT |
| zlib | https://github.com/madler/zlib | `v1.3.1` | zlib |
| Zig toolchain (musl libc and compiler-rt are linked in) | https://pypi.org/project/ziglang/ | 0.17.0 | MIT |

`exteplayer3` links all of the above statically, so the binary as a whole is
distributed under **GPLv3** ([LICENSE](LICENSE)); the licenses of the other
components are in [licenses](licenses).
