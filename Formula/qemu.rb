class Qemu < Formula
    desc "Emulator for x86 and PowerPC"
    homepage "https://www.qemu.org/"
    license "GPL-2.0-only"
    revision 1
    head "https://git.qemu.org/git/qemu.git"
  
    stable do
      url "https://download.qemu.org/qemu-6.0.0.tar.xz"
      sha256 "87bc1a471ca24b97e7005711066007d443423d19aacda3d442558ae032fa30b9"
    
      # utm patch
      patch do
        url "https://github.com/utmapp/UTM/raw/master/patches/qemu-6.0.0.patch"
        sha256 "3cc668069bdadde0d390de16e657dd4c0bb30f020ed5f0b55f38fb7ddf9edfec"
      end

      # xcode 12.5 version header fix
      patch do
        url "https://github.com/akihikodaki/qemu/commit/c1db57c4362f44e50f1411d8dde79d768c2bb999.patch"
        sha256 "a4c52faaf94535932b3a8638e01408e57563ff541a6fe8658dbe06029a09ea5d"
      end
    end
  
    #bottle do
    #end
  
    depends_on "libtool" => :build
    depends_on "meson" => :build
    depends_on "ninja" => :build
    depends_on "pkg-config" => :build
  
    depends_on "glib"
    depends_on "gnutls"
    depends_on "jpeg"
    depends_on "libpng"
    depends_on "libslirp"
    depends_on "libssh"
    depends_on "libusb"
    depends_on "lzo"
    depends_on "ncurses"
    depends_on "nettle"
    depends_on "pixman"
    depends_on "snappy"
    depends_on "vde"
  
    # 820KB floppy disk image file of FreeDOS 1.2, used to test QEMU
    resource "test-image" do
      url "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.2/FD12FLOPPY.zip"
      sha256 "81237c7b42dc0ffc8b32a2f5734e3480a3f9a470c50c14a9c4576a2561a35807"
    end
  
    def install
      ENV["LIBTOOL"] = "glibtool"
  
      args = %W[
        --prefix=#{prefix}
        --cc=#{ENV.cc}
        --host-cc=#{ENV.cc}
        --disable-debug-info
        --disable-bsd-user
        --disable-guest-agent
        --enable-curses
        --enable-libssh
        --enable-slirp=system
        --enable-vde
        --enable-lto
        --extra-cflags=-DNCURSES_WIDECHAR=1
        --disable-sdl
        --disable-gtk
      ]
      # Sharing Samba directories in QEMU requires the samba.org smbd which is
      # incompatible with the macOS-provided version. This will lead to
      # silent runtime failures, so we set it to a Homebrew path in order to
      # obtain sensible runtime errors. This will also be compatible with
      # Samba installations from external taps.
      args << "--smbd=#{HOMEBREW_PREFIX}/sbin/samba-dot-org-smbd"
  
      on_macos do
        args << "--enable-cocoa"
      end
  
      system "./configure", *args
      system "make", "V=1", "install"
    end
  
    test do
      expected = build.stable? ? version.to_s : "QEMU Project"
      assert_match expected, shell_output("#{bin}/qemu-system-aarch64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-alpha --version")
      assert_match expected, shell_output("#{bin}/qemu-system-arm --version")
      assert_match expected, shell_output("#{bin}/qemu-system-cris --version")
      assert_match expected, shell_output("#{bin}/qemu-system-hppa --version")
      assert_match expected, shell_output("#{bin}/qemu-system-i386 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-m68k --version")
      assert_match expected, shell_output("#{bin}/qemu-system-microblaze --version")
      assert_match expected, shell_output("#{bin}/qemu-system-microblazeel --version")
      assert_match expected, shell_output("#{bin}/qemu-system-mips --version")
      assert_match expected, shell_output("#{bin}/qemu-system-mips64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-mips64el --version")
      assert_match expected, shell_output("#{bin}/qemu-system-mipsel --version")
      assert_match expected, shell_output("#{bin}/qemu-system-moxie --version")
      assert_match expected, shell_output("#{bin}/qemu-system-nios2 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-or1k --version")
      assert_match expected, shell_output("#{bin}/qemu-system-ppc --version")
      assert_match expected, shell_output("#{bin}/qemu-system-ppc64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-riscv32 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-riscv64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-rx --version")
      assert_match expected, shell_output("#{bin}/qemu-system-s390x --version")
      assert_match expected, shell_output("#{bin}/qemu-system-sh4 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-sh4eb --version")
      assert_match expected, shell_output("#{bin}/qemu-system-sparc --version")
      assert_match expected, shell_output("#{bin}/qemu-system-sparc64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-tricore --version")
      assert_match expected, shell_output("#{bin}/qemu-system-x86_64 --version")
      assert_match expected, shell_output("#{bin}/qemu-system-xtensa --version")
      assert_match expected, shell_output("#{bin}/qemu-system-xtensaeb --version")
      resource("test-image").stage testpath
      assert_match "file format: raw", shell_output("#{bin}/qemu-img info FLOPPY.img")
    end
end