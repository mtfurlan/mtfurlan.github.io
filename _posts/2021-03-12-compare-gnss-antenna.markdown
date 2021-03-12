---
layout: post
title:  "Comparing GNSS Antennas"
categories: gnss
---

Steps to compare GNSS antennas.

<!--excerpt-->

Basing this off the idea of comparing SNR proposed by [Tallysman GNSS](http://www.digikey.no/Web%20Export/Supplier%20Content/tallysman-1526/pdf/tallysman-comparing-gnss-antenna-performance.pdf)

Steps:
1. Log NMEA strings including G.GSV and G.RMC
2. Use the RMC times to make the start and stop the same for each file
3. Use [wolfgangr/perl-nmea](https://github.com/wolfgangr/perl-nmea) to plot the
  SNR for different satellites and log statistical data about them.
4. Higher is better.
   > To give some idea of values to be expected, 54dB is amazing, 53dB is excellent, 52dB is  good and  49/50dB  is  “ho-hum”.

   I didn't see anything above 46, but it's probably fine.

It also outputs some plots of SNR for a visual representation of the statistics.


