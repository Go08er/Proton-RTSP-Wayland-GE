{
  lib,
  stdenvNoCC,
  fetchurl,
  gnutar,
  gzip,
  archiveUrl ? "https://github.com/Go08er/Proton-RTSP-Wayland-GE/releases/download/v11.1.0-beta.4/Proton-RTSP-Wayland-GE-Beta4.tar.gz",
  archiveHash ? "sha256-POos9fR2a0f3Q5bLtNXG3PdTTcNk2KGMboF4ODgF2Ek=",
  archivePath ? null,
  steamDisplayName ? "Proton RTSP Wayland GE Beta 4",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-rtsp-wayland-ge-bin";
  version = "11.1.0-beta.4";

  src =
    if archivePath != null then
      archivePath
    else
      fetchurl {
        url = archiveUrl;
        hash = archiveHash;
      };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  nativeBuildInputs = [
    gnutar
    gzip
  ];

  installPhase = ''
    runHook preInstall

    echo "${finalAttrs.pname} is intended for programs.steam.extraCompatPackages." > "$out"
    mkdir -p "$steamcompattool"
    tar -xzf "$src" -C "$steamcompattool" --strip-components=1
    test -f "$steamcompattool/compatibilitytool.vdf"
    test -x "$steamcompattool/proton"

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail \
        '"display_name" "Proton RTSP Wayland GE Beta 4"' \
        '"display_name" "${steamDisplayName}"'
  '';

  meta = {
    description = "RTSP Proton compatibility tool with selected Proton-GE native-Wayland patches";
    homepage = "https://github.com/Go08er/Proton-RTSP-Wayland-GE";
    # lsteamclient's Steamworks SDK terms are not represented here; the packaged licenses/ tree is authoritative.
    license = with lib.licenses; [
      asl20
      bsd2
      bsd3
      gpl3Plus
      lgpl21Plus
      mit
      ofl
      unicode-30
      x11
      zlib
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
