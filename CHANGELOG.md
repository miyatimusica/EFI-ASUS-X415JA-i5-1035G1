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

### Kexts (25)

| Kext | Version | Role |
|------|---------|------|
| Lilu | 1.7.2 | Patch engine |
| VirtualSMC | 1.3.8 | SMC emulation |
| SMCProcessor | 1.3.8 | CPU sensors |
| SMCBatteryManager | 1.3.8 | Battery |
| SMCLightSensor | 1.3.8 | Ambient light |
| WhateverGreen-HDMIB | 1.7.2 | Fork of WhateverGreen with the Ice Lake HDMI module (`-igfxhdmib`) |
| AppleALC | 1.9.8 | Audio |
| AsusSMC | 1.4.1 | ASUS EC keys |
| ECEnabler | 1.0.6 | Embedded controller reads |
| CPUFriend | 1.3.0 | Power-management tuning |
| CPUFriendDataProvider | 1.0.1 | Frequency profile |
| CpuTscSync | 1.1.3 | TSC sync |
| NVMeFix | 1.1.4 | NVMe power management |
| RestrictEvents | 1.1.7 | Telemetry / CPU-name patches |
| AMFIPass | 1.4.1 | AMFI bypass |
| AirportRTW | 2.3.1 | RTL8821CE WiFi + Bluetooth coexistence (souissiak1-maker fork, GPL-2.0, **locally patched** — see below) |
| BlueToolFixup | 2.7.2 | Bluetooth fixes |
| RealtekBluetoothFirmware | 1.0.2 | Realtek BT firmware |
| RealtekRTL8111 | 3.0.0 | Ethernet |
| VoodooI2C | 2.9.1 | I2C bus |
| VoodooI2CHID | 1.0 | ELAN trackpad (HID-over-I2C) |
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
1360×768, speakers / 3.5 mm jack / mic, boot chime with volume carried across sessions,
WiFi, Bluetooth, Ethernet, ELAN trackpad, keyboard and Fn keys, battery, sleep/wake, USB
ports, NVMe, webcam.

### Local modifications

`AirportRTW.kext` is not the stock 2.3.1 binary. Upstream enables WiFi/Bluetooth
coexistence for a single PCI ID; this build extends it to the RTL8821CE in this machine
(`10ec:c821`), which is what makes WiFi and Bluetooth usable at the same time. The change
is local and not upstreamed — replacing the kext with an official build loses it.

### Removed in this cleanup

Four kexts were sitting in `Kexts/` without being injected:

| Removed | Why |
|---------|-----|
| `IOSkywalkFamily.kext` | Not referenced by `Kernel → Add`; `AirportRTW` does not need it |
| `IO80211FamilyLegacy.kext` | Same — leftover from an earlier WiFi setup (11 MB) |
| `VoodooI2CELAN.kext` | Not injected; the ELAN trackpad runs through `VoodooI2CHID` |
| `SimpleHDA.kext` | Was disabled in config; audio works with `AppleALC` alone (4.3 MB) |

A disabled framebuffer patch with no comment was also dropped from `Kernel → Patch`.
The EFI went from 52 MB to 36 MB with no behavioural change.

### Known limitations

- HDMI audio: not working yet.
- HDMI resolutions above 1360×768: pending testing, not confirmed broken.
- AirDrop does not work yet; the rest of Bluetooth does (pairing, audio, file transfer,
  input devices) alongside WiFi.
- SD card reader: enumerates as a USB card reader (`0bda:0129`), but has not been tested
  with a card inserted.
- Fingerprint reader: no driver exists; not covered.
- `USBMap.kext` matches this exact port layout only.
- SMBIOS values are placeholders and must be regenerated before use.

---

## Credits

- [Acidanthera](https://github.com/acidanthera) — OpenCorePkg, Lilu, VirtualSMC, AppleALC,
  WhateverGreen (base of the HDMIB fork), NVMeFix, RestrictEvents, CPUFriend, CpuTscSync,
  ECEnabler, AMFIPass
- [Dortania](https://dortania.github.io/OpenCore-Install-Guide/) — install guide and
  troubleshooting reference
- [VoodooI2C](https://github.com/VoodooI2C) — VoodooI2C, VoodooI2CHID
- [Acidanthera / RehabMan lineage](https://github.com/RehabMan) — VoodooPS2Controller
- [souissiak1-maker / AirportRTW](https://github.com/souissiak1-maker/AirportRTW)
  (GPL-2.0) — Realtek RTW88/RTW89 driver, built on the
  [itlwm](https://github.com/OpenIntelWireless/itlwm) architecture
- RealtekBluetoothFirmware and BlueToolFixup authors — Bluetooth support
- [MaLd0n](https://www.olarila.com/) — DSDT hotpatch set
- AsusSMC authors — ASUS EC keys
- [corpnewt](https://github.com/corpnewt) — GenSMBIOS, ProperTree, USBMap, gibMacOS
