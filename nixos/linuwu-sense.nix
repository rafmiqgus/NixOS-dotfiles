# Div-Linuwu-Sense: patched acer-wmi kernel module restoring fan / thermal
# control on Acer Nitro/Predator laptops. Fixes the ANV15-51 "fans spin at
# idle" behaviour by handing the EC a real thermal profile instead of letting
# it free-run its default curve.
#
# This is the same driver DAMX uses on the CachyOS side, packaged declaratively
# for NixOS (no `make install`; NixOS handles blacklist/load/perms/service).
# Secure Boot must be OFF (it is on this machine) so the unsigned module loads.
#
# Exposed after rebuild + reboot:
#   /sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense/fan_speed
#   /sys/firmware/acpi/platform_profile   (quiet | balanced | performance)
#
# fan_speed format: "CPU,GPU" — 0=auto, 1=min (discouraged), 100=max, e.g. "40,40".

{ config, lib, pkgs, ... }:

let
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
  # Build the module and make it available to the running kernel.
  boot.extraModulePackages = [ linuwu-sense ];

  # linuwu_sense and the in-tree acer_wmi both bind the Acer WMI GUID; the
  # stock one must lose so our patched module claims the device.
  boot.blacklistedKernelModules = [ "acer_wmi" ];
  boot.kernelModules = [ "linuwu_sense" ];

  # Group that owns the writable sysfs knobs (mirrors upstream Makefile).
  users.groups.linuwu_sense = { };
  users.users.rafael.extraGroups = [ "linuwu_sense" ];

  # Make the nitro_sense knobs group-writable so you (in the linuwu_sense group)
  # can adjust fans without root. Paths per upstream's nitro field list.
  systemd.tmpfiles.rules =
    let base = "/sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense";
    in map (f: "f ${base}/${f} 0660 root linuwu_sense - -") [
      "fan_speed"
      "battery_limiter"
      "battery_calibration"
      "usb_charging"
    ];

  # Hand the EC a quiet thermal profile at boot — the actual fix for idle spin-up.
  # If the standard platform_profile isn't wired up, fall back to fan_speed=auto.
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
      fan=/sys/module/linuwu_sense/drivers/platform:acer-wmi/acer-wmi/nitro_sense/fan_speed

      # acer-wmi registers platform_profile asynchronously after the module
      # loads and has been seen to lose the race with this unit ("Failed to
      # register platform_profile class device with empty choices" at boot,
      # then this service no-ops and the EC stays on its "balanced" default).
      # Wait for the knob rather than skipping it.
      for _ in $(seq 1 50); do
        if [ -w "$profile" ]; then break; fi
        sleep 0.1
      done

      if [ -w "$profile" ]; then
        echo quiet > "$profile"
      else
        echo "platform_profile not writable after 5s; EC left at its default" >&2
      fi

      # Ensure the fan controller is in auto (curve-following), not forced.
      if [ -w "$fan" ]; then
        echo "0,0" > "$fan" || true
      fi
    '';
  };
}
