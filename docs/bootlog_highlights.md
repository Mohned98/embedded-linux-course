# Linux Boot Log → Explanation Mapping

| Boot Log | Explain |
|----------|---------|
| `Booting Linux on physical CPU...` | Linux kernel starts executing (bootloader → kernel handoff). |
| `Machine model: Raspberry Pi 3 Model B+` | Device Tree loaded and board identified. |
| `Kernel command line: ...` | Boot arguments passed by the bootloader (`root=`, `console=`, `rootdelay=`...). |
| `CPU1: Booted secondary processor` | Additional CPU cores started (SMP). |
| `ttyAMA0 at MMIO ...` | UART driver initialized. |
| `printk: console [ttyAMA0] enabled` | Kernel console redirected to the serial port. |
| `mmc0: new high speed SDHC card` | SD card detected by the MMC driver. |
| `Waiting 1 sec before mounting root device...` | The kernel is waiting briefly for the root filesystem device (e.g., SD card or virtual block device) to become available before attempting to mount it. This ensures the root filesystem is ready before userspace starts. |
| `EXT4-fs (...) mounted filesystem` | Root filesystem mounted successfully. |
| `Run /sbin/init as init process` | **Kernel switches to user space and starts PID 1.** |

---

# systemd Logs

| Boot Log | Explain |
|----------|---------|
| `Started Journal Service.` | System logging service started. |
| `Started DHCP Client Daemon.` | Network configuration service starts. |
| `Starting OpenBSD Secure Shell server...` | SSH server is being started for remote access. |
| `Started WPA supplicant.` | Wi-Fi authentication service started. |
| `Started Getty on tty1.` | Login prompt started on the local console. |

---

# systemd Targets

| Boot Log | Explain |
|----------|---------|
| `Reached target Local File Systems.` | Required filesystems have been mounted. |
| `Reached target Swap.` | Swap space activated (if configured). |
| `Reached target Network.` | Networking is available. |
| `Reached target Multi-User System.` | Normal text-mode boot completed. |
| `Reached target Graphical Interface.` | GUI environment ready (if installed). |

---