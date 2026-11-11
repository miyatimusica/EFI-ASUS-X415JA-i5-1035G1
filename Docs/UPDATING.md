# Updating OpenCore, kexts and macOS

Rule zero: **back up the working EFI first.**

```bash
sudo diskutil mount disk0s1
cp -R /Volumes/EFI/EFI ~/EFI-backup-$(date +%F)
```

Keep a bootable USB with the same EFI. If an update bricks the boot, you recover from it.

---

## Updating OpenCore

1. Download the release from
   [OpenCorePkg releases](https://github.com/acidanthera/OpenCorePkg/releases).
2. Replace `EFI/OC/OpenCore.efi`.
3. Replace every file in `EFI/OC/Drivers/` with the matching version. Do not mix
   versions of OpenRuntime with OpenCore — they must match.
4. Replace `EFI/OC/Resources/` if you use OpenCanopy and the theme format changed.
5. Compare your `config.plist` against `Docs/Sample.plist` from the same release. New
   releases add keys; missing keys fail validation.
6. Validate:

```bash
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

7. Reboot and test before deleting the backup.

> Upstream OpenCore changes break things far more often than kext updates do. If you are
> not chasing a specific fix, staying on a working version is a valid strategy.

## Updating kexts

Only update the kexts you need, one group at a time:

| Group | Kexts |
|-------|-------|
| Core | Lilu, VirtualSMC (+ SMCProcessor, SMCBatteryManager, SMCLightSensor) |
| Graphics | WhateverGreen-HDMIB |
| Audio | AppleALC |
| WiFi | AirportRTW, IOSkywalkFamily, IO80211FamilyLegacy |
| Bluetooth | BlueToolFixup, RealtekBluetoothFirmware |
| Input | VoodooI2C, VoodooI2CELAN, VoodooI2CHID, VoodooPS2Controller |
| Power | CPUFriend, CPUFriendDataProvider, NVMeFix, ECEnabler, CpuTscSync |
| Other | RestrictEvents, AMFIPass, AsusSMC, BrightnessKeys, USBMap, HoRNDIS |

Notes:

- Lilu must load before anything that depends on it.
- `AirportRTW`, `IOSkywalkFamily` and `IO80211FamilyLegacy` are version-coupled. Update
  them together or not at all.
- `CPUFriendDataProvider` is generated for a specific CPU and SMBIOS. Do not replace it
  with someone else's file.
- `USBMap.kext` is hardware-specific. Updating it means remapping your ports.

After replacing kexts, check the load order in `config.plist → Kernel → Add` and reboot.

## Updating macOS

### Minor updates (15.x → 15.y)

Usually fine as-is:

1. Back up the EFI.
2. System Settings → General → Software Update.
3. Let it reboot; pick the installer entry, then the normal entry.

If the update stalls, boot verbose and check whether a kext is blocking the boot.

### Major updates (15 → 16)

1. Wait until the kexts you depend on publish support for the new major version.
2. Update OpenCore and all kexts first.
3. Read the release notes of each kext for removed or renamed keys.
4. Test on a separate disk or partition if you can.
5. Keep the previous EFI on the USB so you can boot the old system if the new one fails.

### After any macOS update

```bash
kextstat | grep -v com.apple          # everything still loaded?
system_profiler SPAudioDataType       # audio survived?
system_profiler SPAirPortDataType     # wifi survived?
pmset -g log | tail -20               # sleep still behaving?
```

Audio and WiFi are the two things most likely to break. Both are fixable by adjusting
`layout-id` or updating the AirportRTW trio — no reinstall needed.

## If an update breaks the boot

1. Boot from the USB with the backed-up EFI.
2. Mount the internal EFI and restore the backup:

```bash
sudo diskutil mount disk0s1
rm -rf /Volumes/EFI/EFI
cp -R ~/EFI-backup-YYYY-MM-DD /Volumes/EFI/EFI
```

3. Reboot and confirm the old configuration still works before retrying the update.
