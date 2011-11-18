require 'formula'

class Zsh < Formula
  url 'http://sourceforge.net/projects/zsh/files/zsh-dev/4.3.17/zsh-4.3.17.tar.gz'
  head 'git://zsh.git.sf.net/gitroot/zsh/zsh', :using => :git
  homepage 'http://www.zsh.org/'
  md5 '9074077945550d6684ebe18b3b167d52'
  version "4.3.17"

  depends_on 'gdbm'
  depends_on 'pcre'
  depends_on 'yodl' if ARGV.build_head?

  skip_clean :all

  def install
    if ARGV.build_head?
      system "./Util/preconfig"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--disable-etcdir",
                          "--enable-fndir=#{share}/zsh/functions",
                          "--enable-site-fndir=#{share}/zsh/site-functions",
                          "--enable-scriptdir=#{share}/zsh/scripts",
                          "--enable-site-scriptdir=#{share}/zsh/site-scripts",
                          "--enable-cap",
                          "--enable-function-subdirs",
                          "--enable-maildir-support",
                          "--enable-multibyte",
                          "--enable-pcre",
                          "--enable-zsh-secure-free",
                          "--with-tcsetpgrp"

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    if ARGV.build_head?
      system "make"
    end

    system "make install"
  end

  def test
    system "#{bin}/zsh --version"
  end

  def caveats; <<-EOS.undent
    To use this build of Zsh as your login shell, add it to /etc/shells.
    EOS
  end
end
