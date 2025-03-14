final: prev: {
  bitwarden-desktop = prev.bitwarden-desktop.overrideAttrs (
    finalAttrs: prevAttrs: {
      patches = prevAttrs.patches ++ [
        ./ssh-agent-no-confirm.patch
      ];
    }
  );
}
