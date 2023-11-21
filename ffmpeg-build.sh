#!/bin/bash
if [ -z "$ANDROID_NDK_FFMPEG" ]; then
  echo "Please set ANDROID_NDK_FFMPEG to the Android NDK folder"
  exit 1
fi

#Change to your local machines architecture
HOST_OS_ARCH=windows-x86_64

function configure_ffmpeg {

  ABI=$1
  PLATFORM_VERSION=$2
  TOOLCHAIN_PATH=$ANDROID_NDK_FFMPEG/toolchains/llvm/prebuilt/${HOST_OS_ARCH}/bin
  local STRIP_COMMAND

  # Determine the architecture specific options to use
  case ${ABI} in
  armeabi-v7a)
    TOOLCHAIN_PREFIX=armv7a-linux-androideabi
    STRIP_COMMAND=arm-linux-androideabi-strip
    ARCH=armv7-a
    EXTRA_CONFIG="--enable-neon --enable-asm"
    ;;
  arm64-v8a)
    TOOLCHAIN_PREFIX=aarch64-linux-android
    ARCH=aarch64
    EXTRA_CONFIG="--enable-neon --enable-asm"
    ;;
  x86)
    TOOLCHAIN_PREFIX=i686-linux-android
    ARCH=x86
    EXTRA_CONFIG="--disable-asm"
    ;;
  x86_64)
    TOOLCHAIN_PREFIX=x86_64-linux-android
    ARCH=x86_64
    EXTRA_CONFIG="--disable-asm"
    ;;
  esac

  if [ -z ${STRIP_COMMAND} ]; then
    STRIP_COMMAND=${TOOLCHAIN_PREFIX}-strip
  fi

  echo "Configuring FFmpeg build for ${ABI}"
  echo "Toolchain path ${TOOLCHAIN_PATH}"
  echo "Command prefix ${TOOLCHAIN_PREFIX}"
  echo "Strip command ${STRIP_COMMAND}"

  #./configure --prefix=build/${ABI} --target-os=android --arch=${ARCH} --enable-cross-compile --cc=${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}${PLATFORM_VERSION}-clang --strip=${TOOLCHAIN_PATH}/${STRIP_COMMAND} --enable-small --disable-programs --disable-doc --enable-shared --disable-static ${EXTRA_CONFIG} --disable-everything --enable-protocols --enable-decoder=ALL --enable-demuxer=ALL
  ./configure \
    --prefix=build/${ABI} \
    --target-os=android \
    --arch=${ARCH} \
    --enable-cross-compile \
    --cc=${TOOLCHAIN_PATH}/${TOOLCHAIN_PREFIX}${PLATFORM_VERSION}-clang \
    --strip=${TOOLCHAIN_PATH}/${STRIP_COMMAND} \
    --enable-small \
    --disable-programs \
    --disable-doc \
    --enable-shared \
    --disable-static \
    ${EXTRA_CONFIG} \
    --disable-everything \
    --enable-parser=aac,mpegaudio,gsm,opus,flac \
    --enable-demuxer=flac,tak,dsf,iff,mpc,mpc8,wav,flv,mp3,mov,asf,gsm,aiff,ape,aac,ogg,tta,pcm_s8,pcm_u8,pcm_s16be,pcm_s16le,pcm_u16be,pcm_u16le,pcm_u16be,pcm_u24be,pcm_u24le,pcm_s24be,pcm_s24le,pcm_u32be,pcm_u32le,pcm_s32be,pcm_s32le,pcm_f32be,pcm_f32le,pcm_f64be,pcm_f64le,pcm_alaw,pcm_mulaw \
    --enable-decoder=aac,mp3float,mp2float,mp3on4float,mp3adufloat,vorbis,wmav1,wmav2,alac,mace3,mace6,wmapro,wmalossless,ape,tta,flac,opus,tak,pcm_s8,pcm_s8_planar,pcm_s16be,pcm_s16le,pcm_u16be,pcm_u16le,pcm_s16be_planar,pcm_s16le_planar,pcm_f64le,pcm_f64be,pcm_s24be,pcm_s24daud,pcm_s24le,pcm_s24le_planar,pcm_u24be,pcm_u24le,pcm_s32be,pcm_s32le,pcm_u32be,pcm_u32le,pcm_f32be,pcm_f32le,pcm_s32le_planar,pcm_alaw,pcm_mulaw,adpcm_ms,adpcm_g726,gsm,gsm_ms,adpcm_ima_qt,adpcm_4xm,adpcm_adx,adpcm_ct,adpcm_ea,adpcm_ea_maxis_xa,adpcm_ea_r1,adpcm_ea_r2,adpcm_ea_r3,adpcm_ea_xas,adpcm_ima_amv,adpcm_ima_dk3,adpcm_ima_dk4,adpcm_ima_ea_eacs,adpcm_ima_ea_sead,adpcm_ima_iss,adpcm_ima_smjpeg,adpcm_ima_wav,adpcm_ima_ws,adpcm_swf,adpcm_xa,adpcm_yamaha,pcm_zork,pcm_bluray,pcm_lxf,pcm_dvd \
    --enable-protocol=file \
    --enable-protocol=concat \
    --enable-libvpx \
    --disable-avdevice \
    --enable-avcodec \
    --enable-avformat \
    --enable-symver \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-network \
    --disable-iconv \
    --disable-encoders \
    --disable-muxers \
    --disable-filters \
    --enable-protocols \
    --disable-swscale \
    --disable-avfilter \
    --disable-vaapi \
    --disable-vdpau \
    --enable-pthreads \
    --disable-devices \
    --disable-dxva2 \
    --disable-debug \
    --enable-hwaccels \
    --enable-parsers \
    --disable-indevs \
    --disable-outdevs \
    --disable-postproc \
    --disable-pixelutils \
    --enable-runtime-cpudetect
  return $?
}

function build_ffmpeg {

  configure_ffmpeg $1 $2

  if [ $? -eq 0 ]
  then
          make clean
          make -j12
          make install
  else
          echo "FFmpeg configuration failed, please check the error log."
  fi
}

build_ffmpeg armeabi-v7a 22
cp ./build/armeabi-v7a/lib/* F:\\ANDROID\\PROJECTS\\beatlevelsplayer\\app\\libs\\armeabi-v7a

build_ffmpeg arm64-v8a 22
cp ./build/arm64-v8a/lib/* F:\\ANDROID\\PROJECTS\\beatlevelsplayer\\app\\libs\\arm64-v8a

build_ffmpeg x86 22
cp ./build/x86/lib/* F:\\ANDROID\\PROJECTS\\beatlevelsplayer\\app\\libs\\x86

build_ffmpeg x86_64 22
cp ./build/x86_64/lib/* F:\\ANDROID\\PROJECTS\\beatlevelsplayer\\app\\libs\\x86_64
