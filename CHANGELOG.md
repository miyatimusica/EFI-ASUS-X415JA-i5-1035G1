# Changelog

All notable changes to this EFI are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] — 2026-11-10

First published dump of a working EFI, extracted from a live ASUS VivoBook 14 X415JA
running macOS Sequoia 15.8.3.

### Platform

- ASUS VivoBook 14 X415JA, Intel Core i5-1035G1 (Ice Lake), UHD Graphics G1
- 20 GB RAM (4 GB soldered + 16 GB SODIMM)
- Kingston NV2 NVMe SSD (DRAM-less)
- SMBIOS `MacBookPro16,2`
- OpenCore 1.0.8 (REL-108)
- macOS Sequoia 15.8.3 (24H314)

### Bootloader

- `OpenCore.efi` 1.0.8
- Drivers: `OpenRuntime.efi`, `OpenCanopy.efi`, `HfsPlus.efi`, `AudioDxe.efi`,
  `ResetNvramEntry.efi`
- Boot picker: OpenCanopy (graphical), `PickerMode = External`
- `SecureBootModel = Disabled`, `Vault = Optional`

### ACPI (11 tables)

`SSDT-PNLF`, `SSDT-RHUB`, `SSDT-USBX`, `SSDT-SRAM`, `SSDT-TERM`, `SSDT-DMAC`,
`SSDT-ALS0`, `SSDT-SBUS-MCHC`, `SSDT-HPET`, `SSDT-SPI5`, `MaLd0n.aml`.

`MaLd0n.aml` carries the DSDT hotpatches (RTC, HPET, USB, I2C/GPIO); the rest are
targeted fixes for backlight, USB power, SMBus and the ambient-light stub.

### Kexts (29)

| Kext | Version | Role |
|------|---------|------|
| Lilu | 1.7.2 | Patch engine |
| VirtualSMC | 1.3.8 | SMC emulation |
| SMCProcessor | 1.3.8 | CPU sensors |
| SMCBatteryManager | 1.3.8 | Battery |
| SMCLightSensor | 1.3.8 | Ambient light |
| WhateverGreen-HDMIB | 1.7.2 | Fork of WhateverGreen with the Ice Lake HDMI module (`-igfxhdmib`) |
| AppleALC | 1.9.8 | Audio |
| SimpleHDA | 1.0.0 | Present, **disabled** in config |
| AsusSMC | 1.4.1 | ASUS EC keys |
| ECEnabler | 1.0.6 | Embedded controller reads |
| CPUFriend | 1.3.0 | Power-management tuning |
| CPUFriendDataProvider | 1.0.1 | Frequency profile |
| CpuTscSync | 1.1.3 | TSC sync |
| NVMeFix | 1.1.4 | NVMe power management |
| RestrictEvents | 1.1.7 | Telemetry / CPU-name patches |
| AMFIPass | 1.4.1 | AMFI bypass |
| AirportRTW | 2.3.1 | RTL8821CE WiFi (souissiak1-maker fork, GPL-2.0) |
| IOSkywalkFamily | 1.0 | Present in `Kexts/`, **not injected** — leftover |
| IO80211FamilyLegacy | 12.0 | Present in `Kexts/`, **not injected** — leftover |
| BlueToolFixup | 2.7.2 | Bluetooth fixes |
| RealtekBluetoothFirmware | 1.0.2 | Realtek BT firmware |
| RealtekRTL8111 | 3.0.0 | Ethernet |
| VoodooI2C | 2.9.1 | I2C bus |
| VoodooI2CELAN | 1.0 | ELAN trackpad |
| VoodooI2CHID | 1.0 | I2C HID |
| VoodooPS2Controller | 2.3.8 | Keyboard |
| BrightnessKeys | — | Fn brightness keys |
| USBMap | 1.1 | Port map for this chassis |
| HoRNDIS | — | USB tethering |

### config.plist highlights

- `boot-args`: `keepsyms=1 -igfxblr -igfxbls -noDC9 TSC_sync_margin=0 alcverbs=1
  -igfxhdmib -igfxlowest -no-gfxsbv -igfxdvmt igfxfw=2`
- iGPU: `AAPL,ig-platform-id 01005c8a`, `device-id 5c8a0000`, framebuffer patches,
  `framebuffer-stolenmem`, `enable-dvmt-calc-fix`, `enable-cfl-backlight-fix`
- Audio: `layout-id 66` (0x42) on `PciRoot(0x0)/Pci(0x1F,0x3)`, `alc-verbs`
- Kernel quirks: `AppleXcpmCfgLock`, `AppleXcpmExtraMsrs`, `DisableIoMapper`,
  `PanicNoKextDump`, `PowerTimeoutKernelPanic`
- PCI device names set for SATA, USB, audio, iGPU, WiFi, NVMe, ME and SPI controllers

### Verified working

CPU power management, iGPU acceleration, internal display and brightness, HDMI video at
1360×768, speakers / 3.5 mm jack / mic, WiFi, Ethernet, ELAN trackpad, keyboard and Fn
keys, battery, sleep/wake, USB ports, NVMe, webcam.

### Known limitations

- HDMI audio: not working yet.
- HDMI resolutions above 1360×768: pending testing, not confirmed broken.
- Bluetooth verified only with a third-party USB dongle; onboard RTL8821CE BT untested.
- SD card reader: no usable driver.
- Fingerprint reader: no driver.
- `USBMap.kext` matches this exact port layout only.
- SMBIOS values are placeholders and must be regenerated before use.

---

## Credits

- [Acidanthera](https://github.com/acidanthera) — OpenCorePkg, Lilu, VirtualSMC, AppleALC,
  WhateverGreen (base of the HDMIB fork), NVMeFix, RestrictEvents, CPUFriend, CpuTscSync,
  ECEnabler, AMFIPass
- [Dortania](https://dortania.github.io/OpenCore-Install-Guide/) — install guide and
  troubleshooting reference
- [VoodooI2C](https://github.com/VoodooI2C) — VoodooI2C, VoodooI2CELAN, VoodooI2CHID
- [Acidanthera / RehabMan lineage](https://github.com/RehabMan) — VoodooPS2Controller
- [souissiak1-maker / AirportRTW](https://github.com/souissiak1-maker/AirportRTW)
  (GPL-2.0) — Realtek RTW88/RTW89 driver, built on the
  [itlwm](https://github.com/OpenIntelWireless/itlwm) architecture
- RealtekBluetoothFirmware and BlueToolFixup authors — Bluetooth support
- [MaLd0n](https://www.olarila.com/) — DSDT hotpatch set
- AsusSMC authors — ASUS EC keys
- [corpnewt](https://github.com/corpnewt) — GenSMBIOS, ProperTree, USBMap, gibMacOS
