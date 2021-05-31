---
layout: post
title:  "Colour Spaces"
categories: colour, esp8266
---

Colours are lies.
All I wanted was a nice colour fader.


<!--excerpt-->

This was made in consultation with one of the worlds foremost colour science
experts, any errors are mine.

Probable best case, case, your screen is displaying the triangle:
![image](https://upload.wikimedia.org/wikipedia/commons/a/a8/CIExy1931_sRGB.png)

The stuff outside the triangle is the CIE 1931 XYZ colour space gamut.


Definitions:
* CIE
  * The International Commission on Illumination
  * Some people who make standards
* Gamut
  * A set of colours, like a colour space or what a specific device can render
* Gamma
  * A parameter to the transfer functions to take the stored data closer to some
    value of "actual"
    * E.g. a camera may store a gamma into an image to correct for it's sensor



TODO: where?
Many RGB colour spaces: ![image](https://upload.wikimedia.org/wikipedia/commons/1/1e/CIE1931xy_gamut_comparison.svg)

Relevant colour spaces to what I did
(the capitalization and spacing for the CIE stuff changes, the only thing to do
is not call CIELAB "Lab" to avoid confusion with Hunters Lab)
* RGB: it's what you think about
  * 3 channels, Red, Green, Blue.
  * Stuff like HTML codes
* sRGB: standard RGB: it's what your pictures and such use
  * standard from HP/MS for a defined white point/gamma/etc
    * This can still have a different gamma saved by the camera, called an
      "embedded profile" or something
    * ![image](https://i.imgur.com/Ro18Nyo.png)
* CIE XYZ:
  * Models the human eye
  * Made in 1931 by experiments done on a total of 17 white male middle aged
    Europeans.
    Given that middle aged white male Europeans are a perfect representation of
    the entire range of human experience and colour isn't different to different
    cultures, this works perfectly.
* CIELAB
  * Cartesian spherical colour space
  * Built on top of CIEXYZ to better represent human perception
    There are three revisions of CIELAB, CIE76, CIE94, and CIEDE2000, mostly
    better formulas than Euclidean distance to calculate perceptual difference.
  * L\*: Lightness
  * a\*: green/red
  * b\*: yellow/blue
  * CIELAB is a later standard built on top of CIEXYZ to better represent human
    perception, so theoretically sets of points of an equivalent Euclidean
    distance apart are perceived to be just as far apart.
    There are three revisions of CIELAB, CIE76, CIE94, and CIEDE2000, mostly
    better formulas than Euclidean distance to calculate perceptual difference.
  * ![image](/images/colourspaces/CIELAB.png)
* CIELCh(ab)
  * CIELAB but polar coordinates
  * Lightness, Chroma, Hue


This is the Adobe RGB colour space chunk of CIELAB.
([Adobe is like sRGB but a little bigger](https://en.wikipedia.org/wiki/Adobe_RGB_color_space#Comparison_to_sRGB))
![image](https://upload.wikimedia.org/wikipedia/commons/3/33/Adobergb-in-cielab.png)
Looking at the outside of a cube, white in the center is a corner with the
highest Lightness.

---

## A nice colour fade
If we want to make a colour fade that is smoother than the naive RGB approach,
we need to understand [CIELAB ΔE\*](https://en.wikipedia.org/wiki/Color_difference#CIELAB_%CE%94E*)

It's formulas to calculate how different two points in CIELAB space are
perceptually.

### Approach
In CIELCHab, with a static L and C, iterate over h.
* convert CIELCHab to RGB
* convert RGB to CIELab, calculate difference from last RGB point
* while under min diff, keep iterating h
* store last CIELCH
* output

### Issues
It's jumpy with CIE74/94 ΔE, and super slow with CIE2000 ΔE
