# Sources

The released binaries are built by `build.sh` from exactly these sources.
A source archive of each release is attached to the GitHub release.

| Component | Source | Version | License |
|---|---|---|---|
| exteplayer3 | https://github.com/skyjet18/exteplayer3 | `3e87bef42b8d233ae11d0527548308b84a6d2a2b` (185) + [patches](patches) | GPLv2 or later |
| FFmpeg | https://github.com/skyjet18/FFmpeg, branch `release/6.1-patched` | `0da0223cd1add40eabaad04e1ce609f05670a1de` | LGPLv3 (`--enable-version3`) |
| OpenSSL | https://github.com/openssl/openssl | `openssl-3.5.4` | Apache 2.0 |
| libxml2 | https://github.com/GNOME/libxml2 | `v2.13.8` | MIT |
| zlib | https://github.com/madler/zlib | `v1.3.1` | zlib |
| Zig toolchain (musl libc and compiler-rt are linked in) | https://pypi.org/project/ziglang/ | 0.17.0 | MIT |

`exteplayer3` links all of the above statically, so the binary as a whole is
distributed under **GPLv3** ([LICENSE](LICENSE)); the licenses of the other
components are in [licenses](licenses).
