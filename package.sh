#!/bin/bash
# Build the universal .deb packages (mipsel + armhf) after
# ./build.sh mipsel and ./build.sh arm. postinst installs the matching binary.
#   ./package.sh [exteplayer3-version] [ffmpeg-version]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$ROOT/.work}"
EP3_VER="${1:-$(sed -n 's/^## exteplayer3 \([^ ]*\).*/\1/p' "$ROOT/CHANGELOG.md" | head -n 1)}"
FF_VER="${2:-$(sed -n 's/^## ffmpeg \([^ ]*\).*/\1/p' "$ROOT/CHANGELOG.md" | head -n 1)}"
mkdir -p "$WORK/out"

# make_deb <package> <version> <binary> <install-dir> <description...>
make_deb() {
  local N=$1 V=$2 BIN=$3 DEST=$4; shift 4
  local P="$WORK/pkg-$N" SH="usr/share/$N"
  rm -rf "$P"; mkdir -p "$P/DEBIAN" "$P/$SH/mipsel" "$P/$SH/armhf" "$P/usr/share/doc/$N"
  install -m 755 "$WORK/mipsel/out/$BIN" "$P/$SH/mipsel/$BIN"
  install -m 755 "$WORK/arm/out/$BIN" "$P/$SH/armhf/$BIN"
  cp "$ROOT/CHANGELOG.md" "$P/usr/share/doc/$N/changelog"
  cat "$ROOT/LICENSE" "$ROOT"/licenses/* > "$P/usr/share/doc/$N/copyright"
  { echo "Package: $N"; echo "Version: $V"; echo "Architecture: all"; echo "Maintainer: Blacker91"
    echo "Installed-Size: $(du -sk "$P" --exclude=DEBIAN | cut -f1)"
    [ "$N" = exteplayer3-dreamos ] && echo "Provides: exteplayer3"
    echo "Section: multimedia"; echo "Priority: optional"
    echo "Homepage: https://github.com/Blacker91/exteplayer3-dreamos"
    printf 'Description: %s\n' "$1"; shift
    for l in "$@"; do echo " $l"; done; } > "$P/DEBIAN/control"
  cat > "$P/DEBIAN/postinst" <<EOF
#!/bin/sh
set -e
R="\${DPKG_ROOT:-}"
A="\$(dpkg --print-architecture 2>/dev/null || true)"
case "\$A" in
  mipsel|armhf) ;;
  *) case "\$(uname -m)" in mips*) A=mipsel ;; arm*) A=armhf ;; *) A="" ;; esac ;;
esac
[ -n "\$A" ] && [ -f "\$R/$SH/\$A/$BIN" ] || { echo "$N: unsupported box (\$(uname -m))" >&2; exit 1; }
mkdir -p "\$R$DEST"
mv -f "\$R/$SH/\$A/$BIN" "\$R$DEST/$BIN"
rm -rf "\$R/$SH/mipsel" "\$R/$SH/armhf"
echo "$N installed (\$A)"
EOF
  cat > "$P/DEBIAN/postrm" <<EOF
#!/bin/sh
case "\$1" in
  remove|purge)
    rm -f "\${DPKG_ROOT:-}$DEST/$BIN"
    rmdir "\${DPKG_ROOT:-}$DEST" 2>/dev/null
    rm -rf "\${DPKG_ROOT:-}/$SH" ;;
esac
exit 0
EOF
  chmod 755 "$P/DEBIAN/postinst" "$P/DEBIAN/postrm"
  dpkg-deb -Zgzip --root-owner-group -b "$P" "$WORK/out/${N}_${V}_all.deb" >/dev/null
  echo "$WORK/out/${N}_${V}_all.deb"
}

make_deb exteplayer3-dreamos "$EP3_VER" exteplayer3 /usr/bin \
  "Static exteplayer3 for DreamOS Dreamboxes" \
  "exteplayer3 (skyjet18) with FFmpeg 6.1, OpenSSL 3 and libxml2, statically" \
  "linked: HLS, DASH, CENC DRM keys, separate audio. For DM520/DM525 (mipsel)" \
  "and DM900/DM920 (armhf)."
make_deb ffmpeg-exteplayer3-dreamos "$FF_VER" ffmpeg /usr/lib/exteplayer3_deps \
  "Static ffmpeg for ArchivCZSK on DreamOS" \
  "ffmpeg 6.1 (skyjet18) in /usr/lib/exteplayer3_deps, where ArchivCZSK looks" \
  "for it. The system ffmpeg is not touched."
