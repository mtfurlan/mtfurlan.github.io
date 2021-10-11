---
layout: post
title:  "Colour Spaces"
categories: colour, esp8266
---

Colour is a lie.
All I wanted was a nice colour sweep...


<!--excerpt-->

## High level introduction

Your eye can see all these colours.
Probable best case, case, your screen can display the inside triangle:
![CIEXYZ\_sRGB](https://upload.wikimedia.org/wikipedia/commons/a/a8/CIExy1931_sRGB.png){:height="500px"}
The stuff outside the triangle is the CIE 1931 XYZ colour space gamut.
The triangle is the sRGB gamut map.

Code: [github.com/mtfurlan/colourspace-fader](https://github.com/mtfurlan/colourspace-fader)


Definitions:
* CIE
  * The International Commission on Illumination
  * Some people who make standards
* Gamut
  * A set of colours near white, with a defined whitepoint.
  * There are a a bunch of different definitions because people are terrible.
TODO: is gamma just for srgb?
gamma correction?
* Transfer Function
  * A colourspace has a transfer function to convert the stored data closer to
  some value of "reality"
* Gamma coorection
  * Devices and colourspaces have gamma, a parameter to the transfer
  * E.g. a camera may store a gamma into an image to correct for it's sensor
* White point
  * Where is white?
    This can change.



Relevant colour spaces to what I did
* RGB: this is the one you think about
  * 3 channels, Red, Green, Blue.
  * Stuff like HTML codes
* sRGB: standard RGB: it's what your camera and such uses
  * standard from HP/MS for a defined white point/gamma/etc
    * This can still have a different gamma saved by the camera, called an
      "embedded profile" or something
    * ![image](https://i.imgur.com/Ro18Nyo.png){:height="300px"}
* CIE XYZ:
  * Models the human eye
  * Made in 1931 by experiments done on a total of 17 white male middle aged
    Europeans.
    Given that middle aged white male Europeans are a perfect representation of
    the entire range of human experience and colour isn't different to different
    cultures, this works perfectly.
  * (the capitalization and spacing for the CIE stuff changes, the only thing to
    do is not call CIELAB "Lab" to avoid confusion with Hunters Lab)
* CIELAB
  * Cartesian cylendrical colour space
  * CIELAB is a later standard built on top of CIEXYZ to better represent human
    perception, so theoretically sets of points of an equivalent Euclidean
    distance apart are perceived to be just as far apart.
  * There are three revisions of CIELAB, CIE76, CIE94, and CIEDE2000, mostly
    better formulas than Euclidean distance to calculate perceptual difference.
  * L\*: Lightness
  * a\*: green/red
  * b\*: yellow/blue
  * x-rite and Pantone put out a
   [nice whitepaper I am stealing images from](https://www.xrite.com/-/media/xrite/files/whitepaper_pdfs/l10-001_a_guide_to_understanding_color_communication/l10-001_understand_color_en.pdf):
   ![image](/images/colourspaces/CIELAB.png){:height="500px"}
* CIELCh(ab)
  * CIELAB but polar coordinates
  * Lightness, Chroma, Hue


This is the Adobe RGB colour space mapped to CIELAB.
([Adobe is like sRGB but a little bigger](https://en.wikipedia.org/wiki/Adobe_RGB_color_space#Comparison_to_sRGB)),
and this was the best picture I could find without making one.
![image](https://upload.wikimedia.org/wikipedia/commons/3/33/Adobergb-in-cielab.png){:height="500px"}
Looking at the outside of a cube, white in the center is a corner with the
highest Lightness.

You can see how this is a smaller chunk of colour than the above CIELab color chart from x-rite.

TODO: where?
Many RGB colour spaces: ![image](https://upload.wikimedia.org/wikipedia/commons/1/1e/CIE1931xy_gamut_comparison.svg){:height="500px"}

---
## A nice colour fade
### Naive Approach RGB/HSV linear fade
![RGB/HSV fade](https://i.stack.imgur.com/ISVKu.png)
This is an easy to implement (and
[often recommended](https://learn.adafruit.com/rgb-led-strips/arduino-code))
approach.

You can simplify the code by just doing it in HSV with static saturation and
value, and then and converting to RGB, but the end result is basically the
same.

The issue is how you can see how the different colours appear to be different
sizes there.

Also, fun fact, in spite of stuff like the real brief yellow, cyan, or magenta,
this looks a bit better on your computer monitor than it would on an LED,
because your graphics card and your screen both have gamma corrections to
account for what they can display.

### Better Approach
If we use
[CIELAB ΔE\*](https://en.wikipedia.org/wiki/Color_difference#CIELAB_%CE%94E*)
to calculate our steps, then every step should actually look the same amount of
different.

This is ignoring the nonlinearity of output LEDs for now, my plan is to
characterize and adjust later.

#### Approach 1
In CIELCHab, with a static L and C, iterate over h.
* convert CIELCHab to RGB
* convert RGB to CIELab, calculate difference from last RGB point
* while under min diff, keep iterating h
* store last CIELCH
* output

![attempt 1 static luminosity and chroma](/images/colourspaces/CIELCh 1ΔE L=50 C=100.png){:height="500px"}
Turns out static L and C means you cannot get the full range of outputs, look
at how we just don't have much green.
Could get this a bit better by playing with the parameters, but eh.
![attempt 1.5 static luminosity and chroma](/images/colourspaces/CIELCh 1ΔE L=70 C=100.png){:height="500px"}

#### Approach 2
Do a basic HSL sweep, but make sure each step is big enough with ΔE\*.
![attempt 2 static luminosity and chroma](/images/colourspaces/HSL 3ΔE L=1 C=.5.png){:height="500px"}
![attempt 2 static luminosity and chroma](/images/colourspaces/HSL 6ΔE L=1 C=.5.png){:height="500px"}

You can see the focus on red, green, and blue here because this isn't a very
good starting place.

## Approach 3
Do a CIELCH sweep again but add something that takes a target lumens parameter and moves to the closest place that fits

TODO:
* Fix plots: https://stackoverflow.com/questions/69532730/gnuplot-plotting-colours
* try to coerce stuff into the same lumen output
* Get trustable lux sensor, characterize LEDs, write stuff to turn RGB output into lumens

### Neat asides along the way
Used platformio test framework to run a lot of my tests.
This is how I plotted the output of RGB automatically every time a file changed
```
mkdir -p plotData; inotifywait -r -e create --exclude "\.git" -m . -q | grep --line-buffered -E "\.c$|\.h$|\.sh$|\.gnu$" | grep --line-buffered -v "tmp_pio_test_transport.c" | while read -r directory events filename; do echo "file changed: $directory/$filename"; make test | grep -P "PLOTTITLE.*|PLOTDATA" > plotData/output && head -n1 plotData/output | sed 's/PLOTTITLE: //' > plotData/title && tail -n+2 plotData/output | sed 's/PLOTDATA: //' | sort -n -s -k 1,1 > plotData/rgb.csv && ./plot.gnu; echo "done"; done
```
Watch the current directory for file changes, if it does run make test, filter the output and put it in plotData/output, split that into plotdata/title and plotdata/rgb.csv and then run plot.gnu to make a fancy plot.

[github mtfurlan/colourspace-fader plot.gnu](https://github.com/mtfurlan/colourspace-fader/blob/main/plot.gnu)
