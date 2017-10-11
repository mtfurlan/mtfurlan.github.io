---
layout: post
title:  "Arduino Media Keypad"
categories: arduino keyboard
excerpt_seperator: <!--excerpt-->
---

I wanted a small programmable keypad.
It's primary purpose was to be media keys for a model M that needed to be cleaned and bolt modded, but now that I use a (different) model M, I finished the project.

<!--excerpt-->

<img src="/images/arduino-keypad/arduinoKeypad.jpg" class="img-middle">

Take a keyboard tester, add an arduino pro micro, and boom: Programmable keyboard.

Code is [available on github](https://github.com/mtfurlan/arduinoKeypad).


Hardware side:

Wire the buttons to the arduino, in whatever order is convenient at the time.
<img src="/images/arduino-keypad/arduinoKeypadWires.jpg" class="img-middle">

Carve out a hole in the side of the box, and glue the arduino in.
<img src="/images/arduino-keypad/arduinoKeypadTogether.jpg" class="img-middle">

And then the hardware side is done!

<img src="/images/arduino-keypad/arduinoKeypadDone.jpg" class="img-middle">

The software side is a bit silly. The arduino keyboard library does not support sending arbitrary HID codes, because fuck you. So you need to either modify the arduino library, which is what I did for the initial demo, or make a remote library, which is what is currently there.
It should be noted that all credit for the remote library goes to Stefan Jones, whose code I adapted.

So my code, you define a list of pins, and a list of functions for that pin.
The loop runs a bit of debouncing, and if it's been pressed runs the function for that key. You need to define that function, but you get the choice of the arduino libraries that do keyboard keys, and the remote library that does media keys like volume up/down.

Also provided is an example that will open hackaday, in my blatent attempt to get something onto hackaday.
