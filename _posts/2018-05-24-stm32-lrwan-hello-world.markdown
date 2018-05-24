---
layout: post
title:  "Hello World on an stm32 l0 LoRa dev board"
categories: stm32
---

Trying to make it blink.

Took far longer than expected or probably necessary.

<!--excerpt-->

It seems a lot of my life has been trying to replicate and or work around weird IDE include behavior with make and gcc.
To get code to compile with the HAL libraries from ST, you need to manually include the ones you use in the sources in your makefile, and manually include a bunch of directories in your include path.

I'm guessing the fancy IDEs just do some guessing magic to add the files to be compiled.
Or maybe just makes the object files for all of them and lets you have access to that.


* Start point: [WolinLabs STM32 Discovery Development On Linux](http://www.wolinlabs.com/blog/linux.stm32.discovery.gcc.html)
* End goal: [LoRa Demo code/HAL libraries](https://my.st.com/content/my_st_com/en/products/evaluation-tools/product-evaluation-tools/mcu-eval-tools/stm32-mcu-eval-tools/stm32-mcu-discovery-kits/b-l072z-lrwan1.html) from st running.
* Current point: Blinking.

Official [documentation for the dev kit](http://www.st.com/content/ccc/resource/technical/document/user_manual/group0/ac/62/15/c7/60/ac/4e/9c/DM00329995/files/DM00329995.pdf/jcr:content/translations/en.DM00329995.pdf) from st.

Thanks to eewiki for [documentation on how to use GPIO](https://eewiki.net/pages/viewpage.action?pageId=47644832#GettingStartedwithSTM32ARMCortex-M0+-Example_of_GPIOExampleofGPIO:) that I couldn't find elsewhere.



## Setup

* Compile [the open source version of stlink](https://github.com/texane/stlink) somewhere.
  * No need to install globally.
  ```
  st-info --probe
  ```
  * Make sure that that actually sees your thing, should look like:
  ```
  Found 1 stlink programmers
   serial: 303636434646333233343335353033
  openocd: "\x30\x36\x36\x43\x46\x46\x33\x32\x33\x34\x33\x35\x35\x30\x33"
    flash: 196608 (pagesize: 128)
     sram: 20480
   chipid: 0x0447
    descr: L0x Category 5 device
  ```

* Take the st example/firmware zip, extract it somewhere.
  * Modify the makefile to have paths that point to the st code dir, and the stlink release directory.

* Get GDB to evaluate our macros
  * Need to modify ~/.gdbinit to whitelist other .gdbinit files. Read the gdb startup messages, it will explain.
  * I had to do this, if you're copying mine this is in it:
    * Modified the `reload` macro in the `.gdbinit` to take an argument to not kill the program if not needed, it would be better if I could figure out how to make gdb macros have failure be an option on some commands.
    * If it's built with python support, you can have it run python, and presumably other languages, but that's more investment than I had at the time.

## Building
```
make
make burn
```

## Debugging

### Useful commands:
* make showelf
  * Show the assembly, same as running `arm-none-eabi-objdump -Cd blinky.elf | less`

### Running GDB:
* st-util
  * Start the gdb server
* `arm-none-eabi-gdb blinky.elf`
* In gdb, `reload` or `reload anyArg` will burn new code.


Got it blinking with a breakpoint for delay, but trying to use the blink code from Ross Wolin or the `HAL_Delay` seemed to just hang.
Spent a day or so debugging this, set it down for a while, and then had the bright idea to ask "What's the clock?".

Turns out the default clock is 2.1MHz.
The delay function Ross gave us is


{% highlight c %}
//Quick hack, approximately 1ms delay
void ms_delay(int ms)
{
   while (ms-- > 0) {
      volatile int x=5971;
      while (x-- > 0)
         __asm("nop");
   }
}
{% endhighlight %}
So, `5971 + number of instructions to run a loop` is about 1ms.
At 2.1MHz, one instruction is `4.7*10^-7` seconds. 1ms is `1*10^-3` seconds.
So the number of instructions in 1ms is `10^-3/(4.7*10^-7) = 2128`

So considering that this is the important bit of the delay funciton, you would think we just divide that by the 5 other loop instructions.
```
 80001ea:       23fa            movs    r3, #250        ; 0xfa
 80001ec:       60fb            str     r3, [r7, #12]
 80001ee:       e000            b.n     80001f2 <ms_delay+0x12>
 80001f0:       46c0            nop                     ; (mov r8, r8)
 80001f2:       68fb            ldr     r3, [r7, #12]
 80001f4:       1e5a            subs    r2, r3, #1
 80001f6:       60fa            str     r2, [r7, #12]
 80001f8:       2b00            cmp     r3, #0
 80001fa:       dcf9            bgt.n   80001f0 <ms_delay+0x10>
```

But I did my math wrong the first time, and got 250, which works near-correct(500ms is 543), so the timing is still magic?

The `HAL_Delay` still doesn't work, and I have absolutely no idea why.
Maybe I was supposed to define the clock speed for the HAL stuff somewhere like `F_CPU` in AVR.
