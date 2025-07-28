# Verus Installer from Release

A Python script that automatically downloads and installs the latest Verus release from GitHub.

## Features

- 🚀 Downloads the latest stable or pre-release versions of Verus
- 🔍 Automatically detects your platform (Linux, macOS, Windows)
- 📦 Extracts and installs Verus to `~/verus` by default
- 🔧 Sets up executable permissions for all binaries
- 🛣️ Configures PATH automatically in your shell
- ✅ Verifies installation works correctly

## Quick Start

```bash
# Download and install the latest Verus release
python3 verus_installer_from_release.py

# List available releases without installing
python3 verus_installer_from_release.py --list-assets

# Include pre-release versions
python3 verus_installer_from_release.py --pre-release
```

## Options

```
--pre-release          Include pre-release versions
--output-dir, -o       Download directory (default: current directory)
--install-dir, -i      Installation directory (default: ~/verus)
--platform            Platform pattern to search for (e.g., x86-linux)
--list-assets         List all available assets without downloading
--no-extract          Download only, do not extract or install
--no-path             Do not modify PATH configuration
```

## Requirements

- Python 3.6+
- `requests` library (`pip install requests`)

## Supported Platforms

- Linux (x86_64)
- macOS (x86_64, ARM64)
- Windows (x86_64)

## After Installation

The script will:
1. Install Verus to `~/verus`
2. Add Verus to your PATH in `~/.bashrc` (or appropriate shell config)
3. Verify the installation works

To use Verus immediately:
```bash
source ~/.bashrc
verus --version
```

Or run directly:
```bash
~/verus/verus --version
```

## Example Output

```
Found release: release/0.2025.07.24.142e202
Downloading verus-0.2025.07.24.142e202-x86-linux.zip (28.3 MB)...
✓ Download completed
✓ Verus installed to: /home/user/verus
✓ Installation verified successfully!
```
