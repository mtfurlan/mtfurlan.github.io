---
layout: post
title:  "Android ADB Key Management"
categories:
---

Making a phone trust a jenkins docker container is annoying but doable.

<!--excerpt-->

ADB uses keys to authorize specific computers to each phone, to prevent malicious computers from doing stuff when you just plug a phone in.

At $work we run a jenkins build node that has a phone plugged in to run `./gradlew conectedCheck` to run the instrumented tests that can't be done without a phone or an emulator.
We put the entire android studio install in a container, because I've had problems that required deleting the entire android studio before, and I don't want to manage that on a build node.
Because a new container gets stood up for each build, and each container generates a new adb key, the phone will ask if you trust thhis new computer.

ADB stores it's key at `$HOME/.android/adbkey(.pub)`, and will generate the key if it don't exist.

According to
[the commit that added adb keys](https://android.googlesource.com/platform/system/core/+/d5fcafaf41f8ec90986c813f75ec78402096af2d)
adb can be told to use specific keys with `ADB_KEYS_PATH`, but that doesn't seem to work.

What does work is putting the path to the private key in `ADB_VENDOR_KEYS`.
The intent of `ADB_VENDOR_KEYS` [differs slightly from our use](https://source.android.com/setup/develop/new-device#ANDROID_VENDOR_KEYS), but it works.


## Install a key to a phone
### Option number A: set $HOME weird and just use adb
This is the approach I've used.
```
adb kill-server
mkdir /tmp/adbhome
HOME=/tmp/adbhome adb devices
```
approve on phone, and your key is at /tmp/adbhome/.android/adbkey(.pub)


### Option number B: write into `/data/misc/adb/adb_keys`
Untested by me, but reportedly works and matches the above commit message.

Requires root.
```
adb push $publicKey /data/misc/adb/adb_keys
```


## Jenkins
* Lockable resource (manage -> system configuration -> Lockable Resources Manager) for each phone, with label "android-device"
* Secret file named $resourceName-adbkey containing the adb private key.

How I use it in a jenkinsfile
This doesn't do anything for making sure it uses the correct phone if there are multiple, or that if there are phones on multiple build nodes it gets the correct one.
```
//android phones are lockable resources.
//each phone has an associated credential, that is an ADB key that it's accepted already
lock(resource: null, label: 'android-device', variable: 'LOCKED_RESOURCE', quantity: 1) {
    withCredentials([file(credentialsId: "${env.LOCKED_RESOURCE}-adbkey", variable: 'ADBKEY')]) {
        sh '''
            export ADB_VENDOR_KEYS="$ADBKEY"

            # start adb server with group plugdev
            # docker doesn't load groups from /etc/groups when using 'exec -u'
            sg plugdev "adb start-server"

            if ! adb devices -l | grep "device usb" ; then
                # can't talk to device
                if adb devices | grep "unauthorized" ; then
                    echo "phone connected but build slave unauthorized"
                    return 1
                fi
                echo "no phone connected?"
                return 2
            fi

            # We have to uninstall all company packages to prevent
            # "Package signatures do not match the previously installed version"
            adb shell 'pm list packages -f'  | grep $companyName | sed 's/.*base.apk=//' | xargs -I% adb uninstall % || true

            ./gradlew connectedCheck
            '''
        //tests archived below
    }
}

```
