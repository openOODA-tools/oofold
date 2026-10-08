# oofold: Sovereign LINE WRAPPER

<div align="center">

```
================================================================================
                                oofold
               Sovereign openOODA LINE WRAPPER
================================================================================
```

**Sovereign LINE WRAPPER**  
*Width-aware text line folder breaking on word boundaries and ANSI escape codes.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oofold/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oofold-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oofold/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oofold/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oofold-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oofold/uninstall.sh | bash
```

---

## 2. CLI Usage

```
oofold 0.2.0 (openOODA sovereign search & inspection)
usage: oofold [options] [-w WIDTH] [FILE...]

Width-aware text line folder breaking on word boundaries and ANSI escape codes.

POSIX & Folding Options:
  -w, --width WIDTH     maximum line width (default: 80 columns, or -N shorthand)
  -s, --spaces          break at word spaces rather than hard column boundary
  -b, --bytes           count bytes rather than visual display columns
  -j, --json            output structured folding metrics and folded text as JSON
  -D, --demo            interactive multi-mode line folding showcase
      --test            execute internal subsystem verification suite
      --mcp             run as Model Context Protocol JSON-RPC stdio server
  -v, --version         output version information and exit
  -h, --help            display this help and exit
```

---

## 3. Theming Integration (`oote`)

`oofold` synchronizes visual styles and status colors with [oote](https://github.com/openOODA-tools/oote):
* **Configuration:** Reads active palette from `~/.openooda/theme.oot`.
* **Environment Overrides:** Respects `$OODA_THEME` and `$NO_COLOR`.

---

## 4. Model Context Protocol (MCP)

When invoked with `--mcp`, `oofold` runs a streaming JSON-RPC 2.0 stdio server exposing 5 tools for AI coding agents:
* `fold_wrap_text`: Fold text to a specified column width with space-breaking options.
* `fold_stream_lines`: Stream and fold input text into an array of wrapped lines with metrics.
* `fold_strip_ansi`: Strip ANSI escape sequences from text and compute its true printable width.
* `fold_inspect_line_lengths`: Analyze line lengths and report longest lines and compliance against target width.
* `fold_demo`: Execute an interactive multi-mode folding demonstration showcase.

```bash
oofold --mcp
```

---

## 5. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (&FsReadCap, &TermCap, &McpCap). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 6. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
