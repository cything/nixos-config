final: prev: rec {
  sway-unwrapped = (prev.sway-unwrapped.override (old: {
    inherit wlroots;
  }))
    .overrideAttrs (prevAttrs: {
    version = "1.10";
    src = final.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = "0b08dce08cbcf515103d8a7fd8c390ed04c93428";
      hash = "sha256-Qo/Fr/sc5lqHTlzf7YC282TkF1ZJtDhTNiL31R0c5NY=";
    };
  });

  wlroots = prev.wlroots_0_18.overrideAttrs (prevAttrs: {
    version = "0.19";
    src = final.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "wlroots";
      repo = "wlroots";
      rev = "eb85831284b6f46301e41205c5d4e08fc5b92c27";
      hash = "sha256-itELarxPdIBx5EhDxXZht4Iw8kddaiHVHuAWtf0pGfU=";
    };
  });
}
