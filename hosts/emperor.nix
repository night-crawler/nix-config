{ config, lib, ... }:
{
  networking.hosts = lib.mkIf (config.networking.hostName == "emperor") {
    "139.162.155.69" = [
      "force.fm"
      "hs.force.fm"
      "hs-ui.force.fm"
      "img.force.fm"
      "synapse.force.fm"
      "bw.force.fm"
    ];
  };
}
