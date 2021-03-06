class Rdesktop < Formula
  desc "UNIX client for connecting to Windows Remote Desktop Services"
  homepage "http://www.rdesktop.org/"
  url "https://downloads.sourceforge.net/project/rdesktop/rdesktop/1.8.3/rdesktop-1.8.3.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/r/rdesktop/rdesktop_1.8.3.orig.tar.gz"
  sha256 "88b20156b34eff5f1b453f7c724e0a3ff9370a599e69c01dc2bf0b5e650eece4"

  bottle do
    revision 2
    sha256 "03e7e306cfaa344771d0ae57a34c846748b4f217c10e63e239e4b8247d04141f" => :el_capitan
    sha256 "2509dcf0e5195165a7636649d214098e20757548fc79b4744d65f0840a97988f" => :yosemite
    sha256 "7c5890bcc5d0d2f211db4aa4cdd0eb26fc2e2e3fb0a09d44caa185821187cca8" => :mavericks
  end

  option "with-smartcard", "Build with Smart Card Support"

  depends_on "openssl"
  depends_on :x11

  # Note: The patch below is meant to remove the reference to the
  # undefined symbol SCARD_CTL_CODE. Since we are compiling with
  # --disable-smartcard (by default), we don't need it anyway (and it should
  # probably have been #ifdefed in the original code).
  # upstream bug report: https://sourceforge.net/p/rdesktop/bugs/352/
  patch :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-credssp
      --with-openssl=#{Formula["openssl"].opt_prefix}
      --x-includes=#{MacOS::X11.include}
      --x-libraries=#{MacOS::X11.lib}
    ]

    if build.with? "smartcard"
      args << "--enable-smartcard"
    else
      args << "--disable-smartcard"
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rdesktop -help 2>&1", 64)
  end
end

__END__
diff --git a/scard.c b/scard.c
index caa0745..5521ee9 100644
--- a/scard.c
+++ b/scard.c
@@ -2152,7 +2152,6 @@ TS_SCardControl(STREAM in, STREAM out)
	{
		/* Translate to local encoding */
		dwControlCode = (dwControlCode & 0x3ffc) >> 2;
-		dwControlCode = SCARD_CTL_CODE(dwControlCode);
	}
	else
	{
@@ -2198,7 +2197,7 @@ TS_SCardControl(STREAM in, STREAM out)
	}

 #ifdef PCSCLITE_VERSION_NUMBER
-	if (dwControlCode == SCARD_CTL_CODE(3400))
+	if (0)
	{
		int i;
		SERVER_DWORD cc;
