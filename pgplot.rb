class Pgplot < Formula
  desc "Device-independent graphics package for making simple scientific graphs"
  homepage "http://www.astro.caltech.edu/~tjp/pgplot/"
  url "ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot522.tar.gz"
  mirror "https://distfiles.macports.org/pgplot/pgplot522.tar.gz"
  mirror "ftp://ftp.us.horde.org/pub/linux/gentoo/distro/distfiles/pgplot522.tar.gz"
  version "5.2.2"
  sha256 "a5799ff719a510d84d26df4ae7409ae61fe66477e3f1e8820422a9a4727a5be4"
  revision 1

  bottle do
    revision 2
    sha256 "b081503a0fbd3b50659c319dc9d482833ade23996f853df350ef585adca45b8b" => :el_capitan
    sha256 "73d268e20bba27b848959044fc9ba49bbd257a32be1f55b0ae106495d4c016d9" => :yosemite
    sha256 "f01bff0d8714aa5ca73cf5ae92945fe5d72344dd2c3b5e4bfcc071ba702b8a1b" => :mavericks
  end

  option "with-button", "Install libbutton"

  depends_on :x11
  depends_on :fortran

  resource "button" do
    url "http://www.ucm.es/info/Astrof/software/button/button.tar.gz"
    sha256 "a7cd0697db00858f9c16bb8fc3c7b7773a0486ac9b3c9a73633c388d1417e6d0"
    version "1.0"
  end

  # from MacPorts: https://trac.macports.org/browser/trunk/dports/graphics/pgplot/files
  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/b520c2d/pgplot/patch-makemake.diff"
    sha256 "1af44204240dd91a59c899714b4f6012ff1eccfcad8f2133765beec34d6f1423"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/patches/b520c2d/pgplot/patch-proccom.c.diff"
    sha256 "93c55078389c660407c0052569d3ed543c92107c139c765d207b90687cfb7a0c"
  end

  def install
    ENV.deparallelize
    ENV.append "CPPFLAGS", "-DPG_PPU"
    # allow long lines in the fortran code (for long homebrew PATHs)
    ENV.append "FCFLAGS", "-ffixed-line-length-none"

    # re-hardcode the share dir
    inreplace "src/grgfil.f", "/usr/local/pgplot", share
    # perl may not be in /usr/local
    inreplace "makehtml", "/usr/local/bin/perl", which("perl")
    # prevent a "dereferencing pointer to incomplete type" in libpng
    inreplace "drivers/pndriv.c", "setjmp(png_ptr->jmpbuf)", "setjmp(png_jmpbuf(png_ptr))"

    # configure options
    (buildpath/"sys_darwin/homebrew.conf").write <<-EOS.undent
      XINCL="#{ENV.cppflags}"
      MOTIF_INCL=""
      ATHENA_INCL=""
      TK_INCL=""
      RV_INCL=""
      FCOMPL="#{ENV.fc}"
      FFLAGC="#{ENV.fcflags}"
      FFLAGD=""
      CCOMPL="#{ENV.cc}"
      CFLAGC="#{ENV.cppflags}"
      CFLAGD=""
      PGBIND_FLAGS="bsd"
      LIBS="#{ENV.ldflags} -lX11"
      MOTIF_LIBS=""
      ATHENA_LIBS=""
      TK_LIBS=""
      RANLIB="#{which "ranlib"}"
      SHARED_LIB="libpgplot.dylib"
      SHARED_LD="#{ENV.fc} -dynamiclib -single_module $LDFLAGS -lX11 -install_name libpgplot.dylib"
      SHARED_LIB_LIBS="#{ENV.ldflags} -lpng -lX11"
      MCOMPL=""
      MFLAGC=""
      SYSDIR="$SYSDIR"
      CSHARED_LIB="libcpgplot.dylib"
      CSHARED_LD="#{ENV.fc} -dynamiclib -single_module $LDFLAGS -lX11"
      EOS

    mkdir "build" do
      # activate drivers
      cp "../drivers.list", "."
      ["GIF", "VGIF", "LATEX", "PNG", "TPNG", "PS",
       "VPS", "CPS", "VCPS", "XWINDOW", "XSERVE"].each do |drv|
        inreplace "drivers.list", %r{^! (.*\/#{drv} .*)}, '  \1'
      end

      # make everything
      system "../makemake .. darwin; make; make cpg; make pgplot.html"

      # install
      bin.install "pgxwin_server", "pgbind"
      lib.install Dir["*.dylib", "*.a"]
      include.install Dir["*.h"]
      share.install Dir["*.txt", "*.dat"]
      doc.install Dir["*.doc", "*.html"]
      (share/"examples").install Dir["*demo*", "../examples/pgdemo*.f", "../cpg/cpgdemo*.c", "../drivers/*/pg*demo.*"]
    end

    if build.with? "button"
      resource("button").stage do
        inreplace "Makefile", "f77", "#{ENV.fc} #{ENV.fcflags}"
        system "make"
        lib.install "libbutton.a"
      end
    end
  end
end
