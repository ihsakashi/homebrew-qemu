class Libvirt < Formula
    desc "C virtualization API"
    homepage "https://www.libvirt.org"
    url "https://libvirt.org/sources/libvirt-7.3.0.tar.xz"
    sha256 "27bdbb85c0301475ab1f2ecd185c629ea0bfd5512bef3f6f1817b6c55d1dc1be"
    license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  
    livecheck do
      url "https://libvirt.org/sources/"
      regex(/href=.*?libvirt[._-]v?(\d+(?:\.\d+)+)\.t/i)
    end
  
    head do
      url "https://github.com/libvirt/libvirt.git"
    end

		# apple silicon detection
    patch :p1 do
			url "https://github.com/ihsakashi/libvirt/commit/0f062221ae23e6ea0ed5e6ba65d47395581cb143.patch"
			sha256 "1fa95c485e6cd27bd9b6ac1af9f3d1cdd1f7d7e1baa472e35b5fd3c5f940cf13"
    done

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
          -Ddriver_esx=enabled
          -Ddriver_qemu=enabled
          -Dinit_script=none
        ]
        system "meson", *std_meson_args, *args, ".."
        system "meson", "compile"
        system "meson", "install"
      end
    end
  
    plist_options manual: "libvirtd"
  
    def plist
      <<~EOS
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>EnvironmentVariables</key>
            <dict>
              <key>PATH</key>
              <string>#{HOMEBREW_PREFIX}/bin</string>
            </dict>
            <key>Label</key>
            <string>#{plist_name}</string>
            <key>ProgramArguments</key>
            <array>
              <string>#{sbin}/libvirtd</string>
              <string>-f</string>
              <string>#{etc}/libvirt/libvirtd.conf</string>
            </array>
            <key>KeepAlive</key>
            <true/>
            <key>RunAtLoad</key>
            <true/>
          </dict>
        </plist>
      EOS
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