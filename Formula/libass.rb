class Libass < Formula
  desc "Subtitle renderer for the ASS/SSA subtitle format"
  homepage "https://github.com/libass/libass"
  url "https://github.com/libass/libass/releases/download/0.15.0/libass-0.15.0.tar.xz"
  sha256 "9f09230c9a0aa68ef7aa6a9e2ab709ca957020f842e52c5b2e52b801a7d9e833"
  license "ISC"

  bottle do
    cellar :any
    rebuild 1
    sha256 "31612c258eb45354a212ec42c240676b0b297f6a7ef7693b666f3986c14c3c26" => :catalina
    sha256 "adf25e0a4a61f098662952861b1103493f2be98a14975b1cdd27c8aab3a9603a" => :mojave
    sha256 "d3a3e4c2ff26d2a10991134bca875ecafcff6bc8abb193f3c78cb8c0cd57c779" => :high_sierra
    sha256 "028e53840dcad7fa8291fddacd46be8276578a3fa8c058b04975cf56a802101d" => :sierra
  end

  head do
    url "https://github.com/libass/libass.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "harfbuzz"

  on_linux do
    depends_on "fontconfig"
  end

  def install
    system "autoreconf", "-i" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-fontconfig"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "ass/ass.h"
      int main() {
        ASS_Library *library;
        ASS_Renderer *renderer;
        library = ass_library_init();
        if (library) {
          renderer = ass_renderer_init(library);
          if (renderer) {
            ass_renderer_done(renderer);
            ass_library_done(library);
            return 0;
          }
          else {
            ass_library_done(library);
            return 1;
          }
        }
        else {
          return 1;
        }
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-lass", "-o", "test"
    system "./test"
  end
end
