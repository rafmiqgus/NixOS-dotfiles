{ pkgs, inputs, lib, ... }:

let
  ambxst = "/run/current-system/sw/bin/ambxst";
  awk = "${pkgs.gawk}/bin/awk";
  base = ".dotfiles/home/config/ambxst/mods";

  repos = {
    drpezzer-mods = inputs.drpezzer-mods;
    aspect-mods = inputs.aspect-mods;
    # package root is the repo root, and Ambxst rejects a symlinked root: wrap it in a real subdir
    faceid = pkgs.runCommand "ambxst-faceid-pkg" { } ''
      mkdir -p $out
      cp -r --no-preserve=mode ${inputs.ambxst-faceid-mod} $out/pkg
    '';
  };

  mods = {
    "drpezzer.roadie" = { path = "drpezzer-mods/packages/roadie"; enable = true; };
    "drpezzer.ambxst-skwd-wall" = { path = "drpezzer-mods/packages/ambxst-skwd-wall"; enable = true; };
    "community.linux-faceid" = { path = "faceid/pkg"; enable = true; };
    "aspect.agent-usage-panel" = { path = "aspect-mods/packages/agent-usage-panel"; enable = true; };
  };

  repoLinks = lib.mapAttrs' (
    name: src: lib.nameValuePair "${base}/${name}" { source = src; }
  ) repos;

  pam_faceid_lib = pkgs.callPackage ./linux-faceid/pam_faceid.nix { inherit inputs; };
  faceid-daemon-python-env = pkgs.python3.withPackages (ps: with ps; [ opencv-python numpy ]);
in
{
  home.file = repoLinks // {
    "/usr/lib/security/pam_faceid.so".source = "${pam_faceid_lib}/lib/pam_faceid.so";
    ".local/share/linux-faceid/face_detection_yunet_2023mar.onnx".source =
      "${inputs.ambxst-faceid-mod}/models/face_detection_yunet_2023mar.onnx";
    ".local/share/linux-faceid/face_recognition_sface_2021dec.onnx".source =
      "${inputs.ambxst-faceid-mod}/models/face_recognition_sface_2021dec.onnx";
    ".local/share/linux-faceid/models/face_detection_yunet_2023mar.onnx".source =
      "${inputs.ambxst-faceid-mod}/models/face_detection_yunet_2023mar.onnx";
    ".local/share/linux-faceid/models/face_recognition_sface_2021dec.onnx".source =
      "${inputs.ambxst-faceid-mod}/models/face_recognition_sface_2021dec.onnx";
  };

  home.activation.ambxstMods = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (
      lib.mapAttrsToList (id: m: ''
        if ${ambxst} mods list 2>/dev/null | ${awk} -v id='${id}' '$2==id{f=1} END{exit !f}'; then
          run ${ambxst} mods update '${id}' || echo "ambxst mods: update ${id} failed" >&2
        else
          run ${ambxst} mods install "$HOME/${base}/${m.path}" \
            ${lib.optionalString m.enable "&& run ${ambxst} mods enable '${id}'"} \
            || echo "ambxst mods: install ${id} failed" >&2
        fi
      '') mods
    )
  );

  # --- FaceId mod ---
  home.packages = [ pam_faceid_lib ];

  systemd.user.services.linux-faceid-backend = {
    Unit = {
      Description = "Ambxst linux-faceid mod backend";
      After = [ "network.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${faceid-daemon-python-env}/bin/python ${inputs.ambxst-faceid-mod}/payload/scripts/faceid-daemon.py";
    };
  };

  # --- Roadie ---

}
