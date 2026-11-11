# Troubleshooting — ASUS VivoBook 14 X415JA

---

## Before anything else

Boot verbose: in the OpenCore picker press **Space** on the entry, enable verbose, boot.
A photograph of the last lines beats guessing. Also check that the BIOS still matches
[BIOS_SETTINGS.md](BIOS_SETTINGS.md) — a BIOS update silently resets everything.

---

## Boot problems

| Symptom | Cause | Fix |
|---------|-------|-----|
| No picker, straight to Windows | Fast Boot or CSM on, wrong boot entry | Disable both, pick the UEFI USB entry at F8 |
| Picker appears, macOS entry missing | `ScanPolicy` too strict, or the volume is not APFS | Reset NVRAM from the picker, verify the install volume |
| Hangs at `EB|#LOG:EXITBS:START` | VT-d on, or memory-map quirk mismatch | Disable VT-d, keep `DisableIoMapper` on |
| Hangs at `apfs_module_start` | Storage controller issue | SATA AHCI, Above 4G Decoding on |
| Black screen after the picker, no text | Graphics driver loaded and failed | Boot with `-igfxvesa` to reach the desktop, then fix the framebuffer |
| Panic in `AppleIntel*Graphics` | Wrong platform/device ID or DVMT too low | Restore `01005c8a` / `5c8a0000`, raise DVMT to 128M |
| Panic in `AppleACPIPlatform` | SSDT does not match the board | Disable SSDTs one by one, starting with `MaLd0n.aml` |
| Panic in `VoodooI2C` | Trackpad conflict | Disable `VoodooI2CELAN` and `VoodooI2CHID`, boot, re-add one at a time |
| Panic in `AirportRTW` | Corrupt or mismatched kext | Re-copy `AirportRTW.kext` 2.3.1, keep `SecureBootModel = Disabled` |
| Boots but no graphics acceleration | `WhateverGreen-HDMIB` not loading | Check `kextstat`, check the kext is enabled in `Kernel → Add` |

### Reset NVRAM

The picker includes `ResetNvramEntry.efi`. Select it once, then boot normally. This clears
`boot-args` you may have set accidentally, so re-check them afterwards.

---

## Hardware

### No WiFi

```bash
kextstat | grep -i airportrtw
system_profiler SPAirPortDataType
ioreg -l | grep -i "pci10ec,c821"
```

Only `AirportRTW` (plus `Lilu` and `AMFIPass`) is needed. Load order must be
`Lilu → AMFIPass → AirportRTW`, and `SecureBootModel` must be `Disabled`.
`IOSkywalkFamily` and `IO80211FamilyLegacy` are leftovers in `Kexts/` and are **not**
injected — if you enabled them, disable them again.

Expected hardware: `10ec:c821` (RTL8821CE), subsystem `1a3b:3040`. If the card is absent
from `system_profiler`, check that WiFi is enabled in BIOS. On Sequoia 15.2+ the driver
runs its experimental native frontend; see
[souissiak1-maker/AirportRTW](https://github.com/souissiak1-maker/AirportRTW).

### No Bluetooth

Bluetooth runs on the onboard Realtek combo (`13d3:3529`) with `BlueToolFixup` and
`RealtekBluetoothFirmware` loaded. macOS reports the chipset as `THIRD_PARTY_DONGLE`
because it is not an Apple radio — that label does not mean a USB dongle is plugged in.

The radio also needs the **patched** `AirportRTW.kext` from this repo: upstream 2.3.1
only enables WiFi/BT coexistence for one specific PCI ID, and the binary here extends that
to `10ec:c821`. With a stock build, expect the two radios to interfere. AirDrop is still
not working; pairing, audio, file transfer and input devices are.

```bash
system_profiler SPBluetoothDataType
system_profiler SPUSBDataType | grep -A6 -i bluetooth
log show --predicate 'process == "bluetoothd"' --last 5m
```

### No audio

```bash
system_profiler SPAudioDataType
```

Confirm `layout-id 66` is set on `PciRoot(0x0)/Pci(0x1F,0x3)` and `alcverbs=1` is in
`boot-args`. If the device shows up but produces no sound, try other AppleALC layouts for
this codec (3, 11, 13, 21, 66) one at a time with a reboot between.

`SimpleHDA.kext` is present but disabled on purpose. Enabling it while `AppleALC` also
handles the codec is a common cause of silence.

### Trackpad not working

Check that `VoodooI2C`, `VoodooI2CELAN` and `VoodooI2CHID` are all loaded, and that the
I2C/GPIO hotpatches in `MaLd0n.aml` are enabled. `SSDT-SPI5.aml` also matters for this
board's I2C path.

```bash
ioreg -l | grep -i -E "i2c|elan"
log show --predicate 'process == "VoodooI2C"' --last 5m
```

### Battery missing or wrong

`SMCBatteryManager` must load, and the EC must be readable (`ECEnabler`). If the percentage
is stuck, do a full discharge/recharge cycle once to recalibrate.

### Brightness keys do nothing

`BrightnessKeys` must load and `SSDT-PNLF` must be enabled. Verify the slider itself works
in Control Center first; if the slider works but the keys do not, it is the kext, not the
ACPI.

### HDMI has no signal

Check the module is actually live:

```bash
ioreg -l | grep HDMIB
```

- No `HDMIB-*` keys → the kext is not loading, or `-igfxhdmib` is missing from
  `boot-args`. Boot args must be edited in `config.plist`; OpenCore's NVRAM delete
  removes values set with `nvram`.
- `HDMIB-port ... NOT HDMI` → the `framebuffer-patch0-find` / `-replace` pair is missing
  or wrong, so the connector is still DP.
- Keys present but no picture → try another cable and another display; only 1360×768 has
  been tested so far.

### HDMI audio does not work

That is expected on the current build: HDMI audio is **not solved yet**. Use the 3.5 mm
jack or a USB audio device. Do not spend time on `layout-id` changes for this — the
limitation is in the HDMI module, not in `AppleALC`.

### Some USB ports dead

`USBMap.kext` matches one specific port layout. Remap with
[USBToolBox](https://github.com/USBToolBox/tool) and replace the kext; do not patch the
port limit instead.

### Sleep wakes immediately

```bash
pmset -g log | grep -i "wake reason" | tail -20
```

Common causes: a USB device signalling wake, Wake on LAN in BIOS, or Bluetooth. Unplug
peripherals, disable Wake on LAN, retest. If it still wakes, check `DarkWake` activity
with `pmset -g log`.

### Sleep results in a reboot

Hibernation is writing an image the firmware cannot resume. Set:

```bash
sudo pmset -a hibernatemode 0 autopoweroff 0 standby 0
```

---

## Useful commands

```bash
kextstat | grep -v com.apple            # loaded third-party kexts
nvram boot-args                         # current boot arguments
ioreg -l | grep -i pnlf                 # backlight device
csrutil status                          # SIP
pmset -g                                # power settings
log show --last 10m --style syslog      # recent system log
```

---

## Asking for help

Include: laptop model, CPU, BIOS version, OpenCore version, macOS version, what you
changed last, a verbose boot photo, and your `config.plist` **with serial, MLB, UUID and
ROM removed**. Never post those four values.
