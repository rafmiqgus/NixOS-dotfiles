{ config, lib, ... }:

 {
   programs.starship = {
     enable = true;
     enableZshIntegration = false;
     #configPath = "/home/rafael/.config/starship/starship.toml";
   };
 }
