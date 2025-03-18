final: prev: {
  attic-server = prev.attic-server.overrideAttrs {
    patches = [
      ./prefetch-8-chunks.patch
    ];
  };
}
