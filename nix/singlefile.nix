{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  chromium,
  python3,
}:
buildNpmPackage {
  pname = "single-file-cli";
  version = "2.0.73";

  src = fetchFromGitHub {
    owner = "gildas-lormeau";
    repo = "single-file-cli";
    rev = "0b87ca9167f6cb2b036770d38e9b6bbfaf47abc5";
    hash = "sha256-fMedP+wp1crHUj9/MVyG8XSsl1PA5bp7/HL4k+X0TRg=";
  };
  npmDepsHash = "sha256-nnOMBb9mHNhDejE3+Kl26jsrTRxSSg500q1iwwVUqP8=";

  nativeCheckInputs = [chromium];
  doCheck = stdenv.hostPlatform.isLinux;

  postBuild = ''
    patchShebangs ./single-file
  '';

  checkPhase = ''
    runHook preCheck

    ${python3}/bin/python -m http.server --bind 127.0.0.1 &
    pid=$!

    ./single-file \
      --browser-headless \
      --browser-executable-path chromium-browser\
      http://127.0.0.1:8000

    grep -F 'Page saved with SingleFile' 'Directory listing for'*.html

    kill $pid
    wait

    runHook postCheck
  '';

  meta = {
    description = "CLI tool for saving a faithful copy of a complete web page in a single HTML file";
    homepage = "https://github.com/gildas-lormeau/single-file-cli";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [n8henrie];
    mainProgram = "single-file";
  };
}
