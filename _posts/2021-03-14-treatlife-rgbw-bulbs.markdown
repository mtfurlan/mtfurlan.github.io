---
layout: post
title:  "Treatlife RGBW Bulbs"
categories: iot
---

I replaced the tuya w8bp with an ESP-12E.

<!--excerpt-->

Treatlife doesn't really believe in model numbers, this is the listing I got: [https://smile.amazon.com/gp/product/B083BRRZ4Y/](https://smile.amazon.com/gp/product/B083BRRZ4Y/)

It has a tuya module inside that I cannot put tasmota on.
I don't appreciate this.

Prior Art: [boilerboy165 on digiblur](https://www.digiblur.com/2021/02/treatlife-sl10-rgb-ccw-esp-transplant.html) did this on a similar treatlife product, but it wasn't RGBW and I had to have some pullups/pulldowns on the ESP12E, so this writeup is quite similar.

## Process
### Dissassembly
The disassembly is covered pretty well in the post I linked, and that post has pictures for this.

1. Run a flexible pry tool around the bulb base to seperate the bulb from the body.
2. Pry the hot contact off the bottom and dislodge the wire.
3. Pry the LED ring upwards, including the metalic thing it's attached to.
4. Wiggle and pull on the board to remove it, the neutral wire may be affixed in pretty good, try pushing down on it to dislodge.
   I did tear one out doing this.

### Remove tuya bullshit
1. Hot air gun to remove the tuya module.
2. Snip the little bridge

<a href="/images/treatlife-rgbw-bulbs/treatlife-board-layout.jpg"><img src="/images/treatlife-rgbw-bulbs/treatlife-board-layout.jpg" title="pinout for treatlife thing"></a>


### Put the ESP-12E in
1. Program it with tasmota
2. Solder GPIO to the RGBW pins with jumpers as necessary
3. Connect enable to 3V3
4. Pullups on GPIO0 and GPIO2
5. Pulldown on GPIO15

| Treatlife Pin | ESP pin |
| ---           | ---     |
| R             | GPIO13  |
| G             | GPIO12  |
| B             | GPIO16  |
| W             | GPIO14  |

TODO: verify table


<a href="/images/treatlife-rgbw-bulbs/finished-top.jpg"><img src="/images/treatlife-rgbw-bulbs/finished-top.jpg" title="such wire management"></a>
<a href="/images/treatlife-rgbw-bulbs/finished-bottom.jpg"><img src="/images/treatlife-rgbw-bulbs/finished-bottom.jpg" title="not shorting, probably"></a>

### Tasmota

The tasmota colour picker has issues and doesn't really like RGBW.
`SetOption105 1` [claims to help with this](https://tasmota.github.io/docs/Lights/#white-blend-mode) but I remain unconvinced.

```
template {"NAME":"treatlife rgbw","GPIO":[0,0,0,0,0,0,0,0,38,37,40,0,39],"FLAG":0,"BASE":18}
module 0
poweronstate 1
SetOption105 1
color FFFFFFFF
RGBWWTable 150,255,255,255,255
```
If I use the HSV sliders it turns off the white channel entirely.
With this RGBTable it turns down red so at color FFFFFFFF the light looks better,
but if you mess with the hsv sliders in the UI it turns off white and the colour is wonky again.

I will update this post with details once I have a functioning tasmota config.
Plan to test out esphome with these as well.
