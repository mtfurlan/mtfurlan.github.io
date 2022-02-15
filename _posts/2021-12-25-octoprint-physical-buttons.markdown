---
layout: post
title:  "Physical Power and Relay Buttons for Octoprint"
categories:
---

I run octoprint on a pi.
I have octoprint controlling a relay for the printer, and I wanted a physical
button on the printer to make octoprint toggle it.

Turns out a pi can also have a functional power button to turn it on and off these days too.
<!--excerpt-->

For the power button, you can use GPIO3 as a
[shutdown button](https://raspberrypi.stackexchange.com/a/77918),
and also to [turn it back on](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#WAKE_ON_GPIO).

It's still powering the power rails and isn't fully off, but that's fine by me.

So I added
* a momentary switch that is read via octoprint deal with the power relay, also managed by octoprint.
* an RGB momentary switch to turn the pi on/off and show the state of the pi (turning on, running, shutting down)

pi GPIO:
* gpio 3: toggle pi power via config.txt magics in the links above
* gpio 17: blue power switch led (pi booting, and when the pi is off it's very dimly blue)
* gpio 27: green power switch led (pi running)
* gpio 22: red power switch led (pi turning off)

* gpio 4: printer power relay
  * This is after the switch on the UM2, I cut the trace on the bottom after SW1 and put the relay between SW1 and J14+
* gpio 24: 3V3 from printer to sense if relay is on
  * ultimaker 2 control board TP37(3V3) TP39(GND)
* gpio 18: toggle relay button
  * octoprint physical button addon + curl + psu control addon

octoprint setup:
* PSU control plugin
  * control relay, sense relay
* physical button addon
  * toggle relay with system task that runs
    * `curl -s -H "Content-Type: application/json" -H "X-Api-Key: $apikey" -X POST -d '{ "command":"togglePSU" }' http://localhost/api/plugin/psucontrol`
    * I tried the python octoprint api but it was *super* slow

## config files
Turn the blue LED on at boot with config.txt and use systemd units to update the LED to running and poweroff

`config.txt` added to bottom:
```
dtoverlay=gpio-shutdown
gpio=17=op,dh
gpio=27=op,dl
gpio=22=op,dl
```

`/etc/systemd/system/led-startup.service`
```
[Unit]
Description=set LEDs to booted state
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '[ ! -d /sys/class/gpio/gpio17 ] && echo "17" > /sys/class/gpio/export; echo "1" > /sys/class/gpio/gpio17/value'
ExecStart=/bin/bash -c '[ ! -d /sys/class/gpio/gpio27 ] && echo "27" > /sys/class/gpio/export; echo "0" > /sys/class/gpio/gpio27/value'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

`/etc/systemd/system/led-shutdown.service`
```
[Unit]
Description=shutdown LED stuff
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '[ ! -d /sys/class/gpio/gpio27 ] && echo "27" > /sys/class/gpio/export; echo "1" > /sys/class/gpio/gpio27/value'
ExecStart=/bin/bash -c '[ ! -d /sys/class/gpio/gpio22 ] && echo "22" > /sys/class/gpio/export; echo "0" > /sys/class/gpio/gpio22/value'
TimeoutStartSec=0

[Install]
WantedBy=shutdown.target
```

## pi4 pinout
I also made a diagram for the pi4:
```
                             RPi 4
                             ┌───┐
                    +3V3   1 │○ ○│ 2   +5V
             (SDA) GPIO2   3 │○ ○│ 4   +5V
             (SCL) GPIO3   5 │○ ○│ 6   GND
                   GPIO4   7 │○ ○│ 8   GPIO14 (UART TXD)
                     GND   9 │○ ○│ 10  GPIO15 (UART RXD)
       (SPI1_CE1) GPIO17  11 │○ ○│ 12  GPIO18 (SPI1_CE0)    [PWM]
                  GPIO27  13 │○ ○│ 14  GND
                  GPIO22  15 │○ ○│ 16  GPIO23
                    +3V3  17 │○ ○│ 18  GPIO24
      (SPI0_MOSI) GPIO10  19 │○ ○│ 20  GND
      (SPI0_MISO) GPIO9   21 │○ ○│ 22  GPIO25
      (SPI0_SCLK) GPIO11  23 │○ ○│ 24  GPIO8  (SPI0_CE0)
                     GND  25 │○ ○│ 26  GPIO7  (SPI0_CE1)
   {Reserved EEPROM_SDA}  27 │○ ○│ 28  GPIO1  {Reserved EEPROM_SCL}
                  GPIO5   29 │○ ○│ 30  GND
                  GPIO6   31 │○ ○│ 32  GPIO12
[PWM]             GPIO13  33 │○ ○│ 34  GND
[PWM] (SPI1_MISO) GPIO19  35 │○ ○│ 36  GPIO16 (SPI1_CSO)
                  GPIO26  37 │○ ○│ 38  GPIO20 (SPI1_MOSI)
                     GND  39 │○ ○│ 40  GPIO21 (SPI1_SCLK)
                             └───┘
```
