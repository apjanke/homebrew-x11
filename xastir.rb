class Xastir < Formula
  desc "X amateur station tracking and information reporting"
  homepage "http://www.xastir.org/"
  url "https://downloads.sourceforge.net/xastir/xastir-2.0.6.tar.gz"
  sha256 "e46debd3f67ea5c08e2f85f03e26653871a9cdd6d692c8eeee436c3bc8a8dd43"
  revision 3

  bottle do
    sha256 "2189103506cf98d4cd0fb792b965106617b07909e2953f29544a81d4199f9f81" => :yosemite
    sha256 "59fbf0ad507a20a71def46cb378cb3d41b3bffea8c5abf20d7e74aea8612ca82" => :mavericks
    sha256 "78ea252ec39fe3f5cc9b8894e9758a96bbd309a6d9ef59c5d88338faa80f73fc" => :mountain_lion
  end

  depends_on "proj"
  depends_on "pcre"
  depends_on "berkeley-db"
  depends_on "gdal"
  depends_on "libgeotiff"
  depends_on "openmotif"
  depends_on "jasper"
  depends_on "graphicsmagick"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
