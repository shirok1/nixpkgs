{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, libmpdclient
, openssl
, lua5_3
, libid3tag
, flac
, pcre2
, gzip
, perl
, jq
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mympd";
  version = "13.0.5";

  src = fetchFromGitHub {
    owner = "jcorporation";
    repo = "myMPD";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9TOQoef5aVHFeDc0y3k6SCHBeKON5ueU7275HAmPw9M=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    gzip
    perl
    jq
  ];
  preConfigure = ''
    env MYMPD_BUILDDIR=$PWD/build ./build.sh createassets
  '';
  buildInputs = [
    libmpdclient
    openssl
    lua5_3
    libid3tag
    flac
    pcre2
  ];

  cmakeFlags = [
    # Otherwise, it tries to parse $out/etc/mympd.conf on startup.
    "-DCMAKE_INSTALL_SYSCONFDIR=/etc"
    # similarly here
    "-DCMAKE_INSTALL_LOCALSTATEDIR=/var/lib/mympd"
  ];
  hardeningDisable = [
    # causes redefinition of _FORTIFY_SOURCE
    "fortify3"
  ];
  # 5 tests out of 23 fail, probably due to the sandbox...
  doCheck = false;

  meta = {
    homepage = "https://jcorporation.github.io/myMPD";
    description = "A standalone and mobile friendly web mpd client with a tiny footprint and advanced features";
    maintainers = [ lib.maintainers.doronbehar ];
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Plus;
    mainProgram = "mympd";
  };
})
