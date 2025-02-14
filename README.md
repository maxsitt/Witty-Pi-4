# Witty-Pi-4 for the Insect Detect DIY camera trap

<img src="https://raw.githubusercontent.com/maxsitt/insect-detect-docs/main/docs/assets/logo.png" width="540">

[![DOI PLOS ONE](https://img.shields.io/badge/PLOS%20ONE-10.1371%2Fjournal.pone.0295474-BD3094)](https://doi.org/10.1371/journal.pone.0295474)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://choosealicense.com/licenses/mit/)

This fork of the [Witty-Pi-4](https://github.com/uugear/Witty-Pi-4) repository
includes modifications to adapt the software installation and behaviour to the
[Insect Detect](https://maxsitt.github.io/insect-detect-docs/) DIY camera trap.

The current [modifications](https://github.com/uugear/Witty-Pi-4/compare/main...maxsitt:Witty-Pi-4:main) include:

- [`Software/install.sh`](https://github.com/maxsitt/Witty-Pi-4/blob/main/Software/install.sh)
- [`Software/wittypi/beforeShutdown.sh`](https://github.com/maxsitt/Witty-Pi-4/blob/main/Software/wittypi/beforeShutdown.sh)
- [`README.md`](https://github.com/maxsitt/Witty-Pi-4/blob/main/README.md)

---

# Witty-Pi-4

Witty Pi is an add-on board that adds realtime clock and power management to your Raspberry Pi. It can define your Raspberry Pi’s ON/OFF sequence, and significantly reduce the energy usage. Witty Pi 4 is the fourth generation of Witty Pi and it has these hardware resources onboard:

*   Factory calibrated and temperature compensated realtime clock with ±2ppm accuracy.
*   Dedicated temperature sensor with 0.125 °C resolution.
*   On-board DC/DC converter that accepts up to 30V DC.
*   AVR 8-bit microcontroller (MCU) with 8 KB programmable flash.

![](https://user-images.githubusercontent.com/6317566/174240816-01f8ac49-55d1-486a-bfef-b6471371125b.png)

Witty Pi 4 supports all Raspberry Pi models with 40-pin header, including A+, B+, 2B, Zero, Zero W, Zero 2 W, 3B, 3B+ and 4B.

### **References:**

*   [Witty Pi 4 Product Page](https://www.uugear.com/product/witty-pi-4/)
*   [Witty Pi 4 User Manual](https://www.uugear.com/doc/WittyPi4_UserManual.pdf)


### Modify the Firmware:
If you want to change the behavior of Witty Pi 4, you can modify the firmware, compile it and upload to your Witty Pi 4.

To compile the firmware, you need to install [ATtinyCore (V1.5.2)](https://github.com/SpenceKonde/ATTinyCore) in your Arduino IDE.

Here are the configurations on your Arduino IDE:

![](https://github.com/uugear/Witty-Pi-4/raw/main/Firmware/WittyPi4_Arduino_Settings.png)

To upload the firmware to Witty Pi, you can follow [this document](https://www.uugear.com/portfolio/compile-flash-firmware-for-witty-pi-4/).
