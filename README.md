# exteplayer3 for DreamOS

[Česky](README.cs.md)

Static build of [exteplayer3](https://github.com/skyjet18/exteplayer3) (skyjet18) and
ffmpeg for Dreamboxes with **DreamOS 2.5**. Used by
[ServiceApp for DreamOS](https://github.com/Blacker91/serviceapp-dreamos) and ArchivCZSK.

## ⚠️ Warning
- **Use at your own risk.** Make a **backup of your image** before installing.
- Install only on **enigma2 4.3.3r3** (DreamOS 2.5, the last released unstable version),
  the version it was tested on. Check it on the box with `dpkg -l enigma2`.
- Tested on a DM520. The DM900/DM920 build is checked against the same enigma2
  version but has not been tested on the box yet.

| Box | Architecture |
|---|---|
| DM520, DM525 | mipsel |
| DM900, DM920 | armhf |

Statically linked (musl), so it does not depend on the libraries of the image.
FFmpeg 6.1 (skyjet18 patches: DASH, CENC DRM), OpenSSL 3, libxml2.

## Packages
- `exteplayer3-dreamos` → `/usr/bin/exteplayer3`
- `ffmpeg-exteplayer3-dreamos` → `/usr/lib/exteplayer3_deps/ffmpeg` (for ArchivCZSK, the system ffmpeg is not touched)

Both work on all supported boxes, the right binary is installed automatically.

## Install
Together with ServiceApp (recommended), on the box:
```sh
curl -fsSL https://raw.githubusercontent.com/Blacker91/serviceapp-dreamos/dreamos/installer.sh | sh
```
Or download the `.deb` files from [Releases](https://github.com/Blacker91/exteplayer3-dreamos/releases) and run `dpkg -i *.deb`.

When ArchivCZSK offers to download a newer exteplayer3, answer **No**, it would replace this build.

## Changes against skyjet18
See [patches](patches) and [CHANGELOG.md](CHANGELOG.md). In short: options after the URL
work with musl, separate audio and DRM keys, MP2 sound, sound of live streams,
H.264 picture breakup with TV recordings.

## Contact
Bugs and suggestions: [Issues](https://github.com/Blacker91/exteplayer3-dreamos/issues) or e-mail
**dreamosserviceapp@gmail.com**.
