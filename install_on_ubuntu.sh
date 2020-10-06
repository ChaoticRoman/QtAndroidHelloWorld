# Dependencies

set -ex

sudo apt update && sudo apt install -y \
    git qtcreator libclang-dev libstdc++6:i386 \
    libgcc1:i386 zlib1g:i386 libncurses5:i386 libsdl1.2debian:i386 \
    lib32z1 cmake ninja-build build-essential default-jre \
    openjdk-8-jdk-headless android-sdk android-sdk-platform-23 \
    libc6-i386

# Configure environment

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Prepare suitable directory              

topLevelAndroidDirectory=`realpath ~/.android`
rm -rf $topLevelAndroidDirectory
mkdir $topLevelAndroidDirectory
cd $topLevelAndroidDirectory

# Android SDK and NDK
# Courtesy: https://wiki.qt.io/Android#Installing_the_Android_SDK_and_NDK  

ndkVersion="r21d"
sdkBuildToolsVersion="28.0.3"
sdkApiLevelInt=29
sdkApiLevel=android-$sdkApiLevelInt

repository=https://dl.google.com/android/repository
toolsFile=sdk-tools-linux-4333796.zip
toolsFolder=android-sdk-tools
ndkFile=android-ndk-$ndkVersion-linux-x86_64.zip
ndkFolder=android-ndk-$ndkVersion

wget $repository/$toolsFile
unzip -q $toolsFile -d $toolsFolder

wget $repository/$ndkFile
unzip -q $ndkFile

rm $toolsFile
rm $ndkFile

cd $toolsFolder/tools/bin

echo "y" | ./sdkmanager "platform-tools" "build-tools;$sdkBuildToolsVersion"

for level in $(eval echo "{21..$sdkApiLevelInt}")
do
    echo "y" | ./sdkmanager "platforms;android-$level" 
done

# OpenSSL for Android
# Courtesy: https://proandroiddev.com/tutorial-compile-openssl-to-1-1-1-for-android-application-87137968fee

cd $topLevelAndroidDirectory
opensslVersion="1.1.1h"

wget https://www.openssl.org/source/openssl-$opensslVersion.tar.gz
tar xf openssl-$opensslVersion.tar.gz
rm openssl-$opensslVersion.tar.gz

export ANDROID_NDK_HOME=$topLevelAndroidDirectory/android-ndk-$ndkVersion
toolchains_path=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
CC=clang
PATH=$toolchains_path/bin:$PATH

cd openssl-$opensslVersion
for architecture in android-arm android-arm64 android-x86 android-x86_64
do
    ./Configure ${architecture} -D__ANDROID_API__=21 # 21 is the oldest API that Qt supports
    make
    OUTPUT_INCLUDE=$topLevelAndroidDirectory/openssl-$opensslVersion-build/include
    OUTPUT_LIB=$topLevelAndroidDirectory/openssl-$opensslVersion-build/lib/${architecture}
    mkdir -p $OUTPUT_INCLUDE
    mkdir -p $OUTPUT_LIB
    cp -RL include/openssl $OUTPUT_INCLUDE
    cp libcrypto.so $OUTPUT_LIB
    cp libcrypto.a $OUTPUT_LIB
    cp libssl.so $OUTPUT_LIB
    cp libssl.a $OUTPUT_LIB
    make clean
done
cp -RL include/openssl $OUTPUT_INCLUDE
cd $topLevelAndroidDirectory

# Build Qt
# Courtesy: https://wiki.qt.io/Android#Building_Qt

cd $topLevelAndroidDirectory
git clone git://code.qt.io/qt/qt5.git qt5
cd qt5
perl init-repository
git checkout v5.15.1
git submodule update --init --recursive

echo y | \
    OPENSSL_LIBS="-L$topLevelAndroidDirectory/openssl-$opensslVersion-build/lib/ -lssl -lcrypto" \
    ./configure \
    -I$topLevelAndroidDirectory/openssl-$opensslVersion-build/include \
    -xplatform android-clang --disable-rpath -nomake tests -nomake examples \
    -skip qttranslations -skip qtserialport -no-warnings-are-errors \
    -android-ndk $ANDROID_NDK_HOME \
    -android-sdk $topLevelAndroidDirectory/$toolsFolder \
    -android-ndk-host linux-x86_64 -opensource

make -j 12
sudo make install

