This flake was created because I was not fully satisfied with the existing flakes I've used for Vintage Story. I don't even play this game really, but I wanted to have this created if I ever do since my friends play often. I could stop maintaining this repo at any point, but hopefully it will simply sustain itself.

The biggest issue I was attempting to solve was that versions were not tagged to the latest release automatically regardless of the stable or unstable channel. Part of the problem was that the Unstable channel is not updated to the latest release, and instead lags behind Stable by hosting release candidate builds that sometimes fall behind the latest stable release. I personally believe that the Unstable branch should host the latest release, even if it mirrors the Stable branch. But, this prevents needing to have the devs make that change.

This flake will automatically update to the latest release regardless of Stable or Unstable channel. It also enables the use of the latest Unstable or Stable builds, if one wishes to remain on a specific release channel.

Enable this repo in your flake.nix inputs using `vintagestory.url = "github.com/powerofthe69/vintagestory-latest-nix";`.

Enable the overlay using `nixpkgs.overlays = [ vintagestory.overlay.default ];`.

To install the latest version, which will be either stable or unstable, use:

`environment.systemPackages = with pkgs; [ vintagestory ];` or `users.users.youruser.packages = with pkgs; [ vintagestory ];`

Stable can be installed using:

`environment.systemPackages = with pkgs; [ vintagestory-stable ];` or `users.users.youruser.packages = with pkgs; [ vintagestory-stable ];`

Unstable can be installed using:

`environment.systemPackages = with pkgs; [ vintagestory-unstable ];` or `users.users.youruser.packages = with pkgs; [ vintagestory-unstable ];`
