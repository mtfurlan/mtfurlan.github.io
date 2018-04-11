---
layout: post
title:  "Building a custom thermostat"
categories: automation
---

So at i3, one issue we have is people leaving the thermostats on high temepratures and going home.

So we built our own into the automation system.

<!--excerpt-->

At it's core, a thermostat is just a temperature sensor, some relays, some buttons, and a display.

And lo, a thermostat:
<img src="/images/thermostat/first_board.jpg" class="img-middle">
It just appeared, fully formed.

Alternately, [abzman](http://abzman2k.wordpress.com/) made it.

The [code](https://github.com/i3detroit/custom-mqtt-programs/blob/master/thermostat/thermostat.ino) was good fun to write.
Did you know that these things have complex behaviors? That are hard to keep in your head all at once?

Who knew.

Recommendation: Actually write down test procedures.

In the end it seemed to work, and it was put into use:
<img src="/images/thermostat/v1.jpg" class="img-middle">

That one has a bug in the cooling side of the temperature control.
Don't tell anyone.
It'll be fixed when I merge the branches for the new boards which will be before summer so nobody should use the AC.
Hopefully.


After we had the prototype working for a bit, I learned to use kicad.
<img src="/images/thermostat/boards.jpg" class="img-middle">
My first board turned out pretty well, considering.

Issues:
* a few of the LEDs are backwards
* so the relay output is backwards, but our relays have NO and NC things so it's fine
* I pulled the i2c expander reset the wrong way, so we have to jumper one pin

We have 4 thermostats at i3, but only one does AC. The plan is to use the same thermostat with the cool button not usable.

Got a bunch of revisions to make written down, and even partially completed, but I'm not sure we will need to make a new version.

They're not installed at i3 yet, but I'm testing one in my house.
Has not yet burned down.

At least, it hadn't when I left this morning.
TODO: picture in house

