# BIOS settings — ASUS VivoBook 14 X415JA

Enter BIOS with **F2** at power-on. If the menus look simplified, press **F7** for
Advanced Mode. Save with **F10**.

These are the settings the reference machine runs with. Menu names vary slightly between
BIOS revisions; if a setting is missing, update the BIOS first.

---

## Required

| Setting | Value | Why |
|---------|-------|-----|
| Secure Boot | **Disabled** | OpenCore and its kexts are unsigned |
| Fast Boot | **Disabled** | Lets the firmware enumerate the USB and show the picker |
| CSM / Legacy support | **Disabled** | Pure UEFI boot |
| VT-d | **Disabled** | `DisableIoMapper` covers it, but firmware off is cleaner |
| XHCI Hand-off | **Enabled** | macOS takes USB ownership |
| SATA mode | **AHCI** | Never RAID / Intel RST |
| DVMT Pre-Allocated | **64M** | Required by the Ice Lake framebuffer |
| Above 4G Decoding | **Enabled** | 64-bit PCI BARs |
| Re-Size BAR | **Disabled** | Not supported by macOS |

## Recommended

| Setting | Value | Why |
|---------|-------|-----|
| Internal Graphics | Enabled | iGPU is the only GPU |
| Primary Display | Auto / IGFX | Keep the iGPU as primary |
| Intel SpeedStep | Enabled | Native P-states |
| Intel Speed Shift | Enabled | HWP |
| C-States | Enabled | Idle power |
| Wake on LAN | Disabled | Prevents spurious wake |
| USB wake | Enabled | Wake from keyboard |
| Network Stack / PXE | Disabled | Faster boot, less noise |

---

## DVMT note

This EFI's framebuffer data already includes `framebuffer-stolenmem` and
`enable-dvmt-calc-fix`, so it tolerates a 64M BIOS allocation. If you get a black screen
or a framebuffer panic on first boot, raise DVMT to 128M when the BIOS offers it, or boot
once with `-igfxvesa` to reach the desktop and inspect the logs.

---

## If a setting is not visible

- Press **F7** for Advanced Mode.
- Update the BIOS; some toggles only appear on newer revisions.
- Settings that stay hidden are covered by quirks already present in `config.plist`:
  `DisableIoMapper` (VT-d), `AppleXcpmCfgLock` + `AppleXcpmExtraMsrs` (CFG Lock).

## Restoring defaults

**F9** → Load Optimized Defaults → **F10**, then re-apply the Required table. A BIOS
update always resets everything, so re-check the table after flashing.

---

## Updating the BIOS

1. Download the file for **X415JA** from ASUS support.
2. Copy it to the root of a FAT32 USB stick.
3. BIOS → Advanced → ASUS EZ Flash → select the file → confirm.
4. After the reboot, re-apply every setting above and verify OpenCore still boots.

> A BIOS update is not needed for this EFI to work. Only update for a concrete reason.
