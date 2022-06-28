---
layout: post
title:  "Kinesis Advantage USBC & QMK notes"
categories:
---

I have three kinesis advantage now, this is what I've done.

<!--excerpt-->
First off notes on the keyboards:
* Kinesis Advantage Pro
* Kinesis Advantage
* Kinesis Advantage 2 with a [kinT keyboard controller](https://github.com/kinx-project/kint) with a Teensy++ 2.0 running QMK

I don't really see the difference between the first two, but I do like the nicer F keys on the Advantage 2.



----
## Hardware Modifications

I'm replacing the cable with a USBC port on all of them because permanently attached cables are stupid.
<a href="/images/kinesis-advantage-notes/orig_outside.jpg"><img src="/images/kinesis-advantage-notes/orig_outside.jpg" title="original outside cable mess"></a>
<a href="/images/kinesis-advantage-notes/orig_inside.jpg"><img src="/images/kinesis-advantage-notes/orig_inside.jpg" title="original inside"></a>
I cut down a USBC panel mount bracket to fit and adapted it to the thing.

Thanks to [Mihail H. on electronics.stackexchange](https://electronics.stackexchange.com/a/559183/181040) for pointing out it's JST PH.
<a href="/images/kinesis-advantage-notes/cables.jpg"><img src="/images/kinesis-advantage-notes/cables.jpg" title="usbc cables & final inside"></a>
On the first of the three cables I bought the cable broke out the two D+/D- pairs so I initially had a USBC connector that only worked one way, very cursed.
The other two seem to not do this.

<a href="/images/kinesis-advantage-notes/final_outside.jpg"><img src="/images/kinesis-advantage-notes/final_outside.jpg" title="final outside"></a>


-----
## QMK Notes


The default QMK config in the [QMK configurator](https://config.qmk.fm/#/kinesis/kint2pp/LAYOUT) didn't do the keypad layout and did the insert key wrong.

<a href="/images/kinesis-advantage-notes/kinesis_kint2pp_layout_mine.json">I fixed it</a>.
