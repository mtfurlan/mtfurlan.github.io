---
layout: post
title:  "RTT with a nordic board on linux"
categories: kicad
---

Segger RTT(Real Time Transfer) is an out of band debugging tool.
I specifically want to use it with Nordic's logger.

If you search "rtt nordic linux", you get
[a forum post explaining how to do it](https://devzone.nordicsemi.com/f/nordic-q-a/14512/how-to-use-rtt-viewer-or-similar-on-gnu-linux).

Pity it doesn't work.

<!--excerpt-->

The basic idea is you run `JLinkExe`, have it connect to the microcontroller, and then run `JLinkRTTClient`, which will connect to `JLinkExe` and show you the output.

In the end, the issue I was having is that the RTT Control Block address wasn't being automagically discovered.


This [ post from jWendell](https://forum.segger.com/index.php/Thread/4754-SOLVED-RTT-on-MacOSX-TI-CodeComposerStudio-Tiva-LaunchPad/?postID=17642#post17642) is what pointed me to the correct solution.


Manual steps to make it work:
* [Look up the RTT Control Block address](https://devzone.nordicsemi.com/f/nordic-q-a/34060/rtt-control-block-location-for-segger-systemview) in `_build/*.map`, just grep for `_SEGGER_RTT`
* ```
JLinkExe -if SWD -speed 4000 -device Cortex-M4 -autoconnect 1
```
* then type `exec SetRTTAddr 0xWHATEVER` into the `JLinkExe` prompt
* in a different terminal run `JLinkRTTClient`, receive the RTT output, rejoice, etc.


As that is an unacceptable number of steps[^1], lets script that.

If you look at the [JLink documentation](https://www.segger.com/downloads/jlink/UM08001) and search for `SetRTTAddr`, it talks about what it does and how to use it.
If you look below that, at SetRTTTelentPort, you will see the only place I've found documentation for the command line options: Side comments in other sections.


As there is no way to set `SetRTTAddr` from the command line, we'll just pass a script file in with
[-CommanderScript](https://wiki.segger.com/J-Link_Commander#Batch_processing).

The address is in build artifacts, so we want to dynamically read it.

I tried using [process substitution](https://en.wikipedia.org/wiki/Process_substitution), but that didn't work out so I just used `mktemp`.


This is the first pass at hacking together something that works.
```
#!/bin/bash
set -eo pipefail

cd $(dirname "$0")

#TODO: If it was the user pressing ^c to kill JLinkRTTClient, maybe don't
#return an error?
function cleanup() {
    rm -f $TMP
    echo ''
    #echo 'trap'
    # TODO: this finds two processes that are dead by the time kill gets them,
    # but if I don't do it, JLinkExe stays around too long
    kill $(jobs -p)
    exit 42
}

TMP=$(mktemp)
echo "tempfile is $TMP"

trap "cleanup" SIGINT SIGTERM ERR

echo -n "exec SetRTTAddr " > $TMP
grep " _SEGGER_RTT" _build/*.map | awk '{print $1}' >> $TMP

JLinkExe -if SWD -speed 4000 -device Cortex-M4 -autoconnect 1 \
    -CommanderScript $TMP >/dev/null 2>&1 &

JLinkRTTClient

#probably can't get here, need to ctrl c out of JLinkRTTClient, which will
#return an erro, which will be caught by trap ERR
#but just in case
echo "somehow JLinkRTTClient didn't return an error on exit"
rm -f $TMP
exit 1;
```

Reflashing the code while this is running seems to work fine.


If you have improvements, or want to know if I've fixed anything since I posted it, email me.


[^1]: More than one
