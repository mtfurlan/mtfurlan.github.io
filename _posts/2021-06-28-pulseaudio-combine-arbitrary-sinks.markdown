---
layout: post
title:  "Pulseaudio Output to Arbitrary List of Sinks"
categories:
---


I have a headset that has two output devices, a stereo and a mono, with a fade pot to go between them.
This means I want voice programs to go to mono, and everything else to go to stereo.

I also have some speakers, and I would like to output to them at the same time.


<!--excerpt-->

The internet has a lot of suggestions, most of which boil down to
"use use paprefs to output to every sink at once and make a device description
wider than the entire monitor"

By actually reading the docs, I figured out that the `module-combine-sink` can take a list of sinks to output to as an argument.

So what I have is
1. `cp /etc/pulse/default.pa ~/.config/pulse`
2. list sinks with `pactl list short sinks`
   * `pactl list short sinks | grep -v "SteelSeries.*mono" | awk '{ print $2}' | sed -z 's/\n/,/g;s/.$/\n/'`
2. try `pactl load-module module-combine-sink sink_name=combined slaves=$sink_list sink_properties=device.description=whatever`
3. Once that works, put it in `~/.config/pulse`, restart pulseaudio.
```
load-module module-combine-sink sink_name=combined slaves=alsa_output.pci-0000_01_00.1.hdmi-stereo-extra3,alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.analog-stereo,alsa_output.pci-0000_00_1f.3.analog-stereo,alsa_output.pci-0000_00_1f.3.iec958-stereo sink_properties=device.description=combined-without-headphone-mono
set-default-sink combined
```

----
Make sure that if you have to do stuff like setup which HDMI output you use for stuff like a VR hat that that is done first.

Get card Name and Active Profile from
`pactl list cards`
```
set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo-extra3
```

---
2023 update: Debian Bullseye moved from pulseaudio to pipewire.

According to SE, the way to do combined sinks and such things is
[still via pulseaudio](https://askubuntu.com/a/1417370).

Unfortunately, if I do the set-card-profile there it fails.

So what I did was
`~/.config/pipewire/pipewire.conf.d/overrides.conf`
```
context.exec = [
    { path = "bash" args = "~/.config/pipewire/pipewire.conf.d/overrides.sh" }
]
```

and then in `~/.config/pipewire/pipewire.conf.d/overrides.sh`
```
#!/bin/bash

sleep 1
pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo-extra3
pactl load-module module-combine-sink sink_name=combined slaves=alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game,alsa_output.pci-0000_00_1f.3.iec958-stereo,alsa_output.pci-0000_01_00.1.hdmi-stereo-extra3 sink_properties=device.description=combined-without-headphone-mono
pactl set-default-sink combined
```

I feel bad, but it does work, so meh.
