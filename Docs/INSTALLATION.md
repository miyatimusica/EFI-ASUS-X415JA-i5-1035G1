# Installation — ASUS VivoBook 14 X415JA

Target: clean install of macOS Sequoia on the internal NVMe, with OpenCore on the
internal EFI partition.

**You need:** a 16 GB+ USB stick, a working Mac (or a macOS VM) to build the installer,
and a backup of anything on the target disk. The install erases the disk.

---

## 1. BIOS

Apply the settings in [BIOS_SETTINGS.md](BIOS_SETTINGS.md) first. At minimum: Secure
Boot off, Fast Boot off, CSM off, VT-d off, XHCI Hand-off on, SATA AHCI, DVMT 64M,
Above 4G Decoding on.

## 2. Build the installer

```bash
diskutil list                        # identify the USB, e.g. /dev/disk4
sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
  --volume /Volumes/USB --nointeraction
```

If you do not have the installer app, download it with
[gibMacOS](https://github.com/corpnewt/gibMacOS).

## 3. Put this EFI on the USB

```bash
diskutil list                        # the USB now has an EFI partition, e.g. disk4s1
sudo diskutil mount disk4s1
cp -R EFI /Volumes/EFI/
diskutil unmount /Volumes/EFI
```

Verify the layout before unplugging:

```
/Volumes/EFI/EFI/BOOT/BOOTx64.efi
/Volumes/EFI/EFI/OC/OpenCore.efi
/Volumes/EFI/EFI/OC/config.plist
```

## 4. Generate your own SMBIOS

The published `config.plist` ships placeholder identifiers. Replace them.

```bash
git clone https://github.com/corpnewt/GenSMBIOS
cd GenSMBIOS && ./GenSMBIOS.command
# 1) Install/Update MacSerial   2) Select config.plist   3) Generate
# Model: MacBookPro16,2
```

Then set these under `PlatformInfo → Generic` with
[ProperTree](https://github.com/corpnewt/ProperTree):

| Key | Value |
|-----|-------|
| `SystemProductName` | `MacBookPro16,2` |
| `SystemSerialNumber` | generated |
| `MLB` | generated |
| `SystemUUID` | generated |
| `ROM` | 6 bytes, e.g. your `en0` MAC without colons |

Check the serial on [Apple's coverage page](https://checkcoverage.apple.com/) — it should
come back as an invalid/unknown serial, not a registered Mac.

Validate the file:

```bash
./ocvalidate /Volumes/EFI/EFI/OC/config.plist
```

`ocvalidate` ships with the OpenCore release matching your `OpenCore.efi`.

## 5. Boot the installer

1. Insert the USB, power on, tap **F8**.
2. Choose the **UEFI: <your USB>** entry.
3. In the OpenCore picker, select **Install macOS Sequoia**.
4. First boot: press **Space** on the entry and enable verbose mode, so a failure shows
   text instead of a black screen.

## 6. Install

1. Disk Utility → **View → Show All Devices**.
2. Select the **physical NVMe disk**, not a partition.
3. Erase: name `Macintosh HD`, format **APFS**, scheme **GUID Partition Map**.
4. Close Disk Utility → **Install macOS** → pick the new volume.
5. The machine reboots several times. Each time, tap **F8**, pick the USB, and choose the
   entry the installer left behind (`Install macOS Sequoia` or `Macintosh HD`).

Keep the USB plugged in until the Setup Assistant finishes.

## 7. Move the EFI to the internal disk

After reaching the desktop:

```bash
diskutil list                        # internal EFI is usually disk0s1
sudo diskutil mount disk0s1
cp -R /Volumes/EFI/EFI /Volumes/EFI\ 1/    # adjust the target volume name
```

Safer: mount both EFI partitions, open them in Finder, and copy the `EFI` folder across
so it lands as `EFI/EFI/OC/...` on the internal disk.

Then either set the boot order in BIOS, or from the OpenCore picker press
**Ctrl+Enter** on the macOS entry to make it the default.

Test: unplug the USB and reboot. The picker should appear and macOS should boot.

## 8. Dual boot with Windows

- Install Windows first, or shrink its partition from Windows before installing macOS.
- Never let Windows "repair" the boot entry — it removes OpenCore.
- Disable BitLocker before touching the partition table.
- Sync the clock from Windows:

```cmd
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
```

---

## If the installer does not boot

| Symptom | First thing to check |
|---------|----------------------|
| No OpenCore picker | Fast Boot / CSM / Secure Boot still enabled; try another USB port |
| Black screen after the picker | Boot with `-igfxvesa`, then check the framebuffer config |
| Panic in graphics driver | DVMT below 64M, or wrong `ig-platform-id` |
| Panic in `AppleACPIPlatform` | An SSDT does not match this board revision |
| Hangs early with `EB:` | VT-d on, or `DisableIoMapper` disabled |
| Installer does not see the NVMe | SATA/RST mode, or Above 4G Decoding off |

More: [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
