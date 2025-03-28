update:
    git branch -D update || true
    git switch -c update
    nix flake update --commit-lock-file
    git push -f
    git switch main

upgrade:
    git switch update
    sudo nixos-rebuild switch -L --flake . --use-substitutes
    nixos-rebuild switch -L --flake .#chunk --target-host root@2a0f:85c1:840:2bfb::1 --use-substitutes
    home-manager -L switch --flake .
    git switch main
    git merge update
    git branch -d update

switch:
    sudo nixos-rebuild switch -L --flake . --use-substitutes
    nixos-rebuild switch -L --flake .#chunk --target-host root@2a0f:85c1:840:2bfb::1 --use-substitutes
    home-manager -L switch --flake .
