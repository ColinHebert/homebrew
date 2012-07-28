require 'formula'

class ISO8601ParserUnparser < Formula
  url 'https://github.com/growl/iso-8601-parser-unparser/zipball/0.6'
  head 'git://github.com/growl/iso-8601-parser-unparser.git', :using => :git
  homepage 'https://github.com/growl/iso-8601-parser-unparser'
  sha1 '3f1228d71f3375c038805850ee468688d65d49a4'
  version '0.6'
end

class SGHotKeysLib < Formula
  url 'https://github.com/growl/SGHotKeysLib/zipball/1.2'
  head 'https://github.com/growl/SGHotKeysLib/tags', :using => :git
  homepage 'https://github.com/growl/SGHotKeysLib'
  sha1 '7862af5f579b5098fdc13068e4213be5c9727fde'
  version '1.2'
end

class CocoaSyncSocket < Formula
  # Tag from the parent repository
  url 'https://github.com/robbiehanson/CocoaAsyncSocket/tarball/7.1'
  head 'git://github.com/growl/CocoaAsyncSocket.git  ', :using => :git
  homepage 'http://github.com/growl/CocoaAsyncSocket'
  sha1 '3b3c977fc0d7c1de7816c5cfd39e5d1f2d247aa1'
  version '7.1'
end

class ShortcutRecorder < Formula
  url 'http://shortcutrecorder.googlecode.com/svn/trunk/', :revision => 85
  head 'http://shortcutrecorder.googlecode.com/svn/trunk/', :using => :svn
  homepage 'http://wafflesoftware.net/shortcut/'
  version 'r85'
end

class Growl < Formula
  url  'http://growl.info/hg/growl/archive/234c34a9d09b.tar.bz2'
  head 'https://code.google.com/p/growl/', :using => :hg
  homepage 'http://www.growl.info/'
  sha1 'e32eb36d05e37bea792bbcc8849074003d97e618'
  version '1.4'

  def options
    [
      ["--enable-codesign", "Enable code signature"],
      ["--disable-notify", "Don't include the growlnotify application"],
      ["--disable-hardware", "Don't include the HardwareGrowler application"],
    ]
  end

  def patches
    p = []

    # Disable warnings as errors
    p << "https://raw.github.com/gist/2129745/"

    unless ARGV.include? "--enable-codesign"
      # Disable code sign in Growl.app
      p << "https://raw.github.com/gist/1374159/"

      unless ARGV.include? "--disable-hardware"
        # Disable code sign in HardwareGrowler.app
        p << "https://raw.github.com/gist/1379714/"
      end
    end

    return p
  end

  def install
    # Include dependencies not provided by the tarball.
    unless ARGV.build_head?
      p = (Pathname.getwd+'external_dependencies'+'iso8601parser')
      p.mkpath
      ISO8601ParserUnparser.new('ISO8601ParserUnparser').brew{p.install Dir['*']}

      p = (Pathname.getwd+'external_dependencies'+'SGHotKeysLib')
      p.mkpath
      SGHotKeysLib.new('SGHotKeysLib').brew{p.install Dir['*']}

      p = (Pathname.getwd+'external_dependencies'+'cocoaasyncsocket')
      p.mkpath
      CocoaSyncSocket.new('CocoaSyncSocket').brew{p.install Dir['*']}

      p = (Pathname.getwd+'external_dependencies'+'shortcutrecorder')
      p.mkpath
      ShortcutRecorder.new('ShortcutRecorder').brew{p.install Dir['*']}
    end

    ohai "You need to have the developer certificate already present in Keychain" if ARGV.include? "--enable-codesign"

    buildPath = Pathname.getwd+"build"

    system "xcodebuild -configuration Release SYMROOT=#{buildPath}"
    prefix.install "build/Release/Growl.app"

    unless ARGV.include? "--disable-notify"
      system "xcodebuild -project Extras/growlnotify/growlnotify.xcodeproj -configuration Release SYMROOT=#{buildPath}"
      bin.install "build/Release/growlnotify"
      man.install "Extras/growlnotify/growlnotify.1"
    end

    unless ARGV.include? "--disable-hardware"
      # Build using the previously compiled Growl.framework
      system "xcodebuild -project Extras/HardwareGrowler/HardwareGrowler.xcodeproj -configuration Release SYMROOT=#{buildPath}"
      prefix.install "build/Release/HardwareGrowler.app"
    end
  end

  def caveats
    # Infos on code signing
    s = <<-EOS.undent
          The code needs to be signed to compile, by default the signature is disable with patches.
          It may be useful to re-enable the code sign, which can be done with "--enable-codesign".

          The easiest way to enable code signature is to add manually a self-signed certificate:

          To do so, open "Keychain Access.app";
            "Keychain Access" Menu > "Certificate Assistant" > "Create a Certificate..."

          The certificate name must be :
            3rd Party Mac Developer Application: The Growl Project, LLC
          Choose "Code Signing" as Certificate Type.


    EOS

    # Info on .app
    s += <<-EOS.undent
          Growl.app and HardwareGrowler.app are installed in:
            #{prefix}

           To link the applications to a normal Mac OS X location:
             brew linkapps
           or:
             ln -s #{prefix}/Growl.app /Applications
             ln -s #{prefix}/HardwareGrowler.app /Applications
        EOS

    return s
  end
end
