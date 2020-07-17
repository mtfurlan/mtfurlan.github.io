---
layout: post
title:  "HP 7475A Plotter over GPIB/HPIB/IEEE-488"
---

Just got an HP 7475A plotter working with a National Instruments PCI-GPIB 183617K-01.
<!--excerpt-->

[Working code](https://gist.github.com/mtfurlan/ae138eb730517ac946251124feaf9037)

Plotter Manuals:
* [Interfacing and Programming Manual](https://ia803104.us.archive.org/23/items/HP7475AInterfacingandProgrammingManual/HP7475AInterfacingandProgrammingManual.pdf)
* [Operation & Interconnection Manual](https://pearl-hifi.com/06_Lit_Archive/15_Mfrs_Publications/20_HP_Agilent/HP_7475A_Plotter/HP_7475A_Op_Interconnect.pdf)

I used [Linux GPIB](https://linux-gpib.sourceforge.io/) to interface with the gpib card.
It is a kernel module and a userspace library.
The userspace library is natively C, but they provide bindings for other languages, like perl.


Initially I had a bunch issues where it looked like it just forgot about the latter part of longer commands.
This was frustrating, because it worked fine if I copied each command into the interactive terminal example the Linux GPIB folks packaged.

I figured maybe it was somehow a buffer issue, and went down a rabbit hole of trying to ask the plotter when it was done.
The thing that came closest to working is cool trick found via hackaday, [asking the plotter where the pen is and it will not respond till it's done moving](https://blog.dbalan.in/blog/2019/02/23/resurracting-an-hp-7440a-plotter/index.html).


Turns out, my problem was actually that my script didn't have a long enough timeout, and
sending the next command caused the plotter to abort the current command to do the new one.

A timeout of `10` is 300ms, for 10 seconds the timeout should be `13`.

With a proper timeout set, it has accepted a 11183 character transfer without having issues.
Not sure how big the buffer is.


Here are some of the failures, and the eventual success:
<a href="/images/hp-7475A-plotter-gpib/penrose-test.jpg"><img src="/images/hp-7475A-plotter-gpib/penrose-test.jpg" alt="repeated penrose and a 100mm square"></a>
The misalignment is because I kept picking up the paper and putting it back down, it seemed to act differently depending on where it started.

Test 100mm square to demo basic HPGL instructions:
```
IN;                             # initialize
SP1;                            # choose pen 1
PU0,4000;                       # move to 0,4000 without drawing
PD4000,4000,4000,0,0,0,0,4000;  # draw a square
SP0;                            # put away the pen
PU0,0;                          # move to 0,0
IN;                             # re-initialize, not sure why inkscape thinks this is necessary
```
I'm not sure if 1 unit being 0.025mm is a standard for all HPGL plotters, but I'm glad the inkscape defaults, the interfacing manual, and (most importantly) the paper and ruler all agree.


The biggest issue I have right now is that inkscape doesn't have great HPGL support, it only uses PD, which is for straight lines..
The plotter supports fancy curved lines, and fills, and other interesting things.

Curves look okay though, so I don't think I care.
