---
layout: post
title:  "Frsky communications intro"
categories:
---


Adventures in connecting an RC transmitter to an arduino.

<!--excerpt-->
## Tables of Overview

### Communication Protocols between receiver and MCU
* SBUS
  * > SBUS is a bus protocol for receivers to send commands to servos.
    > Unlike PWM, SBUS uses a bus architecture where a single serial line can be
    > connected with up to 16 servos with each receiving a unique command.
  * inverted UART, 100000 8E2 (fast mode 200000 baud)
  * SBUS IN lets you have a backup receiver
* SmartPort / S.Port
  * telemetry
  * inverted UART, 57600 8N1, bidirectional on a single wire
  * receiver polls sensors, sensors respond when poked
* F.Port / FPort
  * Combined control/telemetry
  * "slightly faster than SBUS"
  * Not inverted
  * No documentation
* F.Port V2
  * Came with the ACCESS stuff
  * No documentation
  * Not sure if it's compatible with V1, there is none documentation


### Firmware/communication stuff between transmitter and receiver
Firmware on the receiver and transmitter for talking to each other
* ACCST 1.x / ACCST D8(not sure about this name, I feel like 2.x can do 8 channels? Saw it on a forum though)
  * SBUS for 8 or 16 channels
* ACCST 2.x / ACCST D16
  * small fix for some bug, but completely incompatible
* ACCESS
  * New thing people seem to like it better
  * A lot of transmitters that do ACCESS also do ACCST 2.x

### Hardware I have
* frsky R-XSR reciever
* frsky taranis x9d-plus running opentx
  * Onboard transmitter can only do ACCST 1.x
  * There is the external radio bay that could do more but eh.

### Literature Search for Software Libraries
#### SBUS
* [bolderflight/sbus](https://github.com/bolderflight/sbus)
* [TheDIYGuy999/SBUS](https://github.com/TheDIYGuy999/SBUS)
* [Sbus converter using Arduino](http://www.ernstc.dk/arduino/sbus.html)

#### SmartPort
* [jcheger/arduino-frskysp](https://github.com/jcheger/arduino-frskysp)
  * handles teensey or 328P via `#ifdef`
* [zendes/SPort](https://github.com/zendes/SPort)
* [DanNixon/FrSky_SPORT_Arduino](https://github.com/DanNixon/FrSky_SPORT_Arduino)
* [openXsensor/openXsensor](https://github.com/openXsensor/openXsensor)
  * multi-protocol, not just S.Port
* [sgofferj/arduino-frsky](https://github.com/sgofferj/arduino-frsky)
  * for reading telemetry,
  * It *doesn't* try to handle serial for you! So much nicer!


#### In the end I went with
* SPort: [jcheger/arduino-frskysp](https://github.com/jcheger/arduino-frskysp)
* SBUS: [bolderflight/sbus](https://github.com/bolderflight/sbus)

The SPort library wanted to use `SoftwareSerial` and just talk and receive on the
same pin, which didn't work too good on the esp32 so I forked it to use
`HardwareSerial` and to swap which pins are which at the right times.

I had to put a 1ms delay before sending a packet, because `HardwareSerial`
doesn't like talking right after a call to `setPins`.
I don't love that, and would like to see it go away or at least get reduced.

## In the end, basic kinda working example
[mtfurlan/arduino-sbus-test](https://github.com/mtfurlan/arduino-sbus-test)
