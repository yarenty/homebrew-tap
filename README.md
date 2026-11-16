# Yarenty Tap

Homebrew formulae by [yarenty](https://github.com/yarenty).

## Formulae

### kowalski

**Kowalski** gives a local model jobs: pipelines of small steps (hordes) that run on your own machine. Installs the pre-built `kowalski` and `kowalski-cli` for macOS and Linux, Intel or ARM.

- **Project**: [github.com/yarenty/kowalski](https://github.com/yarenty/kowalski)
- **Site**: [kowalski.yarenty.com](https://kowalski.yarenty.com)
- **License**: MIT

**Install:**

```bash
brew install yarenty/tap/kowalski
kowalski
```

### modelmux

**ModelMux** is a high-performance Rust proxy server that converts OpenAI-compatible API requests to Vertex AI (Anthropic Claude) format. Drop-in replacement for the OpenAI API with streaming, tool/function calling, and production-grade reliability.

- **Project**: [github.com/yarenty/modelmux](https://github.com/yarenty/modelmux)
- **Crate**: [crates.io/crates/modelmux](https://crates.io/crates/modelmux)
- **Docs**: [docs.rs/modelmux](https://docs.rs/modelmux)
- **License**: MIT OR Apache-2.0

**Install:**

```bash
brew install yarenty/tap/modelmux
```

Or tap first, then install:

```bash
brew tap yarenty/tap
brew install modelmux
```

**Brewfile:**

```
tap "yarenty/tap"
brew "modelmux"
```

---

## Documentation

`brew help`, `man brew` or [Homebrew's documentation](https://docs.brew.sh).


