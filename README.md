# Qt for Android Hello World

## Dependencies installation

### Ubuntu 20.04 LTS

Android development is space consuming. 45 GB of VM storage was enough
for minimal Ubuntu installation. You have been warned!

#### Installing dependencies

```
sudo apt install git qtcreator libclang-dev libstdc++6:i386 \
    libgcc1:i386 zlib1g:i386 libncurses5:i386 libsdl1.2debian:i386 \
    lib32z1 cmake ninja-build build-essential default-jre \
    openjdk-8-jdk-headless android-sdk android-sdk-platform-23 \
    libc6-i386 python-is-python3
```

There was a configuration warning in the end of the installation on the VM
but it did not caused any issues laer in the process.

#### Prepare directory for Android toolkit and libraries

Keep your Android development stuff in a convenient location (modify
following steps if you would choose different one).

```
mkdir ~/.android
cd ~/.android
```

#### Android SDK and NDK

**Important Note**: Tested with NDK revision r21d instead of r19c. Change the script
referred in the instructions linked below accordingly.

Follow [Installing the Android SDK and NDK][SDK NDK], the "Scripted installation
on Linux section" (notice that bash script shall be run as a user).

[SDK NDK]: https://wiki.qt.io/Android#Installing_the_Android_SDK_and_NDK

#### OpenSSL for Qt for Android

Follow [this tutorial](https://proandroiddev.com/tutorial-compile-openssl-to-1-1-1-for-android-application-87137968fee).

**Notes:**

* Provided script uses Python 2, so replace `print toolchain_path`
with `print(toolchain_path)` to be able to use it with Python 3.
* Notice that there is Android NDK revision r20 used in the tutorial and
OpenSSL 1.1.1c. Change it to r21d and current version of OpenSSL (1.1.1g at time
of writing this).

#### Qt for Android

```
cd ~/.android
```
[Build Qt for Android.](https://wiki.qt.io/Android#Building_Qt)

**Important Notes:**

* You have suitable Qt Creator and all dependencies already installed.
* Tested with **Qt v5.15.0**, beware of various
  [version compatibility issues](https://doc.qt.io/qt-5/android-getting-started.html).
* **There is missing `--init` in a submodules pull step! Use this comand below instead
  of the one advised in the step 3 of instructions above.**

        git submodule update --init --recursive

  Directories `qtlocation` or `qtwebsockets` should not be empty after submodules pull step.

* After setting JAVA_HOME and PATH variables in `~/.profile` configuration file, apply this
  setting as well.

```
. ~/.profile
```

* **You have to explicitely add OpenSSL support for Qt.** Step 5 should be for the case
of directories used as advised like this:

```
OPENSSL_LIBS='-L/home/roman/.android/output/lib/ -lssl -lcrypto' \
    ./configure -I/home/roman/.android/output/include -openssl \
    -android-ndk-host linux-x86_64 -xplatform android-clang \
    --disable-rpath -nomake tests -nomake examples \
    -android-ndk ~/.android/android-ndk-r21d \
    -android-sdk ~/.android/android-sdk-tools \
    -no-warnings-are-errors -skip qttranslations -skip qtserialport
```

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

I did not have good results with testing in x86 emulator.

## Signing and publishing

Notice `debug` strings in build APK path build even for Release build. The reason is that
the build is not signed. **The process is still under research and development.** Resources:

* https://developer.android.com/studio/publish/preparing
* https://developer.android.com/studio/publish/app-signing
* https://stackoverflow.com/questions/23028313/qt-android-why-is-a-qtapp-debug-apk-created-for-a-release-build
* https://stackoverflow.com/questions/22070172/how-to-remove-the-debug-mode-in-release-output-on-android-with-qt-5-2
* https://www.qt.io/blog/2019/06/28/comply-upcoming-requirements-google-play
