final: prev: {
  attic-server = prev.attic-server.overrideAttrs {
    patches = [
      ./prefetch-32-chunks.patch
    ];
  };
}
