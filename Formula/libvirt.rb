class Libvirt < Formula
  desc "C virtualization API"
  homepage "https://www.libvirt.org"
  url "https://libvirt.org/sources/libvirt-7.9.0.tar.xz"
  sha256 "829cf2b5f574279c40f0446e1168815d3f36b89710560263ca2ce70256f72e8c"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://github.com/libvirt/libvirt.git", branch: "master"

  livecheck do
    url "https://libvirt.org/sources/"
    regex(/href=.*?libvirt[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  # apple silicon detection
  patch :p1 do
      url "https://github.com/ihsakashi/libvirt/commit/0f062221ae23e6ea0ed5e6ba65d47395581cb143.patch"
      sha256 "1fa95c485e6cd27bd9b6ac1af9f3d1cdd1f7d7e1baa472e35b5fd3c5f940cf13"
  end


  # [libvirt PATCH 0/5] meson: Introduce qemu_datadir option - https://listman.redhat.com/archives/libvir-list/2021-November/msg00425.html
  # [libvirt PATCH 1/5] meson: Define qemu_moddir correctly - https://listman.redhat.com/archives/libvir-list/2021-November/msg00426.html
  patch :p1 do
    url "https://github.com/libvirt/libvirt/commit/591cb9d0d5e40eeff60cb18845197508b2878940.patch"
    sha256 "ef24eb83a328e391bb44684e9664b3c4083b9c60864a78c22b7c0ea5268926f6"
  end
  # [libvirt PATCH 2/5] qemu: Set QEMU data location correctly - https://listman.redhat.com/archives/libvir-list/2021-November/msg00427.html
  patch :p1 do
      url "https://github.com/libvirt/libvirt/commit/b41c95af5b0d9f9cdb02105fc08a5c0cf6a50882.patch"
      sha256 "4a44e112c8f24f9d8d6dcf9400115b50415d064f29a82649292e6b7d6b02f50d"
  end
  # [libvirt PATCH 3/5] qemu: Rename interop locations - https://listman.redhat.com/archives/libvir-list/2021-November/msg00428.html
  patch :p1 do
    url "https://github.com/libvirt/libvirt/commit/c46c2e15d1d1d30c5d1c9a62715d659a906a3d1e.patch"
    sha256 "6c2746662499cded00c2e75e7c12ef630cc3107c142766ebaba7a0bd8d87032b"
  end
  # [libvirt PATCH 4/5] meson: Introduce qemu_datadir option - https://listman.redhat.com/archives/libvir-list/2021-November/msg00429.html
  patch :p1 do
    url "https://github.com/libvirt/libvirt/commit/794af15f24efd4496aef2afaeb6d30cb5a7b4e63.patch"
    sha256 "76e1f061898c51cb1c6912671638a202b88ff1d191884e6cee2581532d031633"
  end
  # [libvirt PATCH 5/5] spec: Explicitly provide locations for QEMU data - https://listman.redhat.com/archives/libvir-list/2021-November/msg00430.html
  patch :p1 do
    url "https://github.com/libvirt/libvirt/commit/c5dc658ea8c764f0e6b15fa4da9daff97a8d2ccf.patch"
    sha256 "6a17eaaab58b7d922f174a4a67b2ebb7b981838e6728abf24741483c215e4da0"
  end
  
  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "perl" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gnu-sed"
  depends_on "gnutls"
  depends_on "grep"
  depends_on "libgcrypt"
  depends_on "libiscsi"
  depends_on "libssh2"
  depends_on "yajl"

  uses_from_macos "curl"
  uses_from_macos "libxslt"

  on_macos do
    depends_on "rpcgen" => :build
  end

  on_linux do
    depends_on "libtirpc"
  end

  def install
    mkdir "build" do
      args = %W[
        --localstatedir=#{var}
        --mandir=#{man}
        --sysconfdir=#{etc}
        -Dqemu_datadir=#{HOMEBREW_PREFIX}/share/qemu
        -Ddriver_esx=enabled
        -Ddriver_qemu=enabled
        -Ddriver_network=enabled
        -Dinit_script=none
      ]
      system "meson", *std_meson_args, *args, ".."
      system "meson", "compile"
      system "meson", "install"
    end
  end

  def post_install
  # Since macOS doesn't support QEMU security features, we need to disable them:
    on_macos do
      qemu_conf = etc/"libvirt/qemu.conf"
      qemu_conf.append_lines "security_driver = \"none\""
      qemu_conf.append_lines "dynamic_ownership = 0"
      qemu_conf.append_lines "remember_owner = 0"
    end
  end

  service do
    run [opt_sbin/"libvirtd", "-f", etc/"libvirt/libvirtd.conf"]
    keep_alive true
    environment_variables PATH: HOMEBREW_PREFIX/"bin"
  end

  test do
    if build.head?
      output = shell_output("#{bin}/virsh -V")
      assert_match "Compiled with support for:", output
    else
      output = shell_output("#{bin}/virsh -v")
      assert_match version.to_s, output
    end
  end
end
