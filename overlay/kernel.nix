final: prev:
let
  inherit (prev) lib;
in
{
  linuxKernels.kernels.linux_zen = prev.linuxKernels.kernels.linux_zen.override (old: {
    extraStructuredConfig = with lib.kernel; {
      CONFIG_SCHED_MUQSS = yes;
    };
  });
}
