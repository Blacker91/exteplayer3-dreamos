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

## Balíček
Jeden balíček `exteplayer3-dreamos`, zvlášť pro mipsel a armhf:
- `/usr/bin/exteplayer3`
- `/usr/lib/exteplayer3_deps/ffmpeg` (pro ArchivCZSK, systémový ffmpeg zůstává)

Nahrazuje dřívější samostatný balíček `ffmpeg-exteplayer3-dreamos`, ten se při instalaci sám odebere.

## Instalace
Spolu se ServiceApp (doporučeno), na boxu:
```sh
curl -fsSL https://raw.githubusercontent.com/Blacker91/serviceapp-dreamos/dreamos/installer.sh | sh
```
Nebo stáhni z [Releases](https://github.com/Blacker91/exteplayer3-dreamos/releases) `.deb` pro svůj box
(`_mipsel` pro DM520/DM525, `_armhf` pro DM900/DM920) a spusť `dpkg -i exteplayer3-dreamos_*.deb`.

Když ArchivCZSK nabídne stažení novějšího exteplayer3, odpověz **Ne**, jinak by tento build přepsal.

## Změny proti skyjet18
Viz [patches](patches) a [CHANGELOG.md](CHANGELOG.md). Stručně: volby za adresou fungují
i s musl, oddělený zvuk a klíče DRM, zvuk MP2, zvuk živých streamů, rozpad obrazu
H.264 u TV záznamů, rozpad obrazu 4K VP9 (YouTube) na DM900.

## Kontakt
Chyby a návrhy: [Issues](https://github.com/Blacker91/exteplayer3-dreamos/issues) nebo e-mail
**dreamosserviceapp@gmail.com**.
