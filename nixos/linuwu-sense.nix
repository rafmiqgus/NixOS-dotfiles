# Div-Linuwu-Sense: patched acer-wmi kernel module restoring fan / thermal
# control on Acer Nitro/Predator laptops. Fixes the ANV15-51 "fans spin at
# idle" behaviour by handing the EC a real thermal profile instead of letting
# it free-run its default curve.
#
# Same driver DAMX uses on CachyOS, packaged declaratively (no `make install`;
# NixOS handles blacklist/load/perms/service). Secure Boot must be OFF so the
# unsigned module loads.
#
# Exposed knobs (nitroSense = /sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense):
#   <nitroSense>/fan_speed                "CPU,GPU": 0=auto, 1=min (discouraged), 100=max
#   /sys/firmware/acpi/platform_profile   low-power | quiet | balanced | balanced-performance

{ config, lib, ... }:

let
  nitroSense = "/sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense";

  linuwu-sense = config.boot.kernelPackages.callPackage (
    { stdenv, fetchFromGitHub, kernel }:
    stdenv.mkDerivation {
      pname = "linuwu-sense";
      version = "0-unstable-2026-07-30";

      src = fetchFromGitHub {
        owner = "PXDiv";
        repo = "Div-Linuwu-Sense";
        rev = "d8ea437d847268dd9fe2a49ae28d0723dd720968";
        hash = "sha256-VA8i6kTQ4p5AqSW/jNWJOB4/I4pXV3KKIcrcZ2zHrgM=";
      };

      nativeBuildInputs = kernel.moduleBuildDependencies;

      # Upstream Makefile's `all` target is just the kbuild invocation.
      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd) modules
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -D src/linuwu_sense.ko \
          "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/platform/x86/linuwu_sense.ko"
        runHook postInstall
      '';

      meta = {
        description = "Patched acer-wmi module (fan/thermal control) for Acer Nitro/Predator";
        homepage = "https://github.com/PXDiv/Div-Linuwu-Sense";
        license = lib.licenses.gpl3Only;
        platforms = lib.platforms.linux;
      };
    }
  ) { };
in
{
  boot.extraModulePackages = [ linuwu-sense ];
  boot.kernelModules = [ "linuwu_sense" ];
  # linuwu_sense and in-tree acer_wmi both bind the Acer WMI GUID; the stock
  # one must lose so the patched module claims the device.
  boot.blacklistedKernelModules = [ "acer_wmi" ];

  # Group owning the writable sysfs knobs (mirrors upstream Makefile), so fans
  # can be adjusted without root.
  users.groups.linuwu_sense = { };
  users.users.rafael.extraGroups = [ "linuwu_sense" ];

  systemd.tmpfiles.rules = map (f: "f ${nitroSense}/${f} 0660 root linuwu_sense - -") [
    "fan_speed"
    "battery_limiter"
    "battery_calibration"
    "usb_charging"
  ];

  # Quiet thermal profile at boot (the actual fix for idle spin-up), then put
  # the fans back in auto (curve-following) mode.
  systemd.services.nitro-quiet-fan = {
    description = "Set Acer Nitro to a quiet fan/thermal profile at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      profile=/sys/firmware/acpi/platform_profile
      fan=${nitroSense}/fan_speed

      # acer-wmi registers platform_profile asynchronously after module load and
      # has lost the race with this unit before ("Failed to register
      # platform_profile class device with empty choices"). Wait up to 5 s.
      for _ in $(seq 1 50); do
        [ -w "$profile" ] && break
        sleep 0.1
      done

      if [ -w "$profile" ]; then
        echo quiet > "$profile"
      else
        echo "platform_profile not writable after 5s; EC left at its default" >&2
      fi

      if [ -w "$fan" ]; then
        echo "0,0" > "$fan" || true
      fi
    '';
  };
}
