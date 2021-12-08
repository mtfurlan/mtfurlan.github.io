---
layout: post
title:  "Making afwall not fail captive portal check on android 11"
categories: android
---

I use [afwall](https://github.com/ukanth/afwall) to prevent most things from having internet.

I had a lot of trouble getting wifi to work with afwall enabled in android 11.

<!--excerpt-->

I'm running a samsung A52 5G chinese version with android 11.

The issue is that the captive portal detection decides that there isn't internet, and that I should get fucked.

There is a lot of stuff saying that the way to disable captive portal detection is
```
settings put global captive_portal_detection_enabled 0
```
Those are all for older android, so I checked the
[relevant part of the android 11 source](https://android.googlesource.com/platform/frameworks/base/+/refs/heads/android11-mainline-release/core/java/android/provider/Settings.java#11003).

That says `captive_portal_detection_enabled` is deprecated, use `captive_portal_mode_ignore` instead.

I tried each one individually, and both together
```
$ settings list global | grep captive
captive_portal_detection_enabled=0
captive_portal_mode_ignore=0
```
after a reboot, it still says no internet and `adb logcat | grep connectivity` shows
```
12-02 14:25:14.146  2558 14335 D NetworkMonitor/602: PROBE_DNS connectivitycheck.gstatic.com 18ms OK 142.250.190.67
12-02 14:25:24.165  2558 14335 D NetworkMonitor/602: PROBE_HTTP http://connectivitycheck.gstatic.com/generate_204 Probe failed with exception java.net.SocketTimeoutException: failed to connect to connectivitycheck.gstatic.com/142.250.190.67 (port 80) from /192.168.1.136 (port 38978) after 100
```

App 2559 is "Setup Wizard" in afwall for me, and allowing that wifi means the
captive portal at least can figure out there is internet.

I really don't like that I can't disable the connectivity check because I would
like my phone to allow me access to a network I told it to connect to regardless
of what it thinks about google being accessable.

But whatever, at least it gives me internet now.


---
UPDATE 2021-12-08: it didn't quite work all the time.
It's now working and this is now the list of things I think are relevant:

* 1000 Filter Provider, bunch of other stuff
* 10177 CaptivePortalLogin
* 5023 NetworkDiagnostic
* 10255 Setup Wizard (shows up in a search for 2559, but displays as 10255 now?)
