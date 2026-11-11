# Post-install — ASUS VivoBook 14 X415JA

Assumes macOS is installed and booting from the USB, with the EFI already copied to the
internal disk ([INSTALLATION.md](INSTALLATION.md) step 7).

---

## 1. Confirm you boot without the USB

Unplug the USB, reboot, and check that the OpenCore picker appears and macOS starts. If it
does not, the internal EFI partition is missing the `EFI` folder or the boot order still
points at the USB.

## 2. TRIM

```bash
sudo trimforce enable
```

Reboot when prompted.

## 3. Sleep and hibernation

The EFI is tuned for normal sleep. Turn hibernation off so macOS does not write a
hibernation image the firmware cannot resume:

```bash
sudo pmset -a hibernatemode 0
sudo pmset -a autopoweroff 0
sudo pmset -a standby 0
```

Test: close the lid, wait, open it. The machine should wake to the lock screen.

## 4. Verify each subsystem

```bash
# loaded non-Apple kexts
kextstat | grep -v com.apple

# audio devices
system_profiler SPAudioDataType

# wifi
system_profiler SPAirPortDataType

# bluetooth
system_profiler SPBluetoothDataType

# graphics
system_profiler SPDisplaysDataType

# battery
pmset -g batt

# usb tree
system_profiler SPUSBDataType

# sleep/wake history
pmset -g log | tail -40
```

Expected: WiFi interface with firmware `AirportRTW2.3.1`, `layout-id 66` audio with
internal speakers and mic, battery percentage, and every USB port you use enumerated.

## 5. iServices

Only after step 4 of the install guide (your own serial, MLB, UUID and ROM):

1. Sign in to your Apple ID in System Settings.
2. Open Messages and FaceTime and sign in.
3. If activation fails, sign out, reboot, and sign in again — first activation can take a
   while to propagate.

Never sign in with the SMBIOS that shipped in this repo.

## 6. Optional

```bash
# HiDPI scaling, if the panel or an external display looks wrong
sh -c "$(curl -fsSL https://raw.githubusercontent.com/xzhih/one-key-hidpi/master/hidpi.sh)"
```

FileVault works with this EFI (OpenRuntime is loaded), but enable it only
after you have confirmed the machine boots reliably without the USB, and keep the recovery
key somewhere other than the machine.

## 7. Keep a working backup

Before any OpenCore or macOS update, copy the working EFI somewhere safe:

```bash
sudo diskutil mount disk0s1
cp -R /Volumes/EFI/EFI ~/EFI-backup-$(date +%F)
```

A bootable USB with the same EFI is the cheapest recovery tool you can have.
