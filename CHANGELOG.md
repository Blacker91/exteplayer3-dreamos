# Changelog

## exteplayer3 183-dreamos10
- VP9 on Dreambox (4K YouTube on DM900): picture breakup. Large frames are
  now sent in 32 kB PES chunks like on other Broadcom boxes.

## exteplayer3 183-dreamos9
- One package `exteplayer3-dreamos` with exteplayer3 and ffmpeg
  (`/usr/lib/exteplayer3_deps/ffmpeg`), like the skyjet18 package.
  It replaces `ffmpeg-exteplayer3-dreamos`.
- Separate packages for mipsel and armhf. Files are no longer moved by
  postinst, so dpkg knows all files of the package.

## exteplayer3 183-dreamos8
- H.264: ignore corrupt NAL lengths when looking for in-band SPS/PPS.

## exteplayer3 183-dreamos7
- Live streams (e.g. Tvheadend): sound. Audio trails video in live TS and
  was dropped by the Dreambox, the output is held at start until audio is buffered.

## exteplayer3 183-dreamos6
- MP2 audio (satellite/DVB-T channels) sent as MPEG instead of MP3.

## exteplayer3 183-dreamos5
- H.264: picture breakup with some TV recordings (stream SPS/PPS were
  overridden by different ones from the MP4 header).

## exteplayer3 183-dreamos4
- H.264/H.265: frames with many slices are no longer cut off.

## exteplayer3 183-dreamos3
- Options after the URL were ignored (musl getopt): separate audio (YouTube),
  DRM keys, headers.

## exteplayer3 183-dreamos2
- exteplayer3 and ffmpeg as separate packages.

## ffmpeg 6.1-dreamos2
- Separate package, installed to `/usr/lib/exteplayer3_deps/ffmpeg` for ArchivCZSK.
