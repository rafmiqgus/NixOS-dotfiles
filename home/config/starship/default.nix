{ config, lib, ... }:

 {
   programs.starship = {
     enable = true;
     enableZshIntegration = true;
     #configPath = "/home/rafael/.config/starship/starship.toml";
   };
 }
