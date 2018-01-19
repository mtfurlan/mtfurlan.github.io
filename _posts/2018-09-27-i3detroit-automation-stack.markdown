---
layout: post
title:  "i3Detroit Automation: Snappy Title Pending"
categories: automation
---

Here at i3Detroit, we like learning things. Also we don't like doing extra work.
This usually balloons into a lot of extra work and (hopefully) less work later.
[<img src="https://imgs.xkcd.com/comics/automation.png" title="'Automating' comes from the roots 'auto-' meaning 'self-', and 'mating', meaning 'screwing'.">](https://xkcd.com/1319/)

i3Detroit Automation System Architecture

We started looking into automation for a few reasons: simplifying the space shutdown procedure, and cost/complication of expanding.
Most of our existing lighting circuits are where they were when we started renting the building but some of them have been cumbersome to work with ("no, you can't plug that in there that outlet turns off when the lights do").
When we expand to encompass even more space it gets increasingly difficult to run more and more light switches to control groups of outlets.
With networked relays on every light we can specify groupings in software rather than spending 4-5 hours bending conduit, planning a route in our increasingly crowded ceiling and walls, and pulling fairly expensive wire long distances.
Doing this in our current space gives proof that we do not need to spend a lot of time re-wiring any building we inhabit, just plug in the lights to whatever outlets are already up there and we can control them in whatever pattern is most convenient.

Frequently people would complain because they come in and find the doors to have been unlocked all night, or the tank of argon has all leaked away, or maybe someone decided to try to heat our colander of a shop to 75F all night long in the middle of winter when no one was there.
The benefits of automating things is not just saving time on tasks that get done, but making sure all the tasks actually do get done.


<!--excerpt-->

i3Detroit's status panel:
<img src="https://www.i3detroit.org/wi/images/d/d5/IoT_map.jpg" class="img-middle">

Designing a system to be used by 160 people, most of whom have no idea/interest in what it is, how it works, or what new failures can occur is difficult.
In the home automation hobbyist community this usually correlates to the ['Spousal Acceptance Factor'](https://en.wikipedia.org/wiki/Wife_acceptance_factor) but we have so many more people to please (or, at least pre-emptively render any potential complaints irrelevant/solved).
The biggest requirement we had going in was that everything has to work when the wifi and/or internet was down.
The lights not working because the internet being down is not acceptable (and makes it fairly hard to explain why this is better than it used to be).


One of the bigger changs was all the lightswitches.
Previously The lights were mainly controlled in lines that run the entire length of the building, each running from either a lightswitch (less bad) or a breaker (more bad).
Now, the software controlled lights exactly mirrors this pattern, but now we have several lightswitches in different locations making it more convenient.
The old lightswitches have not been removed, only had plastic covers placed over them because when the network is down they can still be used to control the lights.

Example of new button layout vs old lightswitch layout:
<img src="/images/i3detroit-automation-stack/switches.jpg" class="img-middle">
In this case, the green lightswitches controlled three rows of lights. The order is something like 2 3 1 or whatever, the point being it was just try random switches and hope you get the right one.
Now, they're labeled.

All our lights without ground level buttons have their switches/breakers preserved and have been configured to turn on when they boot up.
This means that if there is no wifi at all, the relay gets power and then immediately turns the light on so it works seamlessly as if the relays were not there.
The lightswitches for the office area we replaced with sonoff touches, because they either only controlled one light or control built-in lights (behind drywall for example), and they do not turn on when power is restored.

TODO: picture of sonoff touch

Other considerations:
- The S in IoT stands for Security.
- Privacy concerns or whatever

We took a three tier approach to the control stack.
1. The original lightswitches(or breakers as the case may be) still work. If you bounce power, the lights turn on.
2. Commands over MQTT, with the [mosquitto](https://mosquitto.org/) broker.
  * Things like three-way switches talk directly to eachother over MQTT
  * If the MQTT broker is up, you can chant the archaic incantations into the broker to receive control over things.
3. [Homeassistant](https://home-assistant.io), this does the high-level logic and automation magic.

We also use [InfluxDB](https://www.influxdata.com/time-series-platform/influxdb/) as a time-series database to log everything, and [Grafana](https://grafana.com/) to display beautiful graphs.

<a href="/images/i3detroit-automation-stack/grafana.png"><img src="/images/i3detroit-automation-stack/grafana.png" alt="graph of fablab temperature in grafana"></a>

We started with [openhab 2](http://www.openhab.org/), but it was clunky and seems to have a few memory leaks.
Homeassistant appears to have a more centrally focused development, and has a better stock UI.
The limitations on what hardware is supported in Homeassistant is not much of a concern because implementing things is not terribly difficult should we need to.

It also has the option of better scripting with AppDaemon, which we haven't played with too much yet.

Every IoT device connects to a wifi network that is on a vlan that can not talk to the internet.
The only exception is the IoT VM named `mcclellan` which can talk to this VLAN and can be remotely administered.
We also have plans to include outside data into either displays or automations such as weather projections or https://spacedirectory.org/pages/docs.html / http://spaceapi.net/.
Sequestering the IoT like this not only makes it easier to have a relatively sensible DHCP pool for normal users of our network, but also prevents accidental control of devices or programming of devices (the Arduino over-the-air programming caused problems when users try to find their device which is on same wifi as tens of IoT devices that can be programmed that way).



Most of our devices are [iTead](https://www.itead.cc/) products, such as the 4.85USD [sonoff basic](https://www.itead.cc/smart-home/sonoff-wifi-wireless-switch.html) running the open source [Tasmota](https://github.com/arendst/Sonoff-Tasmota/wiki) firmware.
<img src="https://gloimg.gbtcdn.com/gb/pdm-product-pic/Maiyang/2018/01/19/goods-img/1516330084294634377.jpg" class="img-middle">
We cannot beat that price.

We also have a bunch of [custom](https://github.com/i3detroit/custom-mqtt-programs) programs:
* Lightswitches
* Thermostats
* Temperature sensors
* Motion sensors
* LED displays
* Front door status panel

<img src="/images/i3detroit-automation-stack/thermostat.jpg" alt="custom thermostat v1">

All of the custom code tries to emulate tasmota in terms of the interface, for consistency reasons.

Our MQTT command structure is something like: `%prefix%/i3/inside/%topic%/%command%`
`%topic%` is something like: `lights/001`
There can also be a group topic, which goes in the same place as topic.

`%prefix%` is one of
* `cmnd`: command the module to do something
* `stat`: results of a command
* `tele`: telemetry data

`%command%` is something like `POWER` or `STATUS`.

To turn on light 1, you would send `cmnd/i3/inside/lights/001/POWER 1`.

To query the state of something, send something like `stat/i3/inside/lights/001/POWER`.
No payload, and use `stat`.

[The full tasmota command list](https://github.com/arendst/Sonoff-Tasmota/wiki/MQTT-Features) has a lot of built in functionality.
Our custom code is a bit less featureful, but it does implement `STATUS` to return the mac/ip address.


It's been a slow process, but we need to make sure it will work well, and not be worse than not having it for more than a few hours a t a time.
Bit scary to just start working on a huge system like this without a plan.
[<img src="https://imgs.xkcd.com/comics/the_general_problem.png" title="I find that when someone's taking time to do something right in the present, they're a perfectionist with no ability to prioritize, whereas when someone took time to do something right in the past, they're a master artisan of great foresight.">](https://xkcd.com/974/)
We can only hope we will be master artisans of great foresight.


Setup links:
* [Homeassistant](https://home-assistant.io/docs/installation/virtualenv/)
* AppDaemon (?) Not sure we actually use this. Does some extra automation for homeassistant
* [InfluxDB](http://docs.grafana.org/installation/debian/)
  * Also install telegraf to log cpu/memory/other stats of the server
* Grafana
  * [amd64](http://docs.grafana.org/installation/debian/)
  * [pine64](https://forum.pine64.org/archive/index.php?thread-4659.html)
  * [pi](https://github.com/fg2it/grafana-on-raspberry/wiki)



Mostly unrelated notes on RPI install

sources.list rpi stretch
```
#grafana
deb https://dl.bintray.com/fg2it/deb stretch main
#influx
deb https://repos.influxdata.com/debian stretch stable
```

`sudo apt-get install python3 python3-venv python3-pip grafana influxdb mosquitto mosquitto-clients`

Follow https://www.home-assistant.io/docs/installation/raspberry-pi/

I like /opt/homeassistant better

```
$ cat /etc/systemd/system/homeassistant.service
[Unit]
Description=Home Assistant
After=network-online.target

[Service]
Type=simple
User=homeassistant
ExecStart=/opt/homeassistant/bin/hass -c "/home/homeassistant/.homeassistant"

[Install]
WantedBy=multi-user.target
```


Use https://github.com/grafana/grafana/blob/master/packaging/deb/systemd/grafana-server.service
```
$ cat /etc/systemd/system/grafana-server.service
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=influxd.service

[Service]
EnvironmentFile=/etc/default/grafana-server
User=grafana
Group=grafana
Type=simple
Restart=on-failure
WorkingDirectory=/usr/share/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/sbin/grafana-server                                                  \
                            --config=${CONF_FILE}                                   \
                            --pidfile=${PID_FILE_DIR}/grafana-server.pid            \
                            cfg:default.paths.logs=${LOG_DIR}                       \
                            cfg:default.paths.data=${DATA_DIR}                      \
                            cfg:default.paths.plugins=${PLUGINS_DIR}                \
                            cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}

LimitNOFILE=10000
TimeoutStopSec=20
UMask=0027

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload
systemctl enable homeassistant
systemctl enable grafana
systemctl enable mosquitto
```
influx is enabled already?

Start all services, reboot, etc

`influx --execute "CREATE DATABASE hass"`

Add to `~homeassistant/.homeassistant/configuration.yaml`
```
influxdb:
  host: localhost
  database: hass

mqtt:
  broker: localhost
```

Running!
