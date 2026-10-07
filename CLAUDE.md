# ~/.dotfiles — NixOS + Home-Manager flake

Single-host, single-user NixOS config. Flake-based, nixpkgs-unstable. Do not re-read
flake.nix / nixos/ / home/config/hypr/ for orientation; this file summarizes them.

## Host / user

- Host `BloodAndTears`, user `rafael` (Rafael Miqueles Gustafsson), shell **fish**.
- Laptop: Acer Nitro ANV15-51. Intel iGPU (PCI:0:2:0) + NVIDIA dGPU (PCI:1:0:0), PRIME offload.
  Desktop runs on iGPU (aquamarine auto-picks it, no DRM pin); use `nvidia-offload <cmd>` for dGPU.
- Keyboard: French AZERTY everywhere (xkb, console, kmscon, Hyprland `kb_layout = fr`).
- Locale en_US.UTF-8 with fr_FR LC_* overrides, TZ Europe/Paris.
- Secure Boot OFF (needed for unsigned linuwu_sense module).

## Flake (`flake.nix`)

Inputs: nixpkgs (nixos-unstable), home-manager (master, follows nixpkgs), spicetify-nix,
sf-mono-liga-src (non-flake, overlay builds `sf-mono-liga-bin` font), ambxst
(`github:Axenide/Ambxst`, Hyprland shell; commented local fork path exists), flake-utils (unused).
`devenv` comes from nixpkgs (`pkgs.devenv`, cached on cache.nixos.org), not a flake input.

Outputs:
- `nixosConfigurations.BloodAndTears` = `nixos/configuration.nix` + ambxst nixosModule
  + overlays.
- `homeConfigurations.rafael` = `home/home.nix` + spicetify HM module. `extraSpecialArgs = { inputs; system; }`.
- `allowUnfree = true` in both.

## Rebuild commands

```sh
nh os switch        # alias nr   (= sudo nixos-rebuild switch, NH_FLAKE=/home/rafael/.dotfiles)
nh home switch      # alias hms  (git add -A first)
nh clean all --keep 5 --keep-since 7d   # alias gc; also runs weekly via nh-clean.timer
sudo nixos/holy-update.sh   # flake update + both nh switches + nh clean (interactive y/n)
```
Plain `nixos-rebuild build --flake .#BloodAndTears` / `home-manager build --flake .#rafael` for test builds.

## Repo layout

```
flake.nix / flake.lock
nixos/
  configuration.nix        system config (see below)
  hardware-configuration.nix  generated; ext4 root, vfat /boot, swap partition
  linuwu-sense.nix         out-of-tree patched acer-wmi module (fan/thermal control)
  holy-update.sh           full update script
home/
  home.nix                 HM entry: imports ./config + ./packages.nix
  packages.nix             home.packages, grouped by commented sections (cli, dev, containers,
                           multimedia, theming, apps, games, tty, fonts, lsp, libs, scripts)
  config/default.nix       imports every subdir: hypr kde firefox zsh fastfetch waybar kitty rofi
                           matugen gtk spicetify hyprlock wlogout starship qt fish
  config/<app>/            one dir per app; default.nix + raw config files
dev-shells/
  devenv-wrapper.sh        entry wrapper for devenv shells
  pentest/                 devenv pentest shell (python CLI tooling, pwnhost, nuclei-templates, cheatsheets)
  discord/, languages/{C,Python,Ruby,Rust,Web}
.claude/settings.local.json
.gitignore: result*, .devenv/, .direnv/, /PenNix/ (separate repo)
```

## nixos/configuration.nix highlights

- systemd-boot, NetworkManager, bluetooth, pipewire (alsa/pulse/jack; LDAC disabled in
  wireplumber bluez codecs due to libldac-dec bug), CUPS, flatpak, nix-ld.
- Display: SDDM **on Wayland** (`sddm.wayland.enable`, weston greeter compositor) + Hyprland. `services.xserver.enable
  = false`, `plasma6.enable = false` (disabled, not removed — never used; saved ~2.5 GiB closure). KDE apps kept via
  systemPackages: dolphin (`$fileManager`)/ark/gwenview; kate in user pkgs; okular in home pkgs. seatd + libinput enabled.
- kmscon TTY (`config.hwaccel`): JetBrainsMono Nerd Font Bold 14, autologin rafael, palette imported from
  `home/config/matugen/generated/kmscon-palette.nix` (matugen-generated, so system rebuild
  depends on a home-side generated file).
- NVIDIA: open driver, `production` package, modesetting, PRIME offload (sync off),
  kernelParams `nvidia-drm.modeset=1`. Intel VAAPI via intel-media-driver (iHD).
- Perf: scx scheduler `scx_lavd --autopower`, zram (zstd, 50%, prio 100), aggressive swappiness
  sysctls, power-profiles-daemon (governor left at intel_pstate `powersave`/HWP).
- Virtualisation: virtualbox host (KVM, ext pack), libvirtd+swtpm, virt-manager, docker,
  podman, spice USB redir, `boot.enableContainers`. kernelModules: v4l2loopback
  (`/dev/video2` "EOS600D"), vboxdrv/netflt/netadp.
- Nix: trusted-users rafael, daemon idle CPU/IO sched, `nix.optimise.automatic` (weekly), extra substituters
  devenv.cachix.org + nix-community.cachix.org, `programs.nh` (flake path, weekly `nh clean all`),
  `systemd-boot.configurationLimit = 10`.
- Misc: steam + gamescope, wireshark, gpu-screen-recorder, `/etc/jdk/{8,17,21}` symlinks,
  sudo NOPASSWD for `~/.nix-profile/bin/vlock -an`.
- User groups: networkmanager wheel docker seat input vboxusers wireshark libvirtd linuwu_sense.
- Not done (flagged): `services.seatd` is redundant with logind for Hyprland (harmless). kmscon autologin
  (`login -f rafael`) gives a passwordless shell on any VT — intentional per user.
- `system.stateVersion = "24.05"`.

## nixos/linuwu-sense.nix

Builds `Div-Linuwu-Sense` (PXDiv, pinned rev) against current kernel, blacklists in-tree
`acer_wmi`, loads `linuwu_sense`. Group `linuwu_sense` gets 0660 on
`/sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense/{fan_speed,battery_limiter,battery_calibration,usb_charging}`
via tmpfiles. Service `nitro-quiet-fan` sets `platform_profile=quiet` and
`fan_speed=0,0` (auto) at boot. `fan_speed` format `"CPU,GPU"`, 0=auto, 100=max.

## home/home.nix

- HM stateVersion 24.05, `programs.home-manager.enable`.
- sessionPath adds `~/.npm-global/bin` (`.npmrc` prefix set).
- Qt: HM `qt.platformTheme.name = "kde"` (QT_QPA_PLATFORMTHEME=kde so KF6 apps like dolphin read kdeglobals
  colours; matugen merges its scheme into kdeglobals via the qt2 template post_hook) + `style.name = "kvantum"`
  with `qt.kvantum.settings.General.theme = "matugen"` (HM owns `~/.config/Kvantum/kvantum.kvconfig`). The
  "matugen" Kvantum theme is rendered by matugen (`kvantum_kvconfig`/`kvantum_svg` templates from
  InioX/matugen-themes, KvAdapta/Materia-based flat look) into `~/.config/Kvantum/matugen/`. matugen does NOT
  create missing output dirs: `mkdir -p ~/.config/Kvantum/matugen` on a fresh machine. `qt/ensure-widgetstyle.py`
  (HM activation) keeps kdeglobals `[KDE] widgetStyle=kvantum`. adwaita-qt rejected: hardcoded palette,
  unmaintained. plasma-integration + breeze from kde/default.nix. Cursor Adwaita 24 + hyprcursor.
- `EDITOR`/`VISUAL` = nvim. `programs.direnv` + nix-direnv (fish hook injected by HM; do not add manual hooks).
- Terminal HM modules (fish auto-wired): `programs.zoxide` (`--cmd cd`, so `cd` is zoxide; `cdi` interactive),
  `programs.eza` (icons/git; `ls`/`la`/`ll`/`lt` aliases in config.fish keep `--group-directories-first`),
  `programs.bat` (also MANPAGER), `programs.atuin` (Ctrl-R history, up-arrow left to fish). eza/bat removed from
  packages.nix (modules install them). Not enabled: fzf, yazi, lazygit, gh.
- Firefox: `programs.firefox.package = pkgs.firefox-devedition` (only Firefox installed).
- git: identity + lfs + credential helper `manager` (github user `rafmiqgus`, credentialstore cache) all in
  `programs.git.settings`; no imperative `~/.gitconfig` (old one kept as `~/.gitconfig.bak`).
- fcitx5 input method (kdePackages.fcitx5-with-addons). zellij enabled.
- Spicetify: matugen's `spicetify/Themes/Comfy/color.ini` is parsed in `spicetify/default.nix` into
  `programs.spicetify.customColorScheme` (build-time). Runtime `~/.config/spicetify` is not read; re-run
  `home-manager switch` after matugen to apply Spotify colors.
- permittedInsecurePackages: quickjs, electron (update as needed).

## Hyprland (`home/config/hypr/`)

Module split, all under `wayland.windowManager.hyprland.settings`. `sourceFirst = true` (colors.conf/monitors.conf
first so matugen `$vars` exist), **ambxst's conf is sourced LAST via `extraConfig`** so its general/decoration/
animations override anything in looks-hypr.nix (by design). `configType = "hyprlang"` (HM default is now lua):

| file | content |
|---|---|
| `default.nix` | packages (waybar, awww, hyprpaper, waypaper, wl-clipboard, clipse, hyprpolkitagent, swaync, hyprlock, hyprpicker, wlr-randr, wl-mirror, brightnessctl, pavucontrol, playerctl), imports |
| `general-hypr.nix` | `source` = `hypr/colors.conf`, `~/.config/hypr/monitors.conf` (ambxst conf lives in default.nix extraConfig); `$terminal=kitty`, `$fileManager=dolphin`, `$menu=rofi -show drun`; env (cursor, `LIBVA_DRIVER_NAME=iHD`, `XKB_DEFAULT_LAYOUT=fr`); exec-once hyprpolkitagent; monitor = `, preferred, auto, 1` (real layout owned by **hyprmoncfg** → `~/.config/hypr/monitors.conf`, daemon `hyprmoncfgd.service`); input fr, touchpad tap+natural scroll; 3-finger horizontal gesture = workspace; device sensitivities (logitech-g305, elan touchpad); `misc.vrr = 2` (fullscreen only), `render.direct_scanout = 2` (auto); hardware cursors at default (auto) |
| `binds-hypr.nix` | `$mainMod=SUPER`. RETURN terminal, C kill, M wlogout script, E filemanager, HJKL focus. Workspaces 1-10 on AZERTY top row keysyms (`ampersand eacute quotedbl apostrophe parenleft minus egrave underscore ccedilla agrave`), SHIFT variants move. SHIFT+S → special:magic. mouse_down/up scroll workspaces. bindm drag move/resize. bindel volume (wpctl) / brightness (brightnessctl). bindl playerctl |
| `windows-hypr.nix` | workspaces 1-4 declared; windowrules (new `match:class` syntax): clipse float 622x652, waypaper float, kitty KittyNmtui float 800x700, pavucontrol float, kitty nvim title opacity 0.90/0.82; layerrule blur logout_dialog |
| `looks-hypr.nix` | imports `animations/caelestia.nix` + `blurs/caelestia.nix` (overridden by ambxst at runtime); dwindle layout, gaps 8 / `8,18,18,18`, border 4, active border `$primary 0xff595959 $inverse_primary 45deg`, shadow, dim_inactive 0.1, rounding 20 |
| (colors) | `~/.cache/matugen/hyprland-colors.conf`, generated by matugen, sourced first. Defines `$image` + `$background/$primary/...` vars |

Notes: ambxst (Axenide) provides the bar/shell; waybar is installed but not autostarted
(commented). Wallpaper via awww/hyprpaper/waypaper (swww line commented).

## Theming pipeline (matugen)

`home/config/matugen/config.toml` renders templates in `home/config/matugen/templates/`.
Outputs live OUTSIDE the repo in `~/.cache/matugen/` (hyprland-colors.conf, hyprlock-colors.conf,
kitty-colors.conf, waybar-colors.css, hyprlust-waybar-colors.css, starship-palette.toml) or
`~/.config/<app>` (rofi, gtk, qt6ct, zellij, btop, vesktop, wlogout) or `~/.cache/wal` (pywalfox).
Consumers reference those absolute paths (Hyprland `source`, kitty `include`, hyprlock `source`,
waybar `@import`). Kvantum theme goes to `~/.config/Kvantum/matugen/` (dir must pre-exist).
Run non-interactively with `--source-color-index 0` (waypaper's wallpaper.sh runs it interactively). Only two generated files stay tracked because Nix reads them at build:
`spicetify/Themes/Comfy/color.ini` and `matugen/generated/kmscon-palette.nix`.
Edit templates, never outputs. If `~/.cache/matugen` is empty (fresh machine), run matugen once
before starting Hyprland or the `$primary` vars are undefined.

## Hardware inventory (from `inxi -Fxxxz`, 2026-09-17)

Tool: `inxi` (installed in home profile). Re-run `inxi -Fxxxz --no-host` to refresh.

- **Machine**: Acer Nitro ANV15-51 v1.14, mobo RPL "Sportage_RTH", UEFI Insyde 1.14 (2024-06-21).
- **CPU**: Intel i5-13420H (Raptor Lake, 8c/12t = 4P+4E), 400–4600 MHz P / 3400 E.
  L2 7 MiB, L3 12 MiB. intel_pstate active mode, HWP. RAPL PL1 55 W / PL2 115 W (EC/balanced profile).
- **GPU 0**: Intel UHD Graphics RPL-P (8086:a7a8), driver i915, `/dev/dri/card2` = `by-path/pci-0000:00:02.0-card`,
  render `renderD129`. Drives all displays. Mesa iris, VAAPI iHD.
- **GPU 1**: NVIDIA RTX 4050 Laptop (AD107M, 10de:28a1), `/dev/dri/card1`, render `renderD128`, driver nvidia
  595 open, PRIME offload, runtime D3 fine-grained (sleeps when unused; any `nvidia-smi` call wakes it).
  HDMI-A-2 is wired to the dGPU.
- **RAM**: 16 GiB. Swap: zram0 7.7 GiB zstd prio 100 + 16.9 GiB partition prio -2.
- **Storage**: nvme0n1 SK Hynix HFS512GEJ9X110N 512 GB (root ext4 + boot + swap); nvme1n1 Samsung 980 1 TB.
  Intel VMD/RST controller present (driver vmd).
- **Audio**: Intel cAVS (sof-audio-pci-intel-tgl), NVIDIA HDA, USB: HP headset, Jabra Link 370. PipeWire 1.6.
- **Network**: Intel CNVi WiFi (iwlwifi, `wlp0s20f3`), Realtek RTL8168 GbE (`enp62s0`), USB RTL8153 GbE dongle.
  Bluetooth Intel AX201 (btusb, hci0).
- **Webcam**: Quanta ACER HD (uvcvideo). v4l2loopback at `/dev/video2` "EOS600D".
- **Battery**: LGC AP21D8M 57.5 Wh design, 40.9 Wh full (71% health), 321 cycles.
- **Input**: Logitech G305, ELAN0518 touchpad. AZERTY.
- **Sensors**: coretemp (Package id 0), `acer` hwmon (temp1-3, fan1 CPU, fan2 GPU), acpitz, INT3400/TCPU
  thermal zones. No lm_sensors installed; read `/sys/class/hwmon` or `inxi -s`.
- **Fan/thermal control**: linuwu_sense (see above). `platform_profile` choices:
  `low-power quiet balanced balanced-performance`.

## Power / perf stack (what actually runs)

- Governor `powersave` (intel_pstate/HWP). EPP owned by power-profiles-daemon (default `balanced`).
- ppd's PlatformDriver is `placeholder`: it does NOT drive `/sys/firmware/acpi/platform_profile` (choices lack
  `performance`). Only linuwu-sense's `nitro-quiet-fan` touches it (writes `quiet` at boot). To change live:
  `sudo sh -c 'echo balanced > /sys/firmware/acpi/platform_profile'`.
- scx: `scx_lavd` 1.1.2 `--autopower` (follows EPP: `powerprofilesctl set power-saver` → core compaction).
- Removed 2026-09-17: auto-cpufreq input (was never enabled), invalid `cpuFreqGovernor = balanced-performance`
  (cpufreq.service failed every boot), `cpu-hwd-boost` service (hwp_dynamic_boost), bogus `drm.vrrpoli=1`.
- Hyprland effective look = ambxst's (gaps 2/4, border 2, rounding 16, layout scrolling, blur 4/2), VRR fullscreen-only, direct scanout auto,
  logging off (debug block removed), `suppress_errors` off: check `hyprctl configerrors` after config changes. iGPU pinned at 1400 MHz max clock while compositing 3 monitors.
- Session: SDDM → plain `hyprland.desktop`; HM `wayland.windowManager.hyprland.systemd.enable` (default true) provides
  `hyprland-session.target` → `graphical-session.target`, so hyprpolkitagent/hyprmoncfgd run as user services. UWSM not
  used (decided 2026-09-17: no gain over HM's target; ambxst's own `exec-once = ambxst` would be unmanaged).
- **No GPU pin.** `WLR_DRM_DEVICES` is obsolete (ignored). `AQ_DRM_DEVICES` is colon-separated, so a by-path
  value (`pci-0000:00:02.0-card`) splits into junk and Hyprland aborts "Found no gpus" (broke boot 2026-09-17).
  If a pin is ever needed: udev symlink without colons, or `/dev/dri/cardN` (unstable numbering).
- Fan-noise levers, in order: platform_profile `quiet`, `powerprofilesctl set power-saver`, blur passes,
  eDP 144 Hz → 60 Hz when docked (hyprmoncfg). dGPU is NOT the cause (runtime D3 works; `nvidia-smi` wakes it).

## Conventions

- Commit directly to `master`, no feature branches. No Co-Authored-By / session trailers.
- Fish is login shell; zsh config also present (`home/config/zsh`).
- Nix style: 2-space, `{ config, lib, pkgs, ... }:` headers, ASCII-art section banners in hypr files,
  packages.nix grouped with `# ── section ──` comments.
- Absolute paths `/home/rafael/.dotfiles/...` used inside configs (not `~`), matching existing style.
