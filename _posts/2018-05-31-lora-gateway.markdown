---
layout: post
title:  "Lora Gateway Research"
categories: lora
---

Trying to get to a lorawan gateway.

Got the [Low Cost LoRa Gateway](https://github.com/CongducPham/LowCostLoRaGw) running, but no lorawan.


<!--excerpt-->

lorawan client with the st lora dev board B-L072Z-LRWAN1
---

```
git clone https://github.com/ARMmbed/mbed-os-example-lorawan
cd mbed-os-example-lorawan
mbed deploy
#or do the mbed import thing

connect dev board
mbedls -u # should show device
mbed config TARGET DISCO_L072CZ_LRWAN1
mbed config TOOLCHAIN GCC_ARM

mbed compile --flash
# [mbed] ERROR: Unable to reset the target board connected to your system.
# Try updating firmware with tool here: https://my.st.com/content/my_st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-programmers/stsw-link007.license=1527606754349.html
remount
# Still doesn't work

# give up and export
mbed export -i make_gcc_arm
make
# edit makefile to include
#     STLINK=/home/mark/advanced/b2v/lora/stm32/stlink/build/Release
#     .PHONY: burn
#     burn: $(PROJECT).bin
#         $(STLINK)/st-flash write $(PROJECT).bin 0x8000000
make burn
minicom -D /dev/ttyACM0
#set serial rate to 230400 (115200*2 because that's the default?)
#It works!
```
I wasn't able to get the thing to connect to the machineQ network, but I think that's a range/coverage issue, not a authentication issue.


setting up our own gateway
---

Lora gateway with two libelium sx1272 modules (note, **not** lorawan)
* [https://github.com/CongducPham/LowCostLoRaGw](https://github.com/CongducPham/LowCostLoRaGw)
* [http://cpham.perso.univ-pau.fr/LORA/RPIgateway.html](http://cpham.perso.univ-pau.fr/LORA/RPIgateway.html)
* Modify the arduino code to be FCC, 900MHz, not paboost.
* **Ignore config file** on the rpi, run with `sudo ./lora_gateway --mode 1 --freq 913.88`
* PingPong doesn't ACK back from the gateway, but the gateway does receive.
* But again, thisis lora not lorawan so not terribly useful.


Actual lorawan gateways:
---

* 20, single channel
    * [https://sandboxelectronics.com/?product=lorago-dock-915mhz-single-channel-lorawan-gateway](https://sandboxelectronics.com/?product=lorago-dock-915mhz-single-channel-lorawan-gateway)
    * open source?
    * code is open source.
    * sx1276 + esp8266
    * single channel, not a real gateway. Might be good enough for us though?
    * [assembly pdf](http://sandboxelectronics.com/wp-content/uploads/2017/09/LoRaGoDockAssembly.pdf)
    * [schematic](http://sandboxelectronics.com/wp-content/uploads/2017/09/LoRaGoDockSchematics.pdf)
    * [github](https://github.com/SandboxElectronics/LoRaGoDOCK-Gateway)
    * [ebay](https://www.ebay.com/itm/LoRaGo-Dock-915MHz-Single-Channel-LoRaWAN-Gateway-Based-on-SX1276-and-ESP8266/112777043755?epid=2265194658&hash=item1a42091f2b:g:HaQAAOSwWEZaav2U)
* 120USD, open source full gateway 915MHz
    * [https://www.tindie.com/products/will123321/sx1308-raspberry-pi-lora-gateway-board/](https://www.tindie.com/products/will123321/sx1308-raspberry-pi-lora-gateway-board/)
* 290 full gateway kit for 915MHz from seeed studio:
    * [https://www.seeedstudio.com/LoRa%2FLoRaWAN-Gateway-915MHz-for-Raspberry-Pi-3-p-2821.html](https://www.seeedstudio.com/LoRa%2FLoRaWAN-Gateway-915MHz-for-Raspberry-Pi-3-p-2821.html)
    * actually from risingHF (no price) http://www2.risinghf.com/#/product-details?product_id=6&lang=en
* ??? risingHF consumer product: http://www2.risinghf.com/#/product-details?product_id=10&lang=en
* 60 consumer gateway? https://www.robotshop.com/en/lg01-p-lora-gateway-915-mhz-north-america.html
* 300 pi hat gateway https://www.robotshop.com/en/915mhz-lora-gateway-raspberry-pi-hat.html
* 150 rak831 sx1301 based http://www.rakwireless.com/en/WisKeyOSH/RAK831
* 325 the things network gateway http://www.newark.com/the-things-network/ttn-gw-915/accessory-type-wireless-gateway/dp/05AC1807
    * this is the people who run the backend stuff a lot of people use
    * pretty much guarenteed to work?


The common one, the IMST iC880a is for the 861MHz spectrum, not usable in the USA.
The sandbox electronics LoRaGo thing claims to be pretty much the iC880a but for the 915MHz.
