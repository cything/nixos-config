final: prev: {
  zipline = prev.zipline.overrideAttrs {
    patches = [
      ./no-check-bucket.patch
    ];
  };
}
