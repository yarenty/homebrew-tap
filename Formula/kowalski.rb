# typed: strict
# frozen_string_literal: true

# Kowalski - jobs for a local model. Installs the pre-built macOS release binaries.
# The Linux release binaries use the system OpenSSL, which Homebrew does not accept.
class Kowalski < Formula
  desc "Runs chores on your own machine with a local model, as pipelines of small steps"
  homepage "https://kowalski.yarenty.com"
  license "MIT"

  depends_on :macos

  on_macos do
    on_arm do
      url "https://github.com/yarenty/kowalski/releases/download/v2.6.1/kowalski-aarch64-apple-darwin.tar.gz"
      sha256 "a251dfd9784eb62b8468af231f68bc034c46f2f135b3e950b15621fefac37d03"
    end
    on_intel do
      url "https://github.com/yarenty/kowalski/releases/download/v2.6.1/kowalski-x86_64-apple-darwin.tar.gz"
      sha256 "ada6c5a008dcb7d633bc91baed72c0e8763a5cbd15abf81fe6e2af9da9eddf6b"
    end
  end

  # Never installed (see `depends_on :macos`); Homebrew wants a URL for every platform.
  on_linux do
    on_arm do
      url "https://github.com/yarenty/kowalski/releases/download/v2.6.1/kowalski-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "be5a348b3713cb396ac21124c7aea0b51b8820b871555c96b1e38d33753c4455"
    end
    on_intel do
      url "https://github.com/yarenty/kowalski/releases/download/v2.6.1/kowalski-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e87f6a697b6ed10105476dd19488ab286f783b0ab1470d3c079a6a0266a9a2eb"
    end
  end

  def install
    bin.install "kowalski", "kowalski-cli"
    pkgshare.install "config.example.toml"
  end

  def caveats
    <<~EOS
      Start it with:
        kowalski
      It opens the app in your browser; Setup asks for a model (Ollama, or an
      OpenAI-compatible endpoint) and a files folder, and writes
        ~/.config/kowalski/config.toml
    EOS
  end

  test do
    assert_match "kowalski #{version}", shell_output("#{bin}/kowalski --version")
    assert_match "kowalski-cli #{version}", shell_output("#{bin}/kowalski-cli --version")
  end
end
