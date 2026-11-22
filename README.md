# debian-nvidia-installer

NVIDIA driver installer with a Bash TUI. This tool allows you to install NVIDIA drivers on Debian and Ubuntu using an interactive text-based interface (TUI).
It automates steps such as package installation, compatibility checks, and graphics environment configuration.

<img src="data/screenshots/main-menu.png">

<div style="display:flex; gap:10px;">
  <img src="data/screenshots/drivers-menu.png" width="270" height="183">
  <img src="data/screenshots/post-installation-menu.png" width="270" height="183">
  <img src="data/screenshots/app-gpu-preferences-menu.png" width="270" height="183">
</div>

### Supported systems

| System | Versions | Architecture |
|---|---|---|
| Debian | 12 (Bookworm), 13 (Trixie) | amd64 |
| Ubuntu | 22.04 LTS, 24.04 LTS | amd64 |

Any other system (including derivatives such as Linux Mint) is refused at start-up with an "Unsupported OS" message, before anything is changed.

Driver choices differ by system:

| Source | Debian 12 | Debian 13 | Ubuntu |
|---|---|---|---|
| Distro repo | v535 proprietary | v535, v550 proprietary, v550 open | Recommended proprietary, latest open |
| NVIDIA CUDA repo | stable / latest, proprietary or open | stable / latest, proprietary or open | stable / latest, proprietary or open |

### Requirements

* A supported system from the table above
* Compatible NVIDIA graphics card
  > Official NVIDIA drivers do not support [GPUs based on the Fermi or Kepler architecture](https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/).

  > See [Debian’s guide on installing legacy drivers](https://wiki.debian.org/NvidiaGraphicsDrivers#Tesla_Drivers) if needed.
* Bash-compatible shell
* Administrator privileges (sudo/root)

# How it works

1. **Detects the system.** Reads `/etc/os-release` and checks the version and CPU architecture. Unsupported systems stop here.
2. **Prepares the package sources.** Debian: enables `contrib`, `non-free` and `non-free-firmware` (a `.bak-nvidia` backup of the sources file is saved first). Ubuntu: enables the `restricted` component. It also enables 32-bit (`i386`) packages, which is optional.
3. **Checks Secure Boot.** If Secure Boot is on and no MOK (Machine Owner Key, the key that lets the kernel load the driver module) is enrolled, it guides you through creating and enrolling one, then asks for a reboot.
4. **Installs kernel headers.** DKMS (Dynamic Kernel Module Support, which rebuilds the driver for each new kernel) needs them: `linux-headers-amd64` on Debian, the running kernel's headers on Ubuntu.
5. **Installs the driver you pick** from the distro repo or the NVIDIA CUDA repo (the CUDA repo is added through NVIDIA's `cuda-keyring` package for your exact release).
6. **Post-install options.** Enables DRM modeset (needed for Wayland), power-management settings, and an optional CUDA Toolkit.
7. **Uninstall** purges NVIDIA packages and config, removes the CUDA repo and version lock, and restores the open-source Nouveau driver.

Reliability features: every apt call waits for the package lock, runs without prompts and keeps your existing config files; `apt update` retries up to 3 times; downloads use retries and timeouts; every action is logged to `/var/log/debian-nvidia-installer/debian-nvidia-installer.log`.

# How to Run

After installation, you can start the script through the shortcut in the applications menu or via the terminal by running the command:

```bash
sudo debian-nvidia-installer
```
> ⚠️ **It is necessary to run as root**, as the tool makes system changes such as installing packages and modifying configuration files.

# Installation

You can install `debian-nvidia-installer` by downloading the `.deb` package from the **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** section of this repository.

### Option 1: Graphical Interface

1. Download the `.deb` package.
2. **Double-click** the file to open it with your system's package manager.
3. Click **“Install”**. You may be prompted to enter your administrator password.

> 💡 Compatible with package managers such as GDebi, Discover (KDE), GNOME Software, and similar tools.

### Option 2: Terminal

Before starting, check the version of the `.deb` package you downloaded from GitHub. Replace `X.X.X` in the commands below with the correct version.
For example, if the version is `0.0.1`, the file will be `debian-nvidia-installer_0.0.1_amd64.deb`.

Copy the `.deb` file to the `/tmp` directory to avoid permission issues with the system package manager:

```bash
cp ./debian-nvidia-installer_X.X.X_amd64.deb /tmp/
```

> 💡 Files in the `/tmp` directory are automatically removed after a system reboot.

Change to the temporary directory `/tmp`, where the `.deb` file was moved:

```bash
cd /tmp
```

Install the package using `apt` so that the script dependencies are installed correctly:

```bash
sudo apt install ./debian-nvidia-installer_X.X.X_amd64.deb
```

> ⚠️ **Important:** Do not install using `dpkg -i`, as this will not resolve the package dependencies and the package may break.

### Option 3: Build and install manually (for advanced users)

Clone the repository locally on your computer using [git](https://packages.debian.org/stable/git):

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

Change to the cloned repository directory:

```bash
cd debian-nvidia-installer
```

Run the build script provided in the repository. It will create the `.deb` package in `./deb_build/debian-nvidia-installer_X.X.X_amd64.deb`:

```bash
./build_deb.sh
```

To install the `.deb` package, follow the same steps as in [Option 1: Graphical Interface](#option-1-graphical-interface) or [Option 2: Terminal](#option-2-terminal).

# Uninstallation

To completely remove the script and its dependencies, run the following command:

```bash
sudo apt purge --autoremove debian-nvidia-installer
```

---

Para a versão em **Português do Brasil**, veja [README.pt_BR.md](README.pt_BR.md)

---
.
> Hello, Debians!
>
> I created this script because I genuinely wanted to contribute to the Linux community, especially to Debian users. I know that moving to Debian can be challenging, particularly for those with NVIDIA hardware, and setting up the drivers correctly is often confusing and intimidating. My goal was to make this process simpler, more accessible, and less stressful for anyone going through it.
>
> Working on this script was also a personal journey for me. It was an opportunity to dive deeper into Linux, understand how the system works under the hood, and explore Bash in a practical way. Sharing the project on GitHub felt like a natural step—not only so others can use it, but also so anyone interested can learn, suggest improvements, and contribute. I hope it helps users, encourages collaboration, and strengthens knowledge sharing within the community.