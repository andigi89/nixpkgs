{ stdenv, fetchFromGitHub, pkg-config, automake, autoconf
, zlib, boost, openssl, libtool, python, libiconv, ncurses, SystemConfiguration
}:

let
  version = "1.2.6";
  formattedVersion = stdenv.lib.replaceChars ["."] ["_"] version;

  # Make sure we override python, so the correct version is chosen
  # for the bindings, if overridden
  boostPython = boost.override { enablePython = true; inherit python; };

in stdenv.mkDerivation {
  pname = "libtorrent-rasterbar";
  inherit version;

  src = fetchFromGitHub {
    owner = "arvidn";
    repo = "libtorrent";
    rev = "libtorrent-${formattedVersion}";
    sha256 = "140gc9j6lymy5kr0gviqznpg4hl57rz2q6vpb9sjkkimr19lrvdr";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ automake autoconf libtool pkg-config ];

  buildInputs = [ boostPython openssl zlib python libiconv ncurses ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ SystemConfiguration ];

  preConfigure = "./autotool.sh";

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/${python.libPrefix}" "$python"
  '';

  outputs = [ "out" "dev" "python" ];

  configureFlags = [
    "--enable-python-binding"
    "--with-libiconv=yes"
    "--with-boost=${boostPython.dev}"
    "--with-boost-libdir=${boostPython.out}/lib"
  ];

  meta = with stdenv.lib; {
    homepage = "https://libtorrent.org/";
    description = "A C++ BitTorrent implementation focusing on efficiency and scalability";
    license = licenses.bsd3;
    maintainers = [ maintainers.phreedom ];
    broken = stdenv.isDarwin;
    platforms = platforms.unix;
  };
}
