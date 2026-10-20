# exteplayer3 pro DreamOS

[English](README.md)

Statický build [exteplayer3](https://github.com/skyjet18/exteplayer3) (skyjet18) a
ffmpeg pro Dreamboxy s **DreamOS 2.5**. Používá ho
[ServiceApp pro DreamOS](https://github.com/Blacker91/serviceapp-dreamos) a ArchivCZSK.

| Box | Architektura |
|---|---|
| DM520, DM525 | mipsel |
| DM900, DM920 | armhf |

Staticky linkovaný (musl), takže nezávisí na knihovnách image.
FFmpeg 6.1 (úpravy skyjet18: DASH, CENC DRM), OpenSSL 3, libxml2.

## Balíčky
- `exteplayer3-dreamos` → `/usr/bin/exteplayer3`
- `ffmpeg-exteplayer3-dreamos` → `/usr/lib/exteplayer3_deps/ffmpeg` (pro ArchivCZSK, systémový ffmpeg zůstává)

Oba fungují na všech podporovaných boxech, správná binárka se vybere sama.

## Instalace
Spolu se ServiceApp (doporučeno), na boxu:
```sh
wget -qO- https://raw.githubusercontent.com/Blacker91/serviceapp-dreamos/dreamos/installer.sh | sh
```
Nebo stáhni `.deb` z [Releases](https://github.com/Blacker91/exteplayer3-dreamos/releases) a spusť `dpkg -i *.deb`.

Když ArchivCZSK nabídne stažení novějšího exteplayer3, odpověz **Ne**, jinak by tento build přepsal.

## Změny proti skyjet18
Viz [patches](patches) a [CHANGELOG.md](CHANGELOG.md). Stručně: volby za adresou fungují
i s musl, oddělený zvuk a klíče DRM, zvuk MP2, zvuk živých streamů, rozpad obrazu
H.264 u TV záznamů.

## Kompilace
Na Debianu/Ubuntu:
```sh
sudo apt install git make cmake pkg-config python3-pip file
pip install ziglang==0.17.0
./build.sh mipsel
./build.sh arm
./package.sh
```

## Licence
Binárka `exteplayer3`: GPLv3 ([LICENSE](LICENSE)). Obsahuje exteplayer3 (GPLv2 nebo novější),
FFmpeg (LGPLv3), OpenSSL (Apache 2.0), libxml2 (MIT) a zlib, viz [SOURCES.md](SOURCES.md)
a [licenses](licenses). Díky skyjet18 za exteplayer3 a úpravy FFmpeg.
