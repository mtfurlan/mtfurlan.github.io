---
layout: post
title:  "USB PD multi-voltage trigger"
categories:
---


I needed USB PD to barrel jack with multiple voltages.
<!--excerpt-->

This project was started when [Deviant Ollam](https://www.youtube.com/user/DeviantOllam) posted a video about using a USB PD trigger to barrel adapter with a barrel adapter kit instead of sorting through a bin of power bricks.
The issue was that USB PD trigger only output 19V, which not all devices will tolerate.

<a href="/images/usb-pd-multi-voltage-trigger/final.jpg"><img src="/images/usb-pd-multi-voltage-trigger/final.jpg" title="Final"></a>

----

So I found this [USB PD trigger module with solder jumpers for voltage](https://www.ebay.com/itm/185396073306) and made a shitty enclosure for it.
<a href="/images/usb-pd-multi-voltage-trigger/listing.jpg"><img src="/images/usb-pd-multi-voltage-trigger/listing.jpg" title="closeup of trigger module" style="max-width:400px;width:100%"></a>
You short the three pads to make different voltages.

```
Voltage│Short pad
        A│B│C
     20│0│0│0
     15│1│0│0
     12│0│1│0
      9│1│1│0
      5│0│1│1
```


## Prototype
Just threw it together, it worked fine:
<a href="/images/usb-pd-multi-voltage-trigger/prototype.jpg"><img src="/images/usb-pd-multi-voltage-trigger/prototype.jpg" title="prototype"></a>

## Enclosure
I got a friend to model something close to good enough in fusion 360, and then I edited in blender to adjust for tolerances.
<a href="/images/usb-pd-multi-voltage-trigger/dimensions.jpg"><img src="/images/usb-pd-multi-voltage-trigger/dimensions.jpg" title="parts dimensions"></a>

<a href="/images/usb-pd-multi-voltage-trigger/usbPDShell-short.stl">My final STL</a>

## Assembly
The hardest part was soldering the tiny wires to the pads without shorting anything.

1. put 30AWG wires on the trigger module
2. glue the wires down (by the end I had found that superglue worked the best because hot glue left too much of a bump)
3. put the dip switch and voltmeter and trigger module in the enclosure
4. trim wires to length to reach the DIP switch
5. strip wires
6. solder wires
<a href="/images/usb-pd-multi-voltage-trigger/wiringA.jpg"><img src="/images/usb-pd-multi-voltage-trigger/wiringA.jpg" title="wiring trigger to DIP switches"></a>
7. put in wires for voltmeter
<a href="/images/usb-pd-multi-voltage-trigger/wiringB.jpg"><img src="/images/usb-pd-multi-voltage-trigger/wiringB.jpg" title="wire in voltmeter"></a>
8. Tune voltmeter so it's a bit above instead of a bit below (showing 8.9V for 9V is more annoying than showing 9.1V)
8. Pot dip switch in epoxy or superglue or hot glue
9. put in output wires (14AWG speaker wire was just what I had lying around)
<a href="/images/usb-pd-multi-voltage-trigger/wiringC.jpg"><img src="/images/usb-pd-multi-voltage-trigger/wiringC.jpg" title="all wired in"></a>
10. glue in display and dip swith with something fast curing (my first one had epoxy leak out the front and look bad)
11. pot the back with epoxy
<a href="/images/usb-pd-multi-voltage-trigger/final_back.jpg"><img src="/images/usb-pd-multi-voltage-trigger/final_back.jpg" title="potted back"></a>


## Next Steps
I did monday evening when I was leaving tuesday afternoon for defcon, so it could be a lot better

* label switches with voltage table
* better enclosure
  * less glue, actual back
* A more permanent barrel jack (the non-screw ones I had couldn't fit the 14AWG)

If anyone wants to help improve this I'm happy to update this post with better stuff and credit you.


## Parts
* [USB PD trigger module with solder jumpers for voltage](https://www.ebay.com/itm/185396073306)
* [random voltmeter](https://smile.amazon.com/dp/B07Q2RQYPJ)
* [random dip switches I had lying around](https://smile.amazon.com/gp/product/B07CB8Z6ZP/)
* 30AWG wire
* Bigger output wire (I had 14AWG speaker wire)
