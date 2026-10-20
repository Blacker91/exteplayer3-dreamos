#!/bin/bash
# Build the .deb packages (one per architecture) after ./build.sh mipsel and
# ./build.sh arm. Each contains /usr/bin/exteplayer3 and
# /usr/lib/exteplayer3_deps/ffmpeg (the path ArchivCZSK uses).
#   ./package.sh [version]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$ROOT/.work}"
VER="${1:-$(sed -n 's/^## exteplayer3 \([^ ]*\).*/\1/p' "$ROOT/CHANGELOG.md" | head -n 1)}"
N=exteplayer3-dreamos
mkdir -p "$WORK/out"

for a in mipsel:mipsel arm:armhf; do
  SRC="$WORK/${a%%:*}/out" ARCH="${a##*:}" P="$WORK/pkg-$N-${a##*:}"
  for b in exteplayer3 ffmpeg; do
    [ -f "$SRC/$b" ] || { echo "missing $SRC/$b - run ./build.sh ${a%%:*}" >&2; exit 1; }
  done
  rm -rf "$P"; mkdir -p "$P/DEBIAN" "$P/usr/bin" "$P/usr/lib/exteplayer3_deps" "$P/usr/share/doc/$N"
  install -m 755 "$SRC/exteplayer3" "$P/usr/bin/exteplayer3"
  install -m 755 "$SRC/ffmpeg" "$P/usr/lib/exteplayer3_deps/ffmpeg"
  cp "$ROOT/CHANGELOG.md" "$P/usr/share/doc/$N/changelog"
  cat "$ROOT/LICENSE" "$ROOT"/licenses/* > "$P/usr/share/doc/$N/copyright"
  cat > "$P/DEBIAN/control" <<EOF
Package: $N
Version: $VER
Architecture: $ARCH
Maintainer: Blacker91
Installed-Size: $(du -sk "$P" --exclude=DEBIAN | cut -f1)
Provides: exteplayer3, ffmpeg-exteplayer3-dreamos
Conflicts: ffmpeg-exteplayer3-dreamos
Replaces: ffmpeg-exteplayer3-dreamos
Section: multimedia
Priority: optional
Homepage: https://github.com/Blacker91/exteplayer3-dreamos
Description: Static exteplayer3 and ffmpeg for DreamOS Dreamboxes
 exteplayer3 (skyjet18) with FFmpeg 6.1, OpenSSL 3 and libxml2, statically
 linked: HLS, DASH, CENC DRM keys, separate audio. ffmpeg is installed in
 /usr/lib/exteplayer3_deps for ArchivCZSK, the system ffmpeg is not touched.
EOF
  # The old ffmpeg-exteplayer3-dreamos package (up to 6.1-dreamos2) deletes
  # /usr/lib/exteplayer3_deps/ffmpeg in its postrm, which would remove the file
  # of this package when dpkg replaces it.
  cat > "$P/DEBIAN/preinst" <<'EOF'
#!/bin/sh
f="${DPKG_ADMINDIR:-/var/lib/dpkg}/info/ffmpeg-exteplayer3-dreamos.postrm"
[ -f "$f" ] && printf '#!/bin/sh\nexit 0\n' > "$f"
exit 0
EOF
  chmod 755 "$P/DEBIAN/preinst"
  dpkg-deb -Zgzip --root-owner-group -b "$P" "$WORK/out/${N}_${VER}_${ARCH}.deb" >/dev/null
  echo "$WORK/out/${N}_${VER}_${ARCH}.deb"
done
