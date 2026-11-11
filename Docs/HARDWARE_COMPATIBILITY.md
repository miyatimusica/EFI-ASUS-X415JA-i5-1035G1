# Hardware compatibility — ASUS VivoBook 14 X415JA

Everything marked ✅ was verified on the machine this EFI came from, running macOS
Sequoia 15.8.3. ⚠️ means partially working or verified only in specific conditions.
❌ means no driver exists.

| | |
|---|---|
| Model | ASUS VivoBook 14 X415JA |
| CPU | Intel Core i5-1035G1 (Ice Lake, 4C/8T) |
| iGPU | Intel UHD Graphics G1 |
| RAM | 20 GB (4 GB soldered + 16 GB SODIMM) |
| Storage | Kingston NV2 NVMe (DRAM-less) |
| WiFi | Realtek RTL8821CE, `10ec:3040` |
| SMBIOS | `MacBookPro16,2` |

---

## Status matrix

**Legend** — ✅ verified working · ⏳ works within the stated limits · ⚠️ partial or
specific conditions · ❌ not supported

| Component | Status | Driver / detail |
|-----------|:--:|-----------------|
| 🧠 CPU power management | ✅ | XCPM + Speed Shift, `CPUFriend` profile |
| 🎨 iGPU acceleration | ✅ | Metal, hardware H.264/HEVC decode |
| 💻 Internal display | ✅ | 1920×1080, no scaling patches needed |
| 🔆 Brightness control | ✅ | `SSDT-PNLF`, slider and Fn keys |
| 🖥️ HDMI video | ⏳ | Works at 1360×768 (only mode tested); higher resolutions pending testing |
| 🔊 HDMI audio | ❌ | Not solved by the HDMIB module yet |
| 🎧 Speakers / 3.5 mm jack | ✅ | `AppleALC`, `layout-id 66`; jack output confirmed |
| 🎙️ Internal mic | ✅ | |
| 📶 WiFi | ✅ | `AirportRTW` 2.3.1 (souissiak1-maker fork), RTL8821CE |
| 🔵 Bluetooth | ✅ | Onboard Realtek combo (`13d3:3529`), needs the patched `AirportRTW` for coexistence with WiFi. AirDrop still not working |
| 🌐 Ethernet | ✅ | `RealtekRTL8111` 3.0.0 |
| 🖱️ Trackpad | ✅ | ELAN I2C, `VoodooI2C` 2.9.1 + `VoodooI2CHID` (ELAN is HID-over-I2C) |
| ⌨️ Keyboard | ✅ | `VoodooPS2Controller` 2.3.8 |
| 🔆 Fn brightness keys | ✅ | `BrightnessKeys` |
| 🔋 Battery / AC status | ✅ | `SMCBatteryManager` |
| 😴 Sleep / wake | ✅ | Lid close and power button |
| 🔌 USB ports | ✅ | `USBMap.kext` for this chassis |
| 💾 NVMe | ✅ | `NVMeFix` 1.1.4 |
| 📷 Webcam | ✅ | Native UVC |
| 💳 SD card reader | ⏳ | USB card reader (`0bda:0129`, USB2.0-CRW); enumerates, not yet tested with a card |
| 👆 Fingerprint reader | ❌ | No driver exists; not covered |
| ⚡ Thunderbolt | ❌ | Not present on this model |

---

## Graphics

The iGPU uses platform ID `01005c8a` with device ID `5c8a0000`, plus framebuffer
patches, `framebuffer-stolenmem`, `enable-dvmt-calc-fix`, `enable-cdclk-frequency-fix`,
`enable-dbuf-early-optimizer` and `enable-cfl-backlight-fix`.

These values are specific to **UHD Graphics G1 on Ice Lake**. Do not copy them to a
Tiger Lake or Comet Lake machine.

### HDMI

The port is enabled by the `WhateverGreen-HDMIB` fork with `-igfxhdmib` plus the
connector patch in `DeviceProperties` — see
[the README](../README.md#hdmi-on-ice-lake-the-whatevergreen-hdmib-fork).

- **Video:** confirmed at 1360×768, the only mode tested so far. Higher resolutions are
  pending testing, not confirmed broken.
- **Audio over HDMI:** not working yet. The 3.5 mm jack and USB audio do work.

## Audio

`layout-id 66` (0x42) on `PciRoot(0x0)/Pci(0x1F,0x3)`, with `alcverbs=1` in boot args.
Audio is handled by `AppleALC` alone.

If audio breaks after a macOS update, try other AppleALC layouts for this codec
(3, 11, 13, 21, 66) one at a time, rebooting between changes.

## WiFi

Realtek RTL8821CE (`10ec:c821`) driven by `AirportRTW` 2.3.1
([souissiak1-maker/AirportRTW](https://github.com/souissiak1-maker/AirportRTW),
GPL-2.0). One kext holds the RTW88 and RTW89 backends and selects one by PCI ID; the
8821CE uses the RTW88 path. On Sequoia 15.2+ it runs the project's experimental native
Wi-Fi frontend.

Load order is `Lilu → AMFIPass → AirportRTW`, with `SecureBootModel = Disabled`.
`IOSkywalkFamily.kext` and `IO80211FamilyLegacy.kext` are leftovers in `Kexts/` and are
**not** injected — this driver does not need them.

Reported firmware string on the reference machine: `AirportRTW2.3.1`.

## Bluetooth

The same combo chip provides Bluetooth over USB, enumerated as `13d3:3529` (AzureWave
module, Realtek silicon). It runs with `BlueToolFixup` and `RealtekBluetoothFirmware`.

The bundled `AirportRTW.kext` is **patched locally**: upstream 2.3.1 arms WiFi/BT
coexistence for one specific PCI ID only, and this binary extends it to `10ec:c821`. Both
radios then work together — pairing, audio, file transfer and input devices. **AirDrop is
still not working.**

## USB

`USBMap.kext` was built for this exact port layout. If your X415JA has a different
board revision, remap with [USBToolBox](https://github.com/USBToolBox/tool) or
[USBMap](https://github.com/corpnewt/USBMap) and replace the kext.

## Not covered

X415EA (Tiger Lake), X415EP (Tiger Lake + MX330/350) and any X415 with a different CPU
are **not** supported by this EFI. The ACPI tables and framebuffer data would need to be
rebuilt for those platforms.
