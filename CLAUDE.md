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
(`github:Axenide/Ambxst`, Hyprland shell; commented local fork path exists).
`devenv` comes from nixpkgs (`pkgs.devenv`, cached on cache.nixos.org), not a flake input.
flake-utils input removed 2026-10-13 (was unused); flake.lock still lists it until the next lock write.

Outputs:
- `nixosConfigurations.BloodAndTears` = `nixos/configuration.nix` + ambxst nixosModule + `overlayModule`.
  No `system` arg: platform comes from `nixpkgs.hostPlatform` in hardware-configuration.nix.
- `homeConfigurations.rafael` = `home/home.nix` + spicetify HM module + `overlayModule`, base
  `pkgs = nixpkgs.legacyPackages.x86_64-linux` (HM re-imports nixpkgs with its own config anyway).
  `extraSpecialArgs = { inherit inputs; }` (no `system`; use `pkgs.stdenv.hostPlatform.system`).
- `overlayModule` = `{ nixpkgs.overlays = overlays; }` (sf-mono-liga-bin), shared by both.
- `allowUnfree = true` set in configuration.nix and home.nix (not in the flake).

## Rebuild commands

```sh
nh os switch        # alias nr   (= sudo nixos-rebuild switch, NH_FLAKE=/home/rafael/.dotfiles)
nh home switch      # alias hms  (nr + hms run `git add -N .` first: new files visible to flake, nothing staged)
# ALL rebuilds need --impure (nh: `-- --impure`): Nix reads matugen colors from ~/.cache/matugen (not in git).
nh clean all --keep 5 --keep-since 3m   # alias gc; also runs weekly via nh-clean.timer
sudo nixos/holy-update.sh   # flake update + both nh switches + nh clean (interactive y/n)
```
Plain `nixos-rebuild build --impure --flake .#BloodAndTears` / `home-manager build --impure --flake .#rafael` for test builds.

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
  `~/.cache/matugen/kmscon-palette.nix` (matugen-generated, outside git, `--impure`; missing file = kmscon
  default palette via `pathExists`).
- NVIDIA: open driver, `production` package, modesetting, PRIME offload, `powerManagement.enable`
  (finegrained off). `nvidia-drm.modeset=1` comes from the nvidia module itself (no manual kernelParam).
  Intel VAAPI via intel-media-driver (iHD); `libva-utils` (vainfo) in systemPackages.
- Perf: in-kernel EEVDF scheduler (scx_lavd removed: kept P-cores in shallow C1), zram (zstd, 50%, prio 100),
  aggressive swappiness sysctls, power-profiles-daemon (governor intel_pstate `powersave`/HWP),
  `powerManagement.powertop.enable` (runtime PM auto-tune at boot).
- Virtualisation: virtualbox host (KVM backend, ext pack), libvirtd+swtpm, virt-manager, docker,
  podman, spice USB redir, `boot.enableContainers`. kernelModules: v4l2loopback (`/dev/video2` "EOS600D").
  No manual vbox modules: with `enableKvm = true` vboxdrv/netflt/netadp are not built (were failing every boot).
- Nix: trusted-users rafael, daemon idle CPU/IO sched, `nix.optimise.automatic` (weekly), extra substituters
  devenv.cachix.org + nix-community.cachix.org, `programs.nh` (flake path, weekly `nh clean all`),
  `systemd-boot.configurationLimit = 10`.
- Misc: no Steam (removed 2026-10-13), wireshark (GUI package), gpu-screen-recorder, `/etc/jdk/{8,17,21}` symlinks,
  sudo NOPASSWD for `~/.nix-profile/bin/vlock -an`.
- tmpfiles `L+ /bin/bash` and `/usr/bin/bash` -> `${pkgs.bash}` (added 2026-10-13): ambxst/Roadie QML hardcodes
  them for the power menu (lock/reboot/poweroff), Roadie's farewell and the AI sidebar; without them every
  power-menu action silently failed ("Process failed to start") and the farewell backed out after 20 s.
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
  unmaintained. plasma-integration + breeze from kde/default.nix. Cursor: Bibata-Modern-Classic 24 via `home.pointerCursor`
  (custom derivation in home.nix merging nixpkgs `bibata-cursors` XCursor + LOSEARDES77 hyprcursor release in one
  theme dir); cursor env vars injected into Hyprland `env` from `config.home.pointerCursor` in general-hypr.nix.
- `EDITOR`/`VISUAL` = nvim. `programs.direnv` + nix-direnv (fish hook injected by HM; do not add manual hooks).
- Terminal HM modules (fish auto-wired): `programs.zoxide` (`--cmd cd`, so `cd` is zoxide; `cdi` interactive),
  `programs.eza` (icons/git; `ls`/`la`/`ll`/`lt` aliases in config.fish keep `--group-directories-first`),
  `programs.bat` (also MANPAGER), `programs.atuin` (Ctrl-R history, up-arrow left to fish). eza/bat removed from
  packages.nix (modules install them). Not enabled: fzf, yazi, lazygit, gh.
- Firefox: `programs.firefox.package = pkgs.firefox-devedition` (only Firefox installed).
- git: identity + lfs + credential helper `manager` (github user `rafmiqgus`, credentialstore cache) all in
  `programs.git.settings`; no imperative `~/.gitconfig` (old one kept as `~/.gitconfig.bak`).
- fcitx5 input method (kdePackages.fcitx5-with-addons). zellij enabled.
- Spicetify: matugen's `~/.cache/matugen/spicetify-color.ini` (outside git, `--impure`, missing = theme default) is parsed in `spicetify/default.nix` into
  `programs.spicetify.customColorScheme` (build-time). Runtime `~/.config/spicetify` is not read; re-run
  `home-manager switch` after matugen to apply Spotify colors.
- No `permittedInsecurePackages` (removed 2026-10-13; quickjs no longer insecure). If a build fails on
  `electron-39.8.10` (EOL), some app still pulls `electron_39`: re-add it to `nixpkgs.config` with a comment.
- `TERMINAL` = kitty (sessionVariables).
- packages.nix multimedia: `pulseaudio` for `pactl` only (talks to pipewire-pulse, no daemon); Roadie's audio
  routing tab needs it.

## Hyprland (`home/config/hypr/`)

**Lua config since 2026-10-15** (`configType = "lua"`, Hyprland 0.56 Lua API `hl.*`; commit fc48d0a). HM writes
`~/.config/hypr/hyprland.lua` + `binds.lua` + `.luarc.json` (LSP stubs from `${hyprland}/share/hypr/stubs/hl.meta.lua`).
No hyprlang left: no `source`, no `$vars`, no `sourceFirst`. Lua can only load Lua (`dofile`/`loadfile`/`require`),
never a hyprlang `.conf`.

How HM renders `settings` in Lua mode: each attribute = `hl.<name>(...)`, list = one call per element, `_args` =
multi-argument call (`env`), `_var` = `local`, `lib.generators.mkLuaInline` = raw Lua (avoided on purpose: anything
needing Lua expressions goes in a native `.lua` file). Sections like general/decoration/input/misc/render go under
`settings.config` (→ `hl.config({...})`). Key names follow the Lua API (`tap_to_click`, `gaps_out = {top,right,...}`,
gradients `{ colors = {...}, angle = 45 }`). Generated order: `require`s (extraLuaFiles) → settings (alphabetical)
→ HM startup/shutdown hooks → `extraConfig`. Later `hl.config` calls override earlier ones.

**`extraConfig` loads, last and in order:** `~/.config/hypr/monitors.lua` (hyprmoncfg) then
`~/.local/share/ambxst/hyprland.lua` (ambxst), through a `load_if_exists` helper (`loadfile`, silently skips a
missing OR syntactically broken file: if ambxst's look vanishes, check its file first). Ambxst therefore overrides only
the keys it sets itself: general/decoration values (incl. border colours) and the PARENT animations
`windows`/`fade`/`border`/`workspaces` (2.5, `myBezier`). Any leaf animation set from Nix (`windowsMove`, `fadeDim`...)
still wins over its parent; check `hyprctl animations` (`overridden: 1` = set explicitly).

| file | content |
|---|---|
| `default.nix` | packages (waybar, awww, hyprpaper, waypaper, wl-clipboard, clipse, hyprpolkitagent, swaync, hyprlock, hyprpicker, wlr-randr, wl-mirror, brightnessctl, pavucontrol, playerctl), imports, `configType = "lua"`, `extraLuaFiles.binds = ./binds.lua`, `extraConfig` (monitors + ambxst loads) |
| `general-hypr.nix` | `env` via `_args` (cursor from `home.pointerCursor`, `LIBVA_DRIVER_NAME=iHD`, `XKB_DEFAULT_LAYOUT=fr`); fallback `monitor` (`output = ""`, preferred/auto/1; real layout owned by **hyprmoncfg** → `~/.config/hypr/monitors.lua`, daemon `hyprmoncfgd.service`); `config.misc` (`vrr = 2` fullscreen only), `config.render.direct_scanout = 2`, `config.input` fr + touchpad `tap_to_click`/natural scroll; `gesture` 3-finger horizontal = workspace; `device` sensitivities (logitech-g305, elan touchpad). No exec-once: hyprpolkitagent is a systemd user unit (graphical-session.target) |
| `binds.lua` | native Lua, `require("binds")`. `local mainMod = "SUPER"`. RETURN kitty, C close, M wlogout script, E `kitty -- yazi`, HJKL focus. Workspaces 1-10 on AZERTY top row keysyms (`ampersand eacute quotedbl apostrophe parenleft minus egrave underscore ccedilla agrave`, loop), SHIFT moves window. SHIFT+S → special:magic. mouse_down/up scroll workspaces. mouse:272/273 drag/resize (`{ mouse = true }`). Volume (wpctl) / brightness (brightnessctl) `{ locked, repeating }`, playerctl `{ locked }` |
| `windows-hypr.nix` | `workspace_rule` 1-4; `window_rule` (`match = { class, title }`): clipse float + `size "622 652"`, waypaper float, kitty KittyNmtui float 800x700, pavucontrol float; `layer_rule` blur logout_dialog |
| `looks-hypr.nix` | `settings.config.*`; imports `blurs/caelestia.nix` only (`config.decoration.blur`). `animations/caelestia.nix` / `custom.nix` NOT imported and still hyprlang-shaped (its leaf `windowsMove 1,6` / `fadeDim 6` survived ambxst's parent `windows 2.5` and made focus/scroll moves 600 ms); dwindle layout, gaps 8 / `{8,18,18,18}`, border 4, shadow, dim_inactive 0.1, rounding 20. No border colours (ambxst sets them) |

Notes: ambxst (Axenide) provides the bar/shell; waybar is installed but not autostarted
(commented). Wallpaper via awww/hyprpaper/waypaper (swww line commented).
VRR: `misc.vrr = 2` (fullscreen only). hyprmoncfg writes `monitors.lua` (Lua) because it detects `hyprland.lua`;
the old hyprlang `~/.config/hypr/monitors.conf` is no longer read (check eDP `vrr` in the Lua file: hyprmoncfg may
write `1` when a profile is saved). Its profile lists the iiyama ultrawide (DP-4, 3440x1440@60) but not the Samsung
LC27G5 (DP-1, 2560x1440@144, falls back to the Nix `preferred, auto` monitor).

**Gotcha (hit 2026-10-15):** Hyprland picks the config format (`hyprland.lua` vs `hyprland.conf`) once at startup.
Switching hyprlang → Lua from inside a running session makes the reload find no `hyprland.conf`, so Hyprland writes
a stub (`autogenerated = 1`, "This config is a STUB!", QWERTY defaults) and keeps recreating it. Fix: from a TTY
`hyprctl -i 0 dispatch exit` (not `pkill`: `start-hyprland` watchdog), `rm ~/.config/hypr/hyprland.conf`, log in
again. Log line to confirm: `[cfg] ... hyprland.lua` in `$XDG_RUNTIME_DIR/hypr/<newest>/hyprland.log`.

## Ambxst / Roadie (runtime state, outside git)

- Ambxst 1.3.11 (flake input). Mods via `ambxst mods ...`: state in `~/.config/ambxst/mods.json`, sources in
  `~/.local/share/ambxst/mods/packages/`, built tree in `~/.local/share/ambxst/mods/generations/<id>/` (the QML
  that actually runs). Installed: `drpezzer.roadie` 3.0.2 (github drpezzer/ambxst-mods, `packages/roadie`).
- Shell config: `~/.config/ambxst/config/*.json` (theme, compositor, performance...), Roadie in `~/.config/ambxst/roadie.json`.
  Ambxst generates `~/.local/share/ambxst/hyprland.lua` (+ `.conf`, `niri.kdl`, `mango.conf`) from `compositor.json`:
  blur/shadow/gaps/borders must be changed in Ambxst Settings, not Nix (its `.lua` is loaded last).
- Logs: `qs log $XDG_RUNTIME_DIR/quickshell/by-id/<id>/log.qslog` (newest dir = running shell). IPC:
  `qs ipc --pid $(cat $XDG_RUNTIME_DIR/ambxst-qs.pid) call roadie <state|farewellPreview reboot|bootPreview|...>`.
- Lockscreen: only option is `lockscreen.position`; animation hardcoded (blur+zoom, `animDuration*2`). Roadie does
  not change it, it only locks after boot (`Lock after boot: Auto` skips it after an SDDM login).
- True Matugen Icons = Settings > Theme > Tint Icons (`theme.json trueMatugenIcons`), off by default.
- Roadie's "Bar follows the focused screen" slide (1.6 x `animDuration`, windows resize in step) is what felt
  sluggish; "Immediate" bar slide is snappy. See perf notes below.

## Theming pipeline (matugen)

`home/config/matugen/config.toml` renders templates in `home/config/matugen/templates/`.
Outputs live OUTSIDE the repo in `~/.cache/matugen/` (hyprland-colors.conf, hyprlock-colors.conf,
kitty-colors.conf, waybar-colors.css, hyprlust-waybar-colors.css, starship-palette.toml) or
`~/.config/<app>` (rofi, gtk, qt6ct, zellij, btop, vesktop, wlogout) or `~/.cache/wal` (pywalfox).
Consumers reference those absolute paths (Hyprland `source`, kitty `include`, hyprlock `source`,
waybar `@import`). Kvantum theme goes to `~/.config/Kvantum/matugen/` (dir must pre-exist).
Run non-interactively with `--source-color-index 0` (waypaper's wallpaper.sh runs it interactively). No generated file is tracked (user does not want them pushed). Nix reads two at build time, hence `--impure`:
`~/.cache/matugen/spicetify-color.ini` and `~/.cache/matugen/kmscon-palette.nix`.
Edit templates, never outputs. If `~/.cache/matugen` is empty (fresh machine), run matugen once
before starting Hyprland or the `$primary` vars are undefined.

## Hardware inventory (from `inxi -Fxxxz`, 2026-09-17)

Tool: `inxi` (installed in home profile). Re-run `inxi -Fxxxz --no-host` to refresh.

- **Machine**: Acer Nitro ANV15-51 v1.14, mobo RPL "Sportage_RTH", UEFI Insyde 1.14 (2024-06-21).
- **CPU**: Intel i5-13420H (Raptor Lake, 8c/12t = 4P+4E), 400–4600 MHz P / 3400 E.
  L2 7 MiB, L3 12 MiB. intel_pstate active mode, HWP. RAPL PL1 55 W / PL2 115 W (EC/balanced profile).
- **GPU 0**: Intel UHD Graphics RPL-P (8086:a7a8), driver i915, `by-path/pci-0000:00:02.0-card`. DRM card number is
  NOT stable across boots (card1 on 2026-10-13, card2 on 2026-10-14): resolve via PCI address 0000:00:02.0.
  Drives all iGPU outputs (eDP, DP-*). Mesa iris, VAAPI iHD.
- **GPU 1**: NVIDIA RTX 4050 Laptop (AD107M, 10de:28a1), `/dev/dri/card1`, render `renderD128`, driver nvidia
  595 open, PRIME offload, runtime D3 via driver default (NixOS `powerManagement.finegrained` is off; sleeps when
  unused; any `nvidia-smi` call wakes it).
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
- Scheduler: in-kernel EEVDF. scx_lavd removed (kept P-cores in shallow C1 at idle, raised idle power floor).
- Removed 2026-09-17: auto-cpufreq input (was never enabled), invalid `cpuFreqGovernor = balanced-performance`
  (cpufreq.service failed every boot), `cpu-hwd-boost` service (hwp_dynamic_boost), bogus `drm.vrrpoli=1`.
- Hyprland effective look = ambxst's (gaps 2/4, border 2, rounding 16, layout scrolling, blur 4/2), VRR fullscreen-only, direct scanout auto,
  logging off (debug block removed), `suppress_errors` off: check `hyprctl configerrors` after config changes.
- iGPU load (measured 2026-10-13/14): read without root from `/sys/class/drm/cardN/gt/gt0/rc6_residency_ms` (idle %)
  and `gt_act_freq_mhz` (max 1400). `intel_gpu_top` needs sudo: `nix shell nixpkgs#intel-gpu-tools`.
  On the Samsung (1440p@144) + eDP@144 the iGPU sat at 0% RC6 / 1400 MHz on an idle desktop, ~83% Render busy
  from Hyprland itself, 99.5% with music playing. Blur off: 37% RC6 / 620 MHz. `ambxst quit`: 30% / 540 MHz.
  blur passes 1, xray, dim_inactive off: no effect. Roadie off: no effect (stock Ambxst same). The shell itself
  renders only ~4 fps idle (`QSG_RENDER_TIMING=1`): cost is Hyprland re-blurring Ambxst's full-screen `ambxst`
  layers (one per monitor, `layerrule = blur on ... ^ambxst(:.*)?$` in ambxst's conf) on each damage.
- Session: SDDM → plain `hyprland.desktop`; HM `wayland.windowManager.hyprland.systemd.enable` (default true) provides
  `hyprland-session.target` → `graphical-session.target`, so hyprpolkitagent/hyprmoncfgd run as user services. UWSM not
  used (decided 2026-09-17: no gain over HM's target; ambxst's own `exec-once = ambxst` would be unmanaged).
- **No GPU pin.** `WLR_DRM_DEVICES` is obsolete (ignored). `AQ_DRM_DEVICES` is colon-separated, so a by-path
  value (`pci-0000:00:02.0-card`) splits into junk and Hyprland aborts "Found no gpus" (broke boot 2026-09-17).
  If a pin is ever needed: udev symlink without colons, or `/dev/dri/cardN` (unstable numbering).
- Fan-noise levers, in order: platform_profile `quiet`, `powerprofilesctl set power-saver`, blur passes,
  eDP 144 Hz → 60 Hz when docked (hyprmoncfg). dGPU is NOT the cause (runtime D3 works; `nvidia-smi` wakes it).

## Conventions

- **Always describe the plan and wait for the user's approval before editing files, building, switching or
  committing.** Read-only inspection (reading files, `nix eval`, journal) is fine without asking.
- Commit directly to `master`, no feature branches. No Co-Authored-By / session trailers.
- Fish is login shell; zsh config also present (`home/config/zsh`).
- Nix style: 2-space, `{ config, lib, pkgs, ... }:` headers, ASCII-art section banners in hypr files,
  packages.nix grouped with `# ── section ──` comments.
- Absolute paths `/home/rafael/.dotfiles/...` used inside configs (not `~`), matching existing style.
