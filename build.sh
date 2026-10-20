#!/bin/bash
# Static exteplayer3 + ffmpeg for Dreamboxes with DreamOS 2.5
#   ./build.sh mipsel      DM520 / DM525
#   ./build.sh arm         DM900 / DM920
#   ./build.sh arm ffmpeg exteplayer3      only some steps
#
# Static musl build (Zig), so nothing depends on the libraries of the image.
# Host (Debian/Ubuntu): git make cmake pkg-config python3-pip file
#   pip install ziglang==0.17.0
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
ARCH="${1:-mipsel}"; shift || true
case "$ARCH" in
  mipsel) ZIG_TARGET=mipsel-linux-musleabihf; ZIG_CPU=mips32;     OSSL_TARGET=linux-mips32; FF_ARCH=mips; CMAKE_PROC=mips ;;
  arm)    ZIG_TARGET=arm-linux-musleabihf;    ZIG_CPU=cortex_a15; OSSL_TARGET=linux-armv4;  FF_ARCH=arm;  CMAKE_PROC=arm ;;
  *) echo "usage: $0 mipsel|arm [step...]" >&2; exit 1 ;;
esac
W="${WORK:-$ROOT/.work}/$ARCH"
TC="$W/tc"; SRC="$W/src"; PREFIX="$W/prefix"; OUT="$W/out"
JOBS="${JOBS:-$(nproc)}"
mkdir -p "$TC" "$SRC" "$PREFIX" "$OUT"

# exact sources, see SOURCES.md
ZLIB_TAG=v1.3.1
OPENSSL_TAG=openssl-3.5.4
LIBXML2_TAG=v2.13.8
FFMPEG_REPO=https://github.com/skyjet18/FFmpeg.git
FFMPEG_BRANCH=release/6.1-patched
FFMPEG_REV=ea4d5204424fa53de15dbc2781424af7223b3bb9
EP3_REPO=https://github.com/skyjet18/exteplayer3.git
EP3_REV=00aaa894db78a5c71c325d7cab1ea9ba5855024d

EP3_SRCS="main/exteplayer.c container/container.c container/container_ffmpeg.c manager/manager.c manager/audio.c
 manager/video.c manager/subtitle.c output/output_subtitle.c output/output.c output/writer/common/pes.c
 output/writer/common/misc.c output/writer/common/writer.c output/linuxdvb_buffering.c output/graphic_subtitle.c
 output/linuxdvb_mipsel.c output/writer/mipsel/writer.c output/writer/mipsel/aac.c output/writer/mipsel/ac3.c
 output/writer/mipsel/bcma.c output/writer/mipsel/mp3.c output/writer/mipsel/pcm.c output/writer/mipsel/lpcm.c
 output/writer/mipsel/dts.c output/writer/mipsel/amr.c output/writer/mipsel/h265.c output/writer/mipsel/h264.c
 output/writer/mipsel/mjpeg.c output/writer/mipsel/mpeg2.c output/writer/mipsel/mpeg4.c output/writer/mipsel/divx3.c
 output/writer/mipsel/vp.c output/writer/mipsel/wmv.c output/writer/mipsel/vc1.c playback/playback.c tools/debug.c
 tools/strbuffer.c external/ffmpeg/src/bitstream.c external/ffmpeg/src/latmenc.c external/ffmpeg/src/mpeg4audio.c
 external/ffmpeg/src/xiph.c external/flv2mpeg4/src/m4vencode.c external/flv2mpeg4/src/flvdecoder.c
 external/flv2mpeg4/src/dcprediction.c external/flv2mpeg4/src/flv2mpeg4.c external/plugins/src/png.c"

step_toolchain() {
  local zig
  zig="$(python3 -c 'import ziglang,os;print(os.path.join(os.path.dirname(ziglang.__file__),"zig"))')"
  printf '#!/bin/sh\nexec %s cc -target %s -mcpu=%s "$@"\n'  "$zig" "$ZIG_TARGET" "$ZIG_CPU" > "$TC/cc"
  printf '#!/bin/sh\nexec %s c++ -target %s -mcpu=%s "$@"\n' "$zig" "$ZIG_TARGET" "$ZIG_CPU" > "$TC/c++"
  for t in ar ranlib; do printf '#!/bin/sh\nexec %s %s "$@"\n' "$zig" "$t" > "$TC/$t"; done
  # binaries are stripped at link time; this strip only copies ("strip -o out in" in FFmpeg's make)
  cat > "$TC/strip" <<'EOF'
#!/bin/sh
out=""; in=""
while [ $# -gt 0 ]; do case "$1" in -o) out="$2"; shift 2 ;; -*) shift ;; *) in="$1"; shift ;; esac; done
[ -n "$out" ] && [ -n "$in" ] && cp -f "$in" "$out"
exit 0
EOF
  chmod +x "$TC"/*
}

env_cross() {
  export CC="$TC/cc" CXX="$TC/c++" AR="$TC/ar" RANLIB="$TC/ranlib" STRIP="$TC/strip"
  export CFLAGS="-Os -ffunction-sections -fdata-sections" LDFLAGS="-static"
  export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
}

checkout() { # dir repo branch-or-tag [commit]
  [ -d "$SRC/$1" ] || git -c advice.detachedHead=false clone -q --depth 50 -b "$3" "$2" "$SRC/$1"
  [ -z "${4:-}" ] || git -c advice.detachedHead=false -C "$SRC/$1" checkout -q "$4"
}

step_fetch() {
  checkout zlib    https://github.com/madler/zlib.git    "$ZLIB_TAG"
  checkout openssl https://github.com/openssl/openssl.git "$OPENSSL_TAG"
  checkout libxml2 https://github.com/GNOME/libxml2.git  "$LIBXML2_TAG"
  checkout ffmpeg  "$FFMPEG_REPO" "$FFMPEG_BRANCH" "$FFMPEG_REV"
  if [ ! -d "$SRC/exteplayer3" ]; then
    git clone -q "$EP3_REPO" "$SRC/exteplayer3"
    git -c advice.detachedHead=false -C "$SRC/exteplayer3" checkout -q "$EP3_REV"
    for p in "$ROOT"/patches/*.patch; do
      patch -d "$SRC/exteplayer3" -p1 -s < "$p" || { echo "patch failed: $p" >&2; exit 1; }
    done
  fi
}

step_zlib() {
  env_cross; cd "$SRC/zlib"
  make distclean >/dev/null 2>&1 || true
  CHOST=$ARCH ./configure --static --prefix="$PREFIX" >/dev/null
  make -j"$JOBS" libz.a >/dev/null && make install >/dev/null
}

step_openssl() {
  env_cross; cd "$SRC/openssl"
  make distclean >/dev/null 2>&1 || true
  ./Configure $OSSL_TARGET no-shared no-asm no-tests no-docs no-apps no-module no-engine \
      no-dso no-async no-afalgeng no-legacy --prefix="$PREFIX" --libdir=lib \
      -Os -ffunction-sections -fdata-sections >/dev/null
  make -j"$JOBS" build_libs >/dev/null
  make install_dev >/dev/null
}

step_libxml2() {
  env_cross; rm -rf "$SRC/libxml2/build"; mkdir -p "$SRC/libxml2/build"; cd "$SRC/libxml2/build"
  cmake .. -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=$CMAKE_PROC \
    -DCMAKE_C_COMPILER="$CC" -DCMAKE_AR="$AR" -DCMAKE_RANLIB="$RANLIB" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF \
    -DLIBXML2_WITH_PYTHON=OFF -DLIBXML2_WITH_ICONV=OFF -DLIBXML2_WITH_ICU=OFF -DLIBXML2_WITH_LZMA=OFF \
    -DLIBXML2_WITH_ZLIB=OFF -DLIBXML2_WITH_PROGRAMS=OFF -DLIBXML2_WITH_TESTS=OFF \
    -DLIBXML2_WITH_HTTP=OFF -DLIBXML2_WITH_FTP=OFF -DLIBXML2_WITH_MODULES=OFF -DLIBXML2_WITH_THREADS=ON >/dev/null
  make -j"$JOBS" >/dev/null && make install >/dev/null
}

step_ffmpeg() {
  env_cross; cd "$SRC/ffmpeg"
  make distclean >/dev/null 2>&1 || true
  local demux="hls,dash,mpegts,mpegtsraw,mov,matroska,webm_dash_manifest,flv,live_flv,aac,ac3,eac3,mp3,mpegps,mpegvideo,h264,hevc,m4v,avi,asf,ogg,wav,flac,webvtt,srt,ass,data,concat,rtsp,sdp,rtp,mpjpeg,image2,mjpeg,png_pipe"
  local proto="file,pipe,data,http,https,httpproxy,tcp,udp,tls,hls,crypto,rtmp,rtmps,rtmpt,rtmpts,rtp,srtp,cache,concat,subfile"
  local parse="h264,hevc,aac,aac_latm,ac3,mpegaudio,mpeg4video,mpegvideo,vc1,dca,opus,vorbis,flac,vp8,vp9,av1,dvbsub,dvd_nav,dvdsub,mjpeg,png"
  local bsf="h264_mp4toannexb,hevc_mp4toannexb,aac_adtstoasc,mpeg4_unpack_bframes,extract_extradata,vp9_superframe,dump_extradata,null"
  local dec="aac,aac_fixed,aac_latm,ac3,ac3_fixed,eac3,mp1,mp2,mp3,mp1float,mp2float,mp3float,opus,vorbis,flac,alac,dca,truehd,mlp,wmav1,wmav2,wmapro,amrnb,amrwb,pcm_s16le,pcm_s16be,pcm_s24le,pcm_s24be,pcm_s32le,pcm_f32le,pcm_u8,pcm_alaw,pcm_mulaw,pcm_bluray,pcm_dvd,dvbsub,dvdsub,pgssub,subrip,srt,ass,ssa,webvtt,mov_text,text,png,mjpeg,h264,hevc,mpeg2video,mpeg4"
  # ArchivCZSK checks for --enable-libxml2, the dash demuxer and this rpath in "ffmpeg -version"
  ./configure \
    --prefix="$PREFIX" --enable-cross-compile --target-os=linux --arch=$FF_ARCH \
    --cc="$CC" --cxx="$CXX" --ar="$AR" --ranlib="$RANLIB" --strip="$STRIP" --nm=nm \
    --pkg-config=pkg-config --pkg-config-flags=--static \
    --extra-cflags="-I$PREFIX/include $CFLAGS" \
    --extra-ldflags="-L$PREFIX/lib -static -Wl,--gc-sections -Wl,--strip-all -Wl,-rpath,/usr/lib/exteplayer3_deps" \
    --enable-static --disable-shared --disable-doc --disable-debug \
    --disable-programs --enable-ffmpeg --enable-ffprobe \
    --disable-autodetect --disable-asm --disable-runtime-cpudetect --enable-pthreads \
    --disable-avdevice --enable-avfilter --disable-postproc \
    --enable-filter=null,anull,copy,acopy,format,aformat,scale,aresample,setpts,asetpts,trim,atrim,fps,setsar,setdar \
    --enable-network --enable-openssl --enable-libxml2 --enable-zlib --enable-version3 \
    --disable-everything \
    --enable-demuxer="$demux" --enable-demuxer=dash --enable-protocol="$proto" --enable-parser="$parse" \
    --enable-bsf="$bsf" --enable-decoder="$dec" \
    --enable-muxer=mpegts,adts,null,matroska,mp4,mov,h264,hevc,ac3,eac3,mp3,data \
    --enable-encoder=png,aac,ac3,mpeg2video \
    > "$W/ffmpeg-configure.log" 2>&1 || { tail -30 "$W/ffmpeg-configure.log"; return 1; }
  make -j"$JOBS" >/dev/null 2> "$W/ffmpeg-build.log" || { grep -m20 error "$W/ffmpeg-build.log"; return 1; }
  make install >/dev/null
  cp -f ffmpeg "$OUT/ffmpeg"
  file "$OUT/ffmpeg"
}

step_exteplayer3() {
  env_cross; cd "$SRC/exteplayer3"
  local b="$W/build-exteplayer3"; rm -rf "$b"; mkdir -p "$b"
  cat > "$b/config.h" <<'EOF'
#define PACKAGE_NAME "exteplayer3"
#define PACKAGE_VERSION "183-static"
#define VERSION "183-static"
#define HAVE_FLV2MPEG4_CONVERTER 1
#ifndef _FILE_OFFSET_BITS
#define _FILE_OFFSET_BITS 64
#endif
#define _LARGEFILE64_SOURCE 1
#define _LARGEFILE_SOURCE 1
#ifndef AUDIO_GET_PTS
#define AUDIO_GET_PTS VIDEO_GET_PTS
#endif
EOF
  local objs=() f o extra optstr
  # musl getopt does not reorder argv, main() is wrapped (extra/argv_permute.c)
  optstr=$(grep -o 'getopt(argc, argv, "[^"]*")' main/exteplayer.c | sed 's/.*"\(.*\)".*/\1/')
  [ -n "$optstr" ] || { echo "cannot find getopt option string" >&2; return 1; }
  $CC $CFLAGS -DEP3_OPTSTRING="\"$optstr\"" -c "$ROOT/extra/argv_permute.c" -o "$b/argv_permute.o"
  objs+=("$b/argv_permute.o")
  for f in $EP3_SRCS; do
    o="$b/$(echo "$f" | tr '/' '_' | sed 's/\.c$/.o/')"; objs+=("$o")
    extra=""; [ "$f" = main/exteplayer.c ] && extra="-Dmain=ep3_main"
    echo "$CC $CFLAGS $extra -DHAVE_CONFIG_H -Dff_mpeg4audio_channels=ep3_mpeg4audio_channels -include $b/config.h -I$b -Iinclude -Iexternal -Iexternal/flv2mpeg4 -I$PREFIX/include -Wall -Wno-unused-parameter -Wno-unused-but-set-variable -c $f -o $o"
  done > "$b/compile.cmds"
  xargs -P "$JOBS" -I{} sh -c '{}' < "$b/compile.cmds" 2> "$b/compile.log" || { grep -m30 -B2 -A3 error "$b/compile.log"; return 1; }
  $CC -static -Wl,--gc-sections -Wl,--strip-all -o "$OUT/exteplayer3" "${objs[@]}" \
      -L"$PREFIX/lib" -lavformat -lavcodec -lswresample -lswscale -lavutil -lxml2 -lssl -lcrypto -lz -lpthread -lm \
      2> "$b/link.log" || { grep -m30 -iE 'error|undefined' "$b/link.log"; return 1; }
  file "$OUT/exteplayer3"
}

STEPS=("$@"); [ ${#STEPS[@]} -eq 0 ] && STEPS=(toolchain fetch zlib openssl libxml2 ffmpeg exteplayer3)
for s in "${STEPS[@]}"; do echo ">>> $ARCH: $s"; "step_$s"; done
