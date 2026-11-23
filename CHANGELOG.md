# Changelog

## exteplayer3 187-dreamos3
- DreamOS fix (patches/0002): after switching the audio track of a film the
  sound could stutter until the next seek, reproducible with an AC-3 44.1 kHz
  track (passed through to a soundbar/receiver) after a TrueHD track (PCM
  48 kHz), also in 185 and in the upstream build. The seek of the switch
  clears both decoders, the picture runs on and the audio decoder starts for
  the new codec only afterwards, into the running clock. On Dreambox one more
  seek to the position after the switch starts both decoders together, as a
  manual seek did.

## exteplayer3 187-dreamos2
- Based on skyjet18 exteplayer3 187 (1df1fdc) and FFmpeg 6.1-patched
  (ca1f67f, HLS subtitle segments loaded on demand).
- Graphic subtitles (PGS, DVB, XSUB) are now written with the PNG encoder of
  FFmpeg upstream, which the static build already has; our PNG patch is gone.
- One new DreamOS fix (patches/0001): some films from Plex (HTTP) had no
  picture from the start, only after a seek. Over HTTP FFmpeg can take the
  start time from an audio stream (2 ms) while the first video keyframe is at
  0 ms; exteplayer3 dropped that keyframe as "before the start", the decoder
  got the HEVC parameter sets with the next frame, which it cannot decode,
  and never started. The first keyframe up to 1 s before the start time is
  now played at 0. (Also in 185.)
- From skyjet18 (186-187), among others:
  - live start hold (Tvheadend) is on by default on Dreambox only;
  - DTS: lone core frames padded on all boxes except Dreambox, PTS dejitter;
  - HLS: DEFAULT=YES audio rendition, failing segments retried, gzip
    playlists; DASH audio switch from the playback position;
  - closed captions of the video stream as a subtitle track;
  - CENC keys per KID (--key), --start <seconds>, dual mono channel
    selection, optional audio transcoding (-Z/-X/-Y/-E);
  - raw AC-3/E-AC-3/DTS/TrueHD/AC-4/MKA/M4B/AIFF/APE files open directly;
  - clean stop on SIGINT/SIGTERM/SIGHUP, parent death or closed command pipe;
  - many fixes in the H.264/H.265/MPEG-2/VC-1/AAC/LPCM writers, buffering
    and HTTP handling (stalled reads end instead of hanging).
- Build: the argv wrapper for musl getopt() is gone (187 uses getopt_long,
  which reorders options in musl too); dlsym() is a stub in the static
  binary (the MIPS build crashed at startup in it). AUDIO_GET_PTS now has its real value (it was mapped to
  VIDEO_GET_PTS, so the position of audio-only playback could not be read);
  OpenSSL looks for CA certificates in /etc/ssl like the image.

## exteplayer3 185-dreamos2
- skyjet18 re-released 185 (3e87bef): the player now reports version 185
  (185-dreamos1 still reported 184, so ArchivCZSK and ServiceApp showed 184).
- Graphic subtitles PNG writer reworked: exteplayer3png.so is still used when
  it can be loaded, the built-in writer is the fallback (same output here).

## exteplayer3 185-dreamos1
- Based on skyjet18 exteplayer3 185 and the matching FFmpeg 6.1-patched:
  - skyjet merged all DreamOS fixes (musl fileno, 1024 iovecs, in-band
    SPS/PPS, MP2 audio type, live start hold and audio watch, VP9 32 kB PES
    on Dreambox); they are no longer separate patches here.
  - Audio track switching keeps the position and timestamps (HLS, DASH,
    mixed TS), transient network errors are retried for 10 s instead of
    ending playback, busy decoder devices are retried, adaptive HLS/DASH
    quality selection, PES PTS/DTS, optional PCM export (-K) and more
    backports from VTi.
- Remaining DreamOS patch: built-in PNG writer for graphic subtitles.

## exteplayer3 184-dreamos3
- Graphic subtitles (PGS from Blu-ray rips, DVB, XSUB): built-in PNG writer.
  The static build could not load exteplayer3png.so, so they never worked.

## exteplayer3 184-dreamos2
- Live streams (Tvheadend): faster zapping, the start hold is the measured
  audio gap + 400 ms (was + 800 ms) and at most 3 s (was 5 s). The audio
  watch fixes it during playback if needed. EP3_LIVE_SYNC_MARGIN=ms sets it.

## exteplayer3 184-dreamos1
- Based on skyjet18 exteplayer3 184:
  - H.264: all SPS/PPS from avcC are passed to the decoder, not only the first
    (live DASH services with a second PPS: picture broke into blocks at
    flashes and fades on Broadcom boxes).
  - X-DRM-Api-Level header for ArchivCZSK is no longer glued to headers
    passed with -h.
- All DreamOS patches unchanged.

## exteplayer3 183-dreamos11
- Live streams (Tvheadend): sometimes no sound after switching channels. The
  audio buffer is now watched during playback too; when audio would come too
  late, the picture is held briefly (about 1 s) until audio is buffered again.
  EP3_LIVE_SYNC_WATCH=0 disables it.

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
