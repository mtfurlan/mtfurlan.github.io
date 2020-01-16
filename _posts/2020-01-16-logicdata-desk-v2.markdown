---
layout: post
title:  "logicdata desk controller v2"
---

At $work I have a motorized sit/stand desk.
I have to hold the up/down buttons to go to any height.
Clearly, this is far too difficult.
So I put together a [thing to read the height and use double presses to automatically go to high/low setpoints while keeping single button hold functionality intact](/hacking-logicdata-desk) a while back.

A few weeks ago, someone emailed me about it and I got inspired to clean it up and redo some bits.

<!--excerpt-->

Version 1 was just taking what [Phil Hord had done](https://github.com/phord/RoboDesk) and bodging it till it worked for my use case.
<a href="/images/logicdata-desk-v2/schematic-v1.png"><img src="/images/logicdata-desk-v2/schematic-v1.png" alt="schematic v1"></a>
It does stuff like use the same pins to read the buttons and control the desk.

It works, but it's hard to read and hard to understand.

For the new version, I just put a switch in to either connect the buttons to the desk, or to fully MitM the buttons.

I had tried to do some fancy logic with 74 series mux before it was pointed out that what I really wanted was a switch.

<a href="/images/logicdata-desk-v2/schematic-v2.png"><img src="/images/logicdata-desk-v2/schematic-v2.png" alt="schematic v2"></a>

One issue I had when assembling this was the DIN-7 connector schematic didn't have a shell pin, which is ground.
You can see the note about that in the v1 schematic.

So when I did basic layout, the connector footprints and symbols had different numbers of pins.
Somehow I didn't notice this till after I had soldered it wrong, but luckily I only had to move three pins cause I also read the schematic wrong, and these mistakes mostly cancelled.

So I spent the time to fix the schematic symbols to have a shell pin, as you can see in the above schematic.
Doesn't look great, but I couldn't really think of a better way to do it.

I've been doing basic layout for protoboard stuff a while, and I find it really helpful even if I'm never going to spin a PCB.

<a href="/images/logicdata-desk-v2/layout-v2.png"><img src="/images/logicdata-desk-v2/layout-v2.png" alt="layout v2"></a>

I did connectorize everything with JST XH.
I've been getting better with crimpers and I'm really liking how it makes so many things easier.

<a href="/images/logicdata-desk-v2/v2.jpg"><img src="/images/logicdata-desk-v2/v2.jpg" alt="closer picture of v2"></a>

It's a little more crowded in v2.

<a href="/images/logicdata-desk-v2/both.jpg"><img src="/images/logicdata-desk-v2/both.jpg" alt="picture of v1 and v2"></a>

I also decreased the thickness of the enclosure, and centered things a little better.

[The Ultimate Parametric Box](https://www.thingiverse.com/thing:1355018) my enclosure is based on isn't the simplest thing to learn openscad on.
I definitely still have a lot to learn about how openscad does things, the coordinate system is still a bit weird to me, you translate stuff but work in the original coordinate space.

Still, I can use it to make objects.
That's pretty cool.

Overall, I'm happy with where this project is now.
For the code, it's usually clear what it's trying to do, for the electronics, it's a bit more complex, but I really like having a switch that cuts out everything I added.
