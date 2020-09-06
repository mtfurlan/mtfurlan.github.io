---
layout: post
title:  "Joysticks in Linux with joydev and evdev"
categories: linux
---

Linux has two joystick modules, `joydev` and `evdev`.

Most joystick calibration tooling is for joydev, but that's deprecated.
There aren't any default tools for saving evdev calibrations.

This is my notes on how I got my joystick calibrated.

<!--excerpt-->

## Problem Statement
I would like to use a joystick in the game Elite Dangerous, played via proton from steam, and my joystick is way out of cal.

Turns out it can only use the evdev module, but this post is more of an overview of what I learned along the way.

This is pretty much a more in depth solution to the problem discussed at
[a reddit post](https://www.reddit.com/r/linux_gaming/comments/5xics8/a_big_problem_with_joysticks_in_linux_right_now/).

## Files
I have a Saitek CYBORG 3D GOLD USB joystick.
It shows up at
```
/dev/input/js0
/dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-joystick
/dev/input/event24
/dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick
```
`usb-SAITEK_CYBORG_3D_USB-joystick` is a symlink to `js0`, and `whatever-event-joystick` symlinks to `eventXX`

`js0` is the joydev stuff, and `event24` is the evdev stuff


## Calibrating
### Calibrating for the "joydev" system
* [jscal](https://manpages.debian.org/testing/joystick/jscal.1.en.html): show and change joystick cal
* [jstest](https://manpages.debian.org/testing/joystick/jstest.1.en.html): show input
* [jstest-gtk](https://manpages.debian.org/testing/jstest-gtk/jstest-gtk.1.en.html): show input and change cal gui

What I ended up doing was the automated cal in `jstest-gtk`, and then manually editing the values till the deadzones worked out.

Export the cal with `jcal -p <device-name>`, it'll print out the jscal command to set the settings to how they are.

For me, it was
```
jscal -s 6,1,0,91,98,9941750,8134159,1,0,97,102,8521500,9099229,1,0,80,85,8658944,8388352,1,0,108,109,5965050,8012754,0,0,0,0 /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-joystick
```

Turns out, Debian's `joystick` package does some nice stuff with `/lib/udev/rules.d/60-joystick.rules` and `jscal-store`/`jscal-restore` to automatically apply calibrations for joydev.

### Calibrating for the "evdev" system
* [evdev-joystick](https://manpages.debian.org/testing/joystick/evdev-joystick.1.en.html): show and change cal
* [evtest](https://manpages.debian.org/testing/evtest/evtest.1.en.html): show input, but poorly
* [Grumbel/evtest-qt](https://github.com/Grumbel/evtest-qt): show input with a gui but no values
* [Virusmater/evdev-joystick-calibration](https://github.com/Virusmater/evdev-joystick-calibration) autocal script with some autoload functionality

I used `evdev-joystick-calibration` to get the calibration values, but I don't value it's attempts to be the program a udev rule calls to re-apply the call when we already have `evdev-joystick`, so I just took it's json:
```
{"5": {"minimum": 16, "maximum": 152, "analog": "ABS_RZ "}, "0": {"minimum": 32, "maximum": 164, "analog": "ABS_X "}, "1": {"minimum": 34, "maximum": 161, "analog": "ABS_Y "}, "6": {"minimum": 16, "maximum": 177, "analog": "ABS_THROTTLE "}}
```
and turned it into commands:
```
evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 32 -M 164 -a 0
evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 34 -M 161 -a 1
evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 16 -M 152 -a 5
evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 16 -M 177 -a 6
```

I would prefer to convert the `jscal` format to `evdev-joystick` commands, but I think the unedited output from `evdev-joystick-calibration` is close enough for today.
I found a post about [how the format works](https://blog.gimx.fr/joystick-calibration-in-gnulinux/) so it shouldn't be too bad when the time comes.

So in the end I have the very readable `/etc/udev/rules.d/85-saitek-cyborg-3d-joystick-jscal.rules`:
```
SUBSYSTEM=="input", ATTRS{idVendor}=="06a3", ATTRS{idProduct}=="0006", ATTRS{product}=="CYBORG 3D USB", ACTION=="add", RUN+=" /bin/bash -c 'evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 32 -M 164 -a 0; evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 34 -M 161 -a 1; evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 16 -M 152 -a 5; evdev-joystick -e /dev/input/by-id/usb-SAITEK_CYBORG_3D_USB-event-joystick  -m 16 -M 177 -a 6'"
```


## Testing the inputs in programs
### Testing SDL
SDL is a cross-platform library a lot of games use.
I have no idea if the game I care about uses it, but I thought it did for a while.

To test how input looks to sdl, [Grumbel/sdl-jstest](https://github.com/Grumbel/sdl-jstest) works well.
It is important to run `git submodule init`.

One thing a bunch of places on the internet recommend is putting `SDL_JOYSTICK_DEVICE=/dev/input/js0` into your environment somehow.
This worked with SDL 1, but not SDL2, you can see that by trying it with `sdl-jtest` and `sdl2-jtest`

### Testing whatever windows gets via proton
To test whatever the windows inside wine gets, this works:
```
WINEPREFIX=$STEAMLIBRARY/steamapps/compatdata/$APPID/pfx $STEAMLIBRARY/steamapps/common/Proton\ 5.0/dist/bin/wine64 control
```
