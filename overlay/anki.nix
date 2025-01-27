inputs: final: prev: {
  anki = prev.anki.overrideAttrs (old: {
    version = "25.01";
    src = inputs.anki;
  });
}
