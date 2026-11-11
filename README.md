# ASUS VivoBook 14 X415JA — OpenCore EFI

[![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8-0078D4?logo=apple&logoColor=white)](https://github.com/acidanthera/OpenCorePkg)
[![macOS](https://img.shields.io/badge/macOS-Sequoia%2015.8.3-black?logo=apple)](https://www.apple.com/macos/)
[![SMBIOS](https://img.shields.io/badge/SMBIOS-MacBookPro16%2C2-FF6B6B)](https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/ice-lake.html)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

Working OpenCore EFI for the **ASUS VivoBook 14 X415JA** (Ice Lake, i5-1035G1), dumped
from a real, daily-driven install. Everything below was verified on the machine this
EFI was extracted from.

| | |
|---|---|
| **Laptop** | ASUS VivoBook 14 X415JA |
| **CPU** | Intel Core i5-1035G1 (Ice Lake, 4C/8T) |
| **iGPU** | Intel UHD Graphics G1 (`01005c8a` / `5c8a0000`) |
| **RAM** | 20 GB (4 GB soldered + 16 GB SODIMM) |
| **Storage** | Kingston NV2 NVMe (DRAM-less) |
| **WiFi** | Realtek RTL8821CE (`10ec:3040`) |
| **Audio** | Realtek codec, `layout-id 66` (0x42) |
| **SMBIOS** | `MacBookPro16,2` |
| **OpenCore** | 1.0.8 (REL-108) |
| **macOS** | Sequoia 15.8.3 (24H314) |

## ⚠️ Generate your own SMBIOS before the first boot

The `config.plist` ships **placeholder** identifiers, so macOS will boot but iServices
(App Store, iMessage, FaceTime, iCloud) will not work until you replace them.

Under `PlatformInfo → Generic`, set all four to values generated for **your** machine:

| Key | What to put there |
|-----|-------------------|
| `SystemSerialNumber` | serial generated for `MacBookPro16,2` |
| `MLB` | board serial from the same generation |
| `SystemUUID` | a fresh UUID |
| `ROM` | 6 bytes, e.g. your `en0` MAC without colons |

Use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) and
[ProperTree](https://github.com/corpnewt/ProperTree) — full steps in
[Quick start](#quick-start) below. Never sign in to iCloud with the placeholders, and
never publish your own values afterwards.

---

## Status

**Legend** — ✅ verified working · ⏳ works, but only within the limits stated · ⚠️ partial
or only under specific conditions · ❌ not supported

| Component | Status | Notes |
|-----------|:--:|-------|
| 🧠 CPU power management | ✅ | XCPM, Speed Shift, C-states |
| 🎨 iGPU acceleration | ✅ | Metal, hardware video decode |
| 💻 Internal display + brightness | ✅ | `SSDT-PNLF`, brightness keys |
| 🖥️ HDMI video | ⏳ | Verified at 1360×768 — the only mode tested so far. Higher resolutions are still pending testing, not confirmed broken |
| 🔊 HDMI audio | ❌ | Not solved by the HDMIB module yet |
| 🎧 Speakers, 3.5 mm jack, mic | ✅ | `AppleALC`, `layout-id 66`, `alcverbs=1`; jack output confirmed |
| 📶 WiFi | ✅ | `AirportRTW` 2.3.1 + `IOSkywalkFamily` |
| 🔵 Bluetooth | ⚠️ | Verified with a third-party USB dongle; onboard BT untested |
| 🌐 Ethernet | ✅ | `RealtekRTL8111` 3.0.0 |
| 🖱️ Trackpad (ELAN I2C) | ✅ | `VoodooI2C` 2.9.1 + `VoodooI2CELAN` |
| ⌨️ Keyboard + Fn keys | ✅ | `VoodooPS2Controller` 2.3.8 |
| 🔋 Battery / AC | ✅ | `SMCBatteryManager` |
| 😴 Sleep / wake | ✅ | Lid and power button |
| 🔌 USB ports | ✅ | `USBMap.kext` for this exact port layout |
| 💾 NVMe | ✅ | `NVMeFix` |
| 📷 Webcam | ✅ | Native UVC |
| 💳 SD card reader | ❌ | No usable driver |
| 👆 Fingerprint reader | ❌ | No driver |

Other X415 variants (X415EA, X415EP, other CPUs) are **not** covered by this EFI.
The ACPI and framebuffer data are specific to the i5-1035G1 / UHD G1.

---

## Quick start

### 1. Build the installer USB

```bash
# 16 GB+ USB. This erases it.
diskutil list
sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
  --volume /Volumes/USB --nointeraction
```

### 2. Mount its EFI partition and copy this EFI

```bash
diskutil list                       # find the USB, e.g. disk4s1
sudo diskutil mount disk4s1
cp -R EFI /Volumes/EFI/
```

The result must be `/Volumes/EFI/EFI/BOOT/BOOTx64.efi` and `/Volumes/EFI/EFI/OC/config.plist`.

### 3. Generate your own SMBIOS

Use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) for `MacBookPro16,2`, then replace
these keys under `PlatformInfo → Generic` in `config.plist` with
[ProperTree](https://github.com/corpnewt/ProperTree):

- `SystemSerialNumber`
- `MLB`
- `SystemUUID`
- `ROM` (6 bytes, e.g. your `en0` MAC without colons)

### 4. BIOS

Press **F2** at power-on. Required:

| Setting | Value |
|---------|-------|
| Secure Boot | Disabled |
| Fast Boot | Disabled |
| CSM / Legacy boot | Disabled |
| VT-d | Disabled |
| XHCI Hand-off | Enabled |
| SATA mode | AHCI |
| DVMT Pre-Allocated | 64M |
| Above 4G Decoding | Enabled |

Full list with menu paths: [Docs/BIOS_SETTINGS.md](Docs/BIOS_SETTINGS.md).

### 5. Install

Press **F8** at power-on, pick the UEFI USB entry, then *Install macOS Sequoia* in the
OpenCore picker. Full walkthrough: [Docs/INSTALLATION.md](Docs/INSTALLATION.md).

---

## Repository layout

```
EFI/
├── BOOT/
│   └── BOOTx64.efi
└── OC/
    ├── OpenCore.efi
    ├── config.plist
    ├── ACPI/       11 SSDTs (PNLF, RHUB, USBX, SRAM, TERM, DMAC,
    │               ALS0, SBUS-MCHC, HPET, SPI5, MaLd0n.aml)
    ├── Drivers/    OpenRuntime, OpenCanopy, HfsPlus,
    │               AudioDxe, ResetNvramEntry
    ├── Kexts/      29 kexts
    └── Resources/  OpenCanopy theme assets
```

280 files, ~52 MB.

---

## What is configured, and why

**Boot args**

```
keepsyms=1 -igfxblr -igfxbls -noDC9 TSC_sync_margin=0 alcverbs=1
-igfxhdmib -igfxlowest -no-gfxsbv -igfxdvmt igfxfw=2
```

`-igfxblr` / `-igfxbls` fix backlight registers on Ice Lake, `-igfxhdmib` activates the
HDMIB module that lights up the HDMI port, `igfxfw=2` loads the GuC firmware,
`alcverbs=1` enables AppleALC verb support for layout 66.

**iGPU** — `AAPL,ig-platform-id = 01005c8a`, `device-id = 5c8a0000`, plus framebuffer
patches, `framebuffer-stolenmem`, `enable-dvmt-calc-fix` and `enable-cfl-backlight-fix`.

**Audio** — `layout-id 66` on `PciRoot(0x0)/Pci(0x1F,0x3)`. `SimpleHDA.kext` is present
but **disabled** in `config.plist`; audio is handled by `AppleALC` alone.

**Kernel quirks** — `AppleXcpmCfgLock`, `AppleXcpmExtraMsrs`, `DisableIoMapper`,
`PanicNoKextDump`, `PowerTimeoutKernelPanic`.

**ACPI** — `MaLd0n.aml` carries the DSDT hotpatches; the SSDTs cover backlight, USB
power, SMBus, HPET, DMAC, SPI and the ambient-light stub.

---

## HDMI on Ice Lake: the `WhateverGreen-HDMIB` fork

This EFI does **not** use upstream WhateverGreen. It uses `WhateverGreen-HDMIB.kext`, a
fork that adds a header-only module (`kern_igfx_hdmib.hpp`) hooked into
`IGFX::processKext` for `AppleIntelICLLPGraphicsFramebuffer`. Ice Lake laptops expose
their HDMI port on a DDI the stock driver never lights up; the module rewrites the
connector, reads the sink EDID and drives hotplug so the port behaves like a real HDMI
output.

It only activates with the boot argument `-igfxhdmib`, which is already in this
`config.plist`. Without it the kext behaves like stock WhateverGreen.

The port mapping itself lives in `DeviceProperties`, not in the module. For
`PciRoot(0x0)/Pci(0x2,0x0)` this EFI carries a 24-byte `framebuffer-patch0-find` /
`framebuffer-patch0-replace` pair that turns *ddi 3, pin 10, class 1, pad 1, type 0x400
(DP), flags 0x2c1* into *ddi 1, pin 2, class 2, pad 0, type 0x800 (HDMI), flags 0x2c1*.
`-igfxhdmib` plus that patch is the whole trick; if you remove one, HDMI stops working
and `ioreg` reports `HDMIB-port ... NOT HDMI`.

Optional module arguments: `igfxhdmib-ddi=N`, `igfxhdmib-fb=N`,
`igfxhdmib-bootdetect=S`, `igfxhdmib-hwcursor=0|1`, `igfxhdmib-swcursor=1`,
`igfxhdmib-aux=0`, `igfxhdmib-dc6fix=0`, `igfxhdmib-edid-fallback=1`,
`igfxhdmib-force=1` (run on an unverified Darwin layout — own risk).

Check that the module is live:

```bash
ioreg -l | grep HDMIB
# HDMIB-version = 1.0-rc3
# HDMIB-layout  = macOS 15 (Sequoia)
# HDMIB-hooks   = installed
# HDMIB-port    = ddi=1 gmbus=2 class=2 type=0x800 flags=0x2c1 OK (HDMI)
```

Where the current build stands, stated plainly:

- ✅ HDMI **video** works. The only mode tested so far is **1360×768**; higher
  resolutions are **pending testing**, not confirmed broken.
- ❌ HDMI **audio** is not solved by the module yet. Use the 3.5 mm jack or USB audio.
- ✅ The internal panel, the 3.5 mm jack and the internal mic all work normally.
- ℹ️ Only platform ID `01005c8a` is verified. Other Ice Lake IDs need the porting guide.
- ℹ️ The module stays inert (no panic) on Darwin versions missing from its offset table,
  so run the layout verifier before any macOS upgrade.

The fork, its build script, the offset tables and the setup/verify tools live in a
separate repository: **[WhateverGreen-HDMIB →](https://github.com/miyatimusica/REPO-HDMIB)**
*(link to be completed)*. Note that WhateverGreen is GPL-2.0 and the BSD-3 module is
compiled into it, so the resulting binary is distributed under the GPL.

---

## Post-install

Copy the EFI to the internal disk, enable TRIM, tune sleep, verify hardware:
[Docs/POST_INSTALL.md](Docs/POST_INSTALL.md).

## Updating

OpenCore, kexts and macOS upgrades: [Docs/UPDATING.md](Docs/UPDATING.md).

## Troubleshooting

[Docs/TROUBLESHOOTING.md](Docs/TROUBLESHOOTING.md).

---

## Releases

Releases attach the EFI as a ZIP plus a SHA-256 checksum:

```bash
curl -LO https://github.com/miyatimusica/EFI-ASUS-X415JA-i5-1035G1/releases/latest/download/EFI.zip
curl -LO https://github.com/miyatimusica/EFI-ASUS-X415JA-i5-1035G1/releases/latest/download/EFI-SHA256.txt
shasum -a 256 -c EFI-SHA256.txt
```

To rebuild the archive locally:

```bash
./scripts/make-release.sh
```

---

## License

MIT — see [LICENSE](LICENSE). OpenCore, Lilu, VirtualSMC, AppleALC, WhateverGreen and the
rest belong to their respective authors; see [CHANGELOG.md](CHANGELOG.md#credits).

> This EFI is published for study and reuse. Hackintoshing violates Apple's EULA.
> No warranty; you own the consequences of flashing your firmware and erasing your disks.
