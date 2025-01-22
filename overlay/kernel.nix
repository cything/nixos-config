final: prev:
let
  inherit (prev) lib;
in
{
  linuxKernel.kernels.linux_zen = prev.linuxKernel.kernels.linux_zen.override (old: {
    structuredExtraConfig = with lib.kernel; {
      CONFIG_SCHED_MUQSS = yes;
    };
  });
}
