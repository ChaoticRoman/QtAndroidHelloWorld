# Qt for Android Hello World

## Dependencies installation

### Ubuntu 20.04 LTS

Android development is space consuming. 45 GB of VM storage was enough
for minimal Ubuntu installation. You have been warned!

#### Installing dependencies

```bash
sudo apt install git qtcreator libclang-dev libstdc++6:i386 \
    libgcc1:i386 zlib1g:i386 libncurses5:i386 libsdl1.2debian:i386 \
    lib32z1 cmake ninja-build build-essential default-jre \
    openjdk-8-jdk-headless android-sdk android-sdk-platform-23 \
    libc6-i386
```

#### Prepare directory for Android toolkit and libraries

Keep your Android development stuff in a convenient location (modify
following steps if you would choose different one). Create this
as a normal user.

```bash
topLevelAndroidDirectory=`realpath ~/.android`
mkdir $topLevelAndroidDirectory
cd $topLevelAndroidDirectory
```

#### Configure environment

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin
```

#### Android SDK and NDK

```bash
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

echo "y" | ./sdkmanager "platforms;$sdkApiLevel" "platform-tools" "build-tools;$sdkBuildToolsVersion"
```

Inspired by [Installing the Android SDK and NDK][SDK NDK], the "Scripted installation
on Linux section" (notice that bash script shall be run as a user).

[SDK NDK]: https://wiki.qt.io/Android#Installing_the_Android_SDK_and_NDK

#### OpenSSL for Qt for Android

```bash
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
    ./Configure ${architecture} -D__ANDROID_API__=$sdkApiLevelInt
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
```

Inspired by [this tutorial](https://proandroiddev.com/tutorial-compile-openssl-to-1-1-1-for-android-application-87137968fee).

#### Qt for Android

```bash
cd $topLevelAndroidDirectory
git clone git://code.qt.io/qt/qt5.git qt5
cd qt5
perl init-repository
git checkout v5.15.1
git submodule update --init --recursive

OPENSSL_LIBS="-L$topLevelAndroidDirectory/openssl-$opensslVersion-build/lib/ -lssl -lcrypto" \
    ./configure \
    -I$topLevelAndroidDirectory/openssl-$opensslVersion-build/include \
    -xplatform android-clang --disable-rpath -nomake tests -nomake examples \
    -skip qttranslations -skip qtserialport -no-warnings-are-errors \
    -android-ndk $ANDROID_NDK_HOME \
    -android-sdk $topLevelAndroidDirectory/$toolsFolder \
    -android-ndk-host linux-x86_64 

make -j 12
sudo make install
```

Inspired by [this page on Qt wiki](https://wiki.qt.io/Android#Building_Qt).

#### Qt Creator configuration

Follow with [Qt Creator configuration](https://wiki.qt.io/Android#Configuring_Qt_Creator)

**Note:** Your Qt Android version is living in `/usr/local/Qt-5.15.0/`, its `qmake` is in `bin` subdirectory.

# Building, installing and running the app on Android device

Select the your new kit, select the armeabi-v7a ABI in qmake Build Step
and build mobile application. Resulting APK should be available as a
`android-build/build/outputs/apk/debug/android-build-debug.apk` under the build
output folder.

During the development you would like to use the Run option in the Qt Creator to speed up
launch of manual run-time test on connected Android device. Android device needs to be in
Developer mode with USB debugging and Install via USB settings turned on.

You can use also x86 emulator. For this simple application I have not found any issues
(but I did for more complex applications).

## Signing and publishing

Notice `debug` strings in build APK path build even for Release build. The reason is that
the build is not signed. **The process is still under research and development.** Resources:

* https://developer.android.com/studio/publish/preparing
* https://developer.android.com/studio/publish/app-signing
* https://stackoverflow.com/questions/23028313/qt-android-why-is-a-qtapp-debug-apk-created-for-a-release-build
* https://stackoverflow.com/questions/22070172/how-to-remove-the-debug-mode-in-release-output-on-android-with-qt-5-2
* https://www.qt.io/blog/2019/06/28/comply-upcoming-requirements-google-play
