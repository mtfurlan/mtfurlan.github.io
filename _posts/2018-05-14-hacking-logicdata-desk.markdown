---
layout: post
title:  "Hacking the Logicdata Desk Controller"
categories: microcontroller, one-day
---

The definition that is [not actually from MIT in spite of always being cited as from MIT](http://tmrc.mit.edu/hackers-ref.html) of hacking is

> Hacking: Using things in ways they were not intended to be used.

It's a good definition.

So here's how I hacked my electronic sit/stand desk controller to have set points in yet another one day project.

<!--excerpt-->

So first off, many thanks for Phil Hord for [doing 90% of the work for me](https://github.com/phord/RoboDesk).
He wrote the analysis code for the logicdata protocol, as well as the clever way to read the button lines while asserting them so the desk still moves.
This is mostly a writeup of how to use his codebase, and some of how it works.

So now my discovery process, starting with the controller.

<img src="/images/hacking-logicdata-desk/controller.jpg" alt="the logicdata controller and a microcontroller">

Logicdata was nice enough to provide a [datasheet](https://web.archive.org/web/20180514132622/http://www.logicdata.net/wp-content/uploads/2017/05/Datasheet_Compact_English-Rev4.pdf), not that I trust them to keep it up so have a link to archive.org.

This contains the pinout for the button connector.
<img src="/images/hacking-logicdata-desk/controller-pinout.png" alt="the logicdata button pinout">

It has a serial line! Those do interesting things!

Turns out, at least one other person on the planet has noticed this, and it was Phil Hord, who has some [videos of something related to the desks](https://www.youtube.com/watch?v=SxIxr1Ul7UI).

From there, I found his github, and his [code](https://github.com/phord/RoboDesk).
The interesting bits are hidden away on the LogicData branch.

After that, it was an entire half day to get it running on an nodemcu board, chosen for it's well-respected feature of being within reach.

So because we want to be able to read the button presses, but also be able to control the desk without fully MitM ing the buttons, phord came up with a rather clever workaround.
Write to the buttons or whatever, set them as input, read them, try again till it looks like we aren't reading what we wrote, and then switch back to output and continue asserting the line high or low.

It does make the debouncing code a little more confusing.

The LogicData protocol is the other important thing.
I didn't spend much time looking at it on the scope, because the code just worked.
So here are the notes phord left on it, which I did confirm with a scope.

```
// 32-bit words
// Idle line is logic-high (5v)
// MARK is LOW
// SPACE is HIGH
// Speed is 1000bps, or 1 bit per ms
// Start data by sending MARK for 50ms
// Approximately 50ms between words
// First two bits are always(?) 01 (SPACE MARK)
// All observed words start with 010000000110 (0x406; SPACE MARK SPACEx7 MARKx2 SPACE)
```

There are a few things his code doesn't interpret, but it does read the height of the desk, which is the thing I wanted so I didn't poke too hard into how the message parsing worked.

Ran into the issue of using a 3.3v microcontroller with 5V logic; I apparently can sustain a movement, but can't start one.
I'm hopeful that a level shifter will fix that.

[https://github.com/mtfurlan/RoboDesk](https://github.com/mtfurlan/RoboDesk)
