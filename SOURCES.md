# Sources

The released binaries are built by `build.sh` from exactly these sources.
A source archive of each release is attached to the GitHub release.

| Component | Source | Version | License |
|---|---|---|---|
| exteplayer3 | https://github.com/skyjet18/exteplayer3 | `cda720ec894f42ecec19dbe8d307750bf248015e` (184) + [patches](patches) | GPLv2 or later |
| FFmpeg | https://github.com/skyjet18/FFmpeg, branch `release/6.1-patched` | `ea4d5204424fa53de15dbc2781424af7223b3bb9` | LGPLv3 (`--enable-version3`) |
| OpenSSL | https://github.com/openssl/openssl | `openssl-3.5.4` | Apache 2.0 |
| libxml2 | https://github.com/GNOME/libxml2 | `v2.13.8` | MIT |
| zlib | https://github.com/madler/zlib | `v1.3.1` | zlib |
| Zig toolchain (musl libc and compiler-rt are linked in) | https://pypi.org/project/ziglang/ | 0.17.0 | MIT |

`exteplayer3` links all of the above statically, so the binary as a whole is
distributed under **GPLv3** ([LICENSE](LICENSE)); the licenses of the other
components are in [licenses](licenses).
