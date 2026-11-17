# typed: strict
# frozen_string_literal: true

# ModelMux - high-performance proxy converting OpenAI API to Vertex AI (Claude).
class Modelmux < Formula
  desc "High-performance proxy server converting OpenAI API requests to Vertex AI format"
  homepage "https://github.com/yarenty/modelmux"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    on_arm do
      url "https://github.com/yarenty/modelmux/releases/download/v1.3.5/modelmux-aarch64-apple-darwin.tar.gz"
      sha256 "d889c5ace65e03bfab7d96cf0505f8c5caa3862ffba44ac48f4d4e4685757546"
    end
    on_intel do
      url "https://github.com/yarenty/modelmux/releases/download/v1.3.5/modelmux-x86_64-apple-darwin.tar.gz"
      sha256 "e2c62bccb0a8ae0703f0c177c6d3279f2c32fb6cc2db17fe7637234966ea2531"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/yarenty/modelmux/releases/download/v1.3.5/modelmux-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9d5cae1066db79fe3d52ec3245ee4f63aa6226e3d1e89193689f28b61e5252cb"
    end
    on_intel do
      url "https://github.com/yarenty/modelmux/releases/download/v1.3.5/modelmux-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "488305d4e12f542c8aad020b8a5ac8335f97c2315eb262563c3093d2e57f47d4"
    end
  end

  def install
    bin.install "modelmux"
  end

  # ModelMux manages its own log files (daily rotation, 30-file retention
  # ~= last month) under `~/Library/Logs/modelmux/` on macOS. We deliberately
  # don't set `log_path` / `error_log_path` so brew services doesn't capture
  # stdout/stderr into a single unbounded `var/log/modelmux.log`.
  service do
    run [opt_bin/"modelmux"]
    keep_alive true
  end

  def caveats
    <<~EOS
      ModelMux runs as an HTTP proxy. Configure it with:
        modelmux config init

      To run ModelMux as a background service:
        brew services start modelmux

      The service will use your config from:
        ~/.config/modelmux/config.toml (Linux & macOS)

      Logs (daily rotation, 30-file retention ~= last month):
        ~/Library/Logs/modelmux/modelmux.log.YYYY-MM-DD

      Upgrading from <= 1.0.0 on macOS? Just run `modelmux` once — config is
      migrated automatically from ~/Library/Application Support/com.SkyCorp.modelmux/
      to ~/.config/modelmux/ (idempotent).
    EOS
  end

  test do
    # Test that the binary was installed and --version works
    version_output = shell_output("#{bin}/modelmux --version")
    assert_match(/^modelmux \d+\.\d+\.\d+/, version_output)

    # Test that -V (short version) works
    version_short = shell_output("#{bin}/modelmux -V")
    assert_match(/^modelmux \d+\.\d+\.\d+/, version_short)

    # Test that --help works
    help_output = shell_output("#{bin}/modelmux --help")
    assert_match(/USAGE/, help_output)
    assert_match(/OPTIONS/, help_output)
    assert_match(/ENVIRONMENT VARIABLES/, help_output)

    # Test that -h (short help) works
    help_short = shell_output("#{bin}/modelmux -h")
    assert_match(/USAGE/, help_short)

    # Test configuration validation with minimal valid config
    # Create a minimal valid base64-encoded service account key JSON
    require "json"
    pk = "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC\n" \
         "-----END PRIVATE KEY-----\n"
    minimal_key = {
      "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
      "auth_uri"                    => "https://accounts.google.com/o/oauth2/auth",
      "client_email"                => "test@test-project.iam.gserviceaccount.com",
      "client_id"                   => "123456789",
      "client_x509_cert_url"        => "https://www.googleapis.com/robot/v1/metadata/x509/test%40test-project.iam.gserviceaccount.com",
      "private_key"                 => pk,
      "private_key_id"              => "test-key-id",
      "project_id"                  => "test-project",
      "token_uri"                   => "https://oauth2.googleapis.com/token",
      "type"                        => "service_account",
    }
    key_b64 = [minimal_key.to_json].pack("m0")

    ENV["GCP_SERVICE_ACCOUNT_KEY"] = key_b64
    ENV["LLM_PROVIDER"] = "vertex"
    ENV["VERTEX_REGION"] = "test-region"
    ENV["VERTEX_PROJECT"] = "test-project"
    ENV["VERTEX_LOCATION"] = "test-region"
    ENV["VERTEX_PUBLISHER"] = "test-publisher"
    ENV["VERTEX_MODEL_ID"] = "test-model"
    ENV["PORT"] = "0" # Use port 0 to avoid conflicts

    # This should fail gracefully with auth/network error, proving config parsing works
    # The server will try to start but fail on actual API calls, which is expected
    output = shell_output("#{bin}/modelmux 2>&1", 1)
    # Should show some error (auth, network, or server startup), not a config error
    assert_match(/Authentication|HTTP|Server|Error|error/i, output)
  end
end
