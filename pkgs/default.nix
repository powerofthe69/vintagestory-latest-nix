{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  dotnet-runtime_8,
  xorg,
  libglvnd,
  openal,
  fontconfig,
  freetype,
  cairo,
  pango,
  gtk3,
  gdk-pixbuf,
  zlib,
  libpulseaudio,
  alsa-lib,
  sourceData, # Pass JSON as argument
  channel ? "latest",
}:

let
  isLatest = channel == "latest";
  suffix = if isLatest then "" else "-${channel}";
  binName = "vintagestory${suffix}";
  titleName = if isLatest then "Vintage Story" else "Vintage Story (${channel})";

in
stdenv.mkDerivation rec {
  pname = "vintagestory${suffix}";
  version = sourceData.version;

  src = fetchurl {
    url = sourceData.url;
    sha256 = sourceData.hash;
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems # Helper to install desktop files cleanly
  ];

  buildInputs = [
    dotnet-runtime_8
    stdenv.cc.cc.lib
    zlib
    xorg.libX11
    xorg.libXi
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXxf86vm
    libglvnd
    openal
    fontconfig
    freetype
    cairo
    pango
    gtk3
    gdk-pixbuf
    libpulseaudio
    alsa-lib
  ];

  # Ignore internal C# dlls, patch native libs
  autoPatchelfIgnoreMissingDeps = [
    "*.dll"
    "System.*"
    "Microsoft.*"
    "Lib.*"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vintage-story
    cp -r * $out/share/vintage-story/
    install -Dm644 ${./icon.png} $out/share/icons/hicolor/256x256/apps/${binName}.png

    # The Wrapper
    makeWrapper ${dotnet-runtime_8}/bin/dotnet $out/bin/${binName} \
      --add-flags "$out/share/vintage-story/Vintagestory.dll" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set DOTNET_ROOT "${dotnet-runtime_8}" \
      --set LD_PRELOAD "${xorg.libXcursor}/lib/libXcursor.so.1"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = binName;
      desktopName = titleName;
      exec = binName;
      icon = binName;
      comment = "Uncompromising Wilderness Survival";
      categories = [
        "Game"
        "Simulation"
      ];
    })
  ];

  meta = with lib; {
    description = "An in-depth voxel survival game";
    homepage = "https://www.vintagestory.at/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "vintagestory";
  };
}
