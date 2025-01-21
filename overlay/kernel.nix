final: prev: let
  inherit (prev) lib;
in {
  linux_zen = prev.linux_zen.override (old: {
    extraStructuredConfig = with lib.kernel; {
      CONFIG_SCHED_MUQSS = yes;
    };
  });
}
