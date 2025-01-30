final: prev: {
  vscode-extensions = prev.vscode-extensions // {
    github = prev.vscode-extensions.github // {
      codespaces = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "github";
          name = "codespaces";
          version = "1.17.3";
          hash = "sha256-idJFYHJ4yeqpFZBX55Y0v1yfzgqyhS0MrC4yIto7i7w=";
        };
      };
    };
  };
}
