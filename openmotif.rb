class Openmotif < Formula
  desc "LGPL release of the Motif toolkit"
  homepage "https://motif.ics.com/motif"
  url "https://downloads.sourceforge.net/project/motif/Motif%202.3.4%20Source%20Code/motif-2.3.4-src.tgz"
  sha256 "637efa09608e0b8f93465dbeb7c92e58ebb14c4bc1b488040eb79a65af3efbe0"

  bottle do
    revision 2
    sha256 "a7306b58b4f448614f89ede7bbf21e6d9f8618268ff99d039ecfc0473b29e3f3" => :el_capitan
    sha256 "b858f095abc5fce79c4f32070465973e72418b3a5eda9e66ea76b3cb019621ea" => :yosemite
    sha256 "3a8210579e8fc6412c46e4ab91b910ea0de83d19265047729ed6115062b04479" => :mavericks
  end

  option :universal

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "jpeg" => :optional
  depends_on "libpng" => :optional
  depends_on :x11

  if build.universal?
    depends_on "flex" => [:build, :universal]
  end

  conflicts_with "lesstif",
    :because => "Lesstif and Openmotif are complete replacements for each other"

  # Removes a flag clang doesn't recognise/accept as valid
  # From https://trac.macports.org/browser/trunk/dports/x11/openmotif/files/patch-configure.ac.diff
  # "Only weak aliases are supported on darwin"
  # Adapted from https://trac.macports.org/browser/trunk/dports/x11/openmotif/files/patch-lib-XmP.h.diff
  patch :DATA

  def install
    ENV.universal_binary if build.universal?

    inreplace "autogen.sh", "libtoolize", "glibtoolize"

    # https://trac.macports.org/browser/trunk/dports/x11/openmotif/Portfile#L59
    # Compile breaks if these three files are present.
    %w[demos/lib/Exm/String.h demos/lib/Exm/StringP.h demos/lib/Exm/String.c].each do |f|
      rm_rf f
    end

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    args << "--disable-jpeg" if build.without? "jpeg"
    args << "--disable-png" if build.without? "libpng"

    system "./autogen.sh", *args
    system "make", "install"

    # Avoid conflict with Perl
    mv man3/"Core.3", man3/"openmotif-Core.3"
  end

  test do
    assert_match /no source file specified/, pipe_output("#{bin}/uil 2>&1")
  end
end

__END__
diff --git a/configure.ac b/configure.ac
index 6db447c..22ea2e9 100644
--- a/configure.ac
+++ b/configure.ac
@@ -164,9 +164,9 @@ fi
 if test x$GCC = xyes
 then
     CFLAGS="$CFLAGS -Wall -g -fno-strict-aliasing -Wno-unused -Wno-comment"
-    if test ` $CC -dumpversion | sed -e 's/\(^.\).*/\1/'` = "4" ; then
-        CFLAGS="$CFLAGS -fno-tree-ter"
-    fi
+    #if test ` $CC -dumpversion | sed -e 's/\(^.\).*/\1/'` = "4" ; then
+        #CFLAGS="$CFLAGS -fno-tree-ter"
+    #fi
 fi
 AC_DEFINE(NO_OL_COMPAT, 1, "No OL Compatability")


diff --git a/lib/Xm/XmP.h b/lib/Xm/XmP.h
index 97c7c71..50b1585 100644
--- a/lib/Xm/XmP.h
+++ b/lib/Xm/XmP.h
@@ -1442,9 +1442,13 @@ extern void _XmDestroyParentCallback(

 #endif /* NO_XM_1_2_BC */

-#if __GNUC__
+#ifdef __GNUC__
 #  define XM_DEPRECATED  __attribute__((__deprecated__))
-#  define XM_ALIAS(sym)  __attribute__((__weak__,alias(#sym)))
+#  ifndef __APPLE__
+#    define XM_ALIAS(sym)  __attribute__((__weak__,alias(#sym)))
+#  else
+#   define XM_ALIAS(sym)
+#  endif
 #else
 #  define XM_DEPRECATED
 #  define XM_ALIAS(sym)
