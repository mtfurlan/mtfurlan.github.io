---
layout: post
title:  "Android Headphone Buttons"
categories: android
---

I wanted a skip backwards button for audiobooks in the car so I used the android headphone button standard.

<!--excerpt-->

Android [3.5mm headset accessory spec](https://source.android.com/devices/accessories/headset/plug-headset-spec)
says that you can have 4 buttons by putting different resistances between mic and ground.
* Function A(0Ω)
  * short: play/pause
  * double: next
  * long: trigger assist
* Function B(240Ω): vol up
* Function C(470Ω): vol down
* Function D(135Ω): "reserved"

You supposed to do some fancy math with the mic resistance, but as I don't intend to have a mic on this I skipped it


The hard part was getting function D to do anything.
I can't get any of the key press debugging apps I tried to register it.
It definitely does things by default, like make tasker save, or close the pulldown menu.
No idea what the phone thinks it is though.

I did eventually get [AutoMediaButtons](https://play.google.com/store/apps/details?id=com.joaomgcd.automediabuttons&hl=en_US&gl=US)
from the [tasker AutoApps family](https://joaoapps.com/) to register it as a "pressy" button.

"Pressy" appears to be some product that is a headphone jack and just has a
single button.
It's weird that I can't make tasker recognize it in any normal
fashion, but at least now I can have it tell my media player to skip back a
bit.
When the question of how to make a pressy button trigger tasker is asked
the responses are to use a custom app to detect it and then call tasker, which
is super dumb.


Ignore the fact that I ended up with rewind on the right, I'm not resoldering it.

<a href="/images/android-headphone-buttons/schematic.png"><img src="/images/android-headphone-buttons/schematic.png" title='"schematic"'></a>
<a href="/images/android-headphone-buttons/actual.jpg"><img src="/images/android-headphone-buttons/actual.jpg" title="final result"></a>

I haven't used this in the car yet but it seems to be working on the bench.
