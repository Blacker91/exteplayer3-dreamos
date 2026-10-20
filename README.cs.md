# exteplayer3 pro DreamOS

[English](README.md)

Statický build [exteplayer3](https://github.com/skyjet18/exteplayer3) (skyjet18) a
ffmpeg pro Dreamboxy s **DreamOS 2.5**. Používá ho
[ServiceApp pro DreamOS](https://github.com/Blacker91/serviceapp-dreamos) a ArchivCZSK.

## ⚠️ Upozornění
- **Vše zkoušíš na vlastní nebezpečí.** Před instalací si **udělej zálohu image**.
- Instaluj pouze na **enigma2 4.3.3r3** (DreamOS 2.5, poslední vydaná unstable verze),
  na které jsme to zkoušeli. Verzi zjistíš na boxu příkazem `dpkg -l enigma2`.
- Vyzkoušeno na DM520. Build pro DM900/DM920 je ověřený proti stejné verzi
  enigma2, ale na boxu zatím vyzkoušený nebyl.

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
curl -fsSL https://raw.githubusercontent.com/Blacker91/serviceapp-dreamos/dreamos/installer.sh | sh
```
Nebo stáhni `.deb` z [Releases](https://github.com/Blacker91/exteplayer3-dreamos/releases) a spusť `dpkg -i *.deb`.

Když ArchivCZSK nabídne stažení novějšího exteplayer3, odpověz **Ne**, jinak by tento build přepsal.

## Změny proti skyjet18
Viz [patches](patches) a [CHANGELOG.md](CHANGELOG.md). Stručně: volby za adresou fungují
i s musl, oddělený zvuk a klíče DRM, zvuk MP2, zvuk živých streamů, rozpad obrazu
H.264 u TV záznamů.

## Kontakt
Chyby a návrhy: [Issues](https://github.com/Blacker91/exteplayer3-dreamos/issues) nebo e-mail
**dreamosserviceapp@gmail.com**.
