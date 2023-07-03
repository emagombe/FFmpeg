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
    --enable-parser=aac,wav,h264,mp3,mp4,ogg,mov,mkv,flac,mpeg4,vorbis,opus \
    --enable-demuxer=aac,wav,h264,mp3,mp4,ogg,mov,mkv,flac,mpeg4,vorbis,opus \
    --enable-decoder=aac,wav,h264,mp3,mp4,ogg,mov,mkv,flac,mpeg4,vorbis,opus \
    --enable-filters \
    --disable-avdevice \
    --enable-avcodec \
    --enable-avformat \
    --disable-symver \
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
    --disable-pthreads \
    --disable-devices \
    --disable-dxva2 \
    --disable-debug \
    --enable-hwaccels \
    --disable-parsers \
    --disable-indevs \
    --disable-outdevs \
    --disable-postproc \
    --disable-pixelutils \
    --disable-runtime-cpudetect
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
build_ffmpeg arm64-v8a 22
build_ffmpeg x86 22
build_ffmpeg x86_64 22