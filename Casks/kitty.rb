cask "kitty" do
  version "0.25.2"
  sha256 "a1a964ab100ff92cbc5ce50c63699199050572474c2b1f34bec84de673d31a7f"

  url "https://github.com/kovidgoyal/kitty/releases/download/v#{version}/kitty-#{version}.dmg"
  name "kitty"
  desc "GPU-based terminal emulator"
  homepage "https://github.com/kovidgoyal/kitty"

  depends_on macos: ">= :sierra"

  app "kitty.app"
  # shim script (https://github.com/Homebrew/homebrew-cask/issues/18809)
  shimscript = "#{staged_path}/kitty.wrapper.sh"
  binary shimscript, target: "kitty"
  binary "#{appdir}/kitty.app/Contents/Resources/terminfo/78/xterm-kitty",
         target: "#{ENV.fetch("TERMINFO", "#{ENV["HOME"]}/.terminfo")}/78/xterm-kitty"

  preflight do
    File.write shimscript, <<~EOS
      #!/bin/sh
      exec '#{appdir}/kitty.app/Contents/MacOS/kitty' "$@"
    EOS
  end
  postflight do
    system_command 'curl',
                   args: ["-sL", "https://github.com/cmaier/kitty-icon/raw/main/kitty.icns", "-o", "#{appdir}/kitty.app/Contents/Resources/kitty.icns"],
                   sudo: false
    system_command 'touch',
                   args: ["#{appdir}/kitty.app"],
                   sudo: false
    # It seems that replacing the icon breaks some security check for MacOS, and removing attributes
    # using the following command fixes it. Use at your own risk
    system_command 'xattr',
                   args: ["-cr", "#{appdir}/kitty.app"],
                   sudo: false
  end

  zap trash: [
    "~/.config/kitty",
    "~/Library/Caches/kitty",
    "~/Library/Preferences/kitty",
    "~/Library/Preferences/net.kovidgoyal.kitty.plist",
    "~/Library/Saved Application State/net.kovidgoyal.kitty.savedState",
  ]
end
