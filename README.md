# Verus & SCIP Downloader Toolkit (DEPRECATED)
> **Deprecated:** This repository has been merged with [probe-verus/tools](https://github.com/Beneficial-AI-Foundation/probe-verus/tree/main/tools) and is no longer maintained.

A collection of scripts for downloading and installing development tools from GitHub releases. Available in both Python (`.py`) and shell script (`.sh`) versions.

## 📦 Scripts Included

| Tool | Python | Shell |
|------|--------|-------|
| Verus installer | `verus_installer_from_release.py` | `verus_installer_from_release.sh` |
| Rust Analyzer installer | `rust_analyzer_installer.py` | `rust_analyzer_installer.sh` |
| Verus Analyzer installer | `verus_analyzer_installer.py` | `verus_analyzer_installer.sh` |
| SCIP installer | `scip_installer.py` | `scip_installer.sh` |
| SCIP Index Generator | `generate_scip_index.py` | `generate_scip_index.sh` |

Shell scripts require `curl` and `jq`. Both versions support the same command-line options.

## ✨ Features

- 🚀 Downloads latest stable or pre-release versions
- 🔍 Automatically detects your platform (Linux, macOS, Windows)
- 📦 Extracts and installs to user directories by default
- 🔧 Sets up executable permissions automatically
- 🛣️ Configures PATH in your shell configuration
- ✅ Verifies installations work correctly
- 🔄 Generates SCIP indices for code analysis

## 🚀 Quick Start


### Install Verus 
```bash
# Download and install the latest Verus release
python3 verus_installer_from_release.py

# Install a specific version
python3 verus_installer_from_release.py --version "0.2025.08.25.63ab0cb"

# List available releases without installing
python3 verus_installer_from_release.py --list-assets

# Include pre-release versions
python3 verus_installer_from_release.py --pre-release
```


### Install Verus Analyzer
```bash
# Install latest stable Verus Analyzer
python3 verus_analyzer_installer.py

# Install latest pre-release
python3 verus_analyzer_installer.py --pre-release

# List available releases
python3 verus_analyzer_installer.py --list-assets
```

### Install Rust Analyzer
```bash
# Install latest stable Rust Analyzer
python3 rust_analyzer_installer.py

# Install latest pre-release
python3 rust_analyzer_installer.py --pre-release

# Download VS Code extension instead of binary
python3 rust_analyzer_installer.py --vsix
```

### Install SCIP
```bash
# Install latest stable SCIP
python3 scip_installer.py

# Install with custom directory
python3 scip_installer.py --install-dir /opt/scip

# Check available releases
python3 scip_installer.py --list-assets
```

### Generate SCIP Index
```bash
# Analyze a project with Verus Analyzer (default)
python3 generate_scip_index.py /path/to/project

# Use Rust Analyzer instead
python3 generate_scip_index.py /path/to/project --analyzer rust-analyzer

# Keep project copy and specify output
python3 generate_scip_index.py /path/to/project --keep-copy --output-dir ./analysis
```

## 🔧 Command Line Options

### Verus Installer
```
--version, -v             Download a specific version (e.g., "0.2025.08.25.63ab0cb")
--pre-release             Include pre-release versions
--output-dir, -o          Download directory (default: current directory)
--install-dir, -i         Installation directory (default: ~/verus)
--platform               Platform pattern to search for (e.g., x86-linux)
--list-assets            List all available assets without downloading
--no-extract             Download only, do not extract or install
--no-path                Do not modify PATH configuration
```

### Verus Analyzer Installer
```
--pre-release, --prerelease    Download pre-release version instead of stable
--output-dir, -o              Download directory (default: current directory)
--install-dir, -i             Installation directory (default: ~/verus-analyzer)
--platform                    Platform pattern (e.g., x86_64-unknown-linux-gnu)
--list-assets                 List all available assets without downloading
--no-extract                  Download only, do not extract or install
--no-path                     Do not modify PATH configuration
--vsix                        Download VS Code extension instead of binary
```

### Rust Analyzer Installer
```
--pre-release, --prerelease    Download pre-release version instead of stable
--output-dir, -o              Download directory (default: current directory)
--install-dir, -i             Installation directory (default: ~/rust-analyzer)
--platform                    Platform pattern (e.g., x86_64-unknown-linux-gnu)
--list-assets                 List all available assets without downloading
--no-extract                  Download only, do not extract or install
--no-path                     Do not modify PATH configuration
--vsix                        Download VS Code extension instead of binary
```

### SCIP Installer
```
--pre-release, --prerelease    Download pre-release version instead of stable
--output-dir, -o              Download directory (default: current directory)
--install-dir, -i             Installation directory (default: ~/scip)
--platform                    Platform pattern (e.g., scip-linux-amd64)
--list-assets                 List all available assets without downloading
--no-extract                  Download only, do not extract or install
--no-path                     Do not modify PATH configuration
```

### SCIP Index Generator
```
project                       Path to the project to analyze (required)
--analyzer, -a                Analyzer to use: verus-analyzer (default) or rust-analyzer
--output-dir, -o              Directory to copy project to (default: temp directory)
--json-output, -j             Output file for JSON export (default: index_scip.json)
--keep-copy                   Keep the copied project after analysis
--check-tools                 Check if required tools are available and exit
```

## 📋 Requirements

- Python 3.6+
- `requests` library

### Installing uv (Recommended)

[uv](https://github.com/astral-sh/uv) is a fast Python package manager that automatically manages dependencies in isolated local environments, keeping your global Python installation clean.

**Install uv:**

```bash
# On Linux/macOS
curl -LsSf https://astral.sh/uv/install.sh | sh

# On Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

**Run scripts with uv:**

```bash
# uv automatically installs dependencies (like requests) 
# in a temporary cached environment without polluting
# your local or global Python environment
uv run verus_installer_from_release.py
uv run rust_analyzer_installer.py
```

**Alternative (traditional pip):**

If you prefer not to use uv, install dependencies globally:
```bash
pip install requests
```

## 🖥️ Supported Platforms

### Verus Analyzer
- Linux (x86_64, aarch64, armv7)
- macOS (x86_64, ARM64)
- Windows (x86_64, aarch64, i686)

### Rust Analyzer
- Linux (x86_64, aarch64, armv7)
- macOS (x86_64, ARM64)
- Windows (x86_64, aarch64, i686)

### SCIP
- Linux (amd64, arm64, arm)
- macOS (amd64, arm64)
- Windows (amd64, arm64)

## 📁 After Installation

### Verus Analyzer
The installer will:
1. Install Verus Analyzer to `~/verus-analyzer`
2. Add it to your PATH in `~/.bashrc` (or appropriate shell config)
3. Verify the installation works

To use immediately:
```bash
source ~/.bashrc
verus-analyzer --version
```

### Rust Analyzer
The installer will:
1. Install Rust Analyzer to `~/rust-analyzer`
2. Add it to your PATH in `~/.bashrc` (or appropriate shell config)
3. Verify the installation works

To use immediately:
```bash
source ~/.bashrc
rust-analyzer --version
```

### SCIP
The installer will:
1. Install SCIP to `~/scip`
2. Add it to your PATH in shell configuration
3. Verify the installation works

To use immediately:
```bash
source ~/.bashrc
scip --version
```

### SCIP Index Generation
The generator will:
1. Copy your project to a working directory
2. Run analyzer SCIP analysis (`verus-analyzer scip .` or `rust-analyzer scip .`)
3. Export SCIP index to JSON (`scip print --json index.scip > index_scip.json`)
4. Clean up temporary files (unless `--keep-copy` is used)

## 📊 Example Output

### Verus Analyzer Installation
```
Fetching latest stable Verus Analyzer release...
Found release: 0.2025.08.05
Published: 2025-08-05T15:30:00Z
Pre-release: False
Downloading verus-analyzer-x86_64-unknown-linux-gnu.gz (15.2 MB)...
✓ Download completed
✓ Verus Analyzer installed to: /home/user/verus-analyzer
✓ Installation verified successfully!

📝 Next steps:
   1. Restart your terminal or run: source /home/user/.bashrc
   2. Type 'verus-analyzer --version' to verify
```

### Rust Analyzer Installation
```
Fetching latest stable Rust Analyzer release...
Found release: 2025-08-05
Published: 2025-08-05T10:00:00Z
Pre-release: False
Downloading rust-analyzer-x86_64-unknown-linux-gnu.gz (12.5 MB)...
✓ Download completed
✓ Rust Analyzer installed to: /home/user/rust-analyzer
✓ Installation verified successfully!

📝 Next steps:
   1. Restart your terminal or run: source /home/user/.bashrc
   2. Type 'rust-analyzer --version' to verify
```

### SCIP Installation
```
Fetching latest stable SCIP release...
Found release: v0.5.2
Published: 2025-08-01T10:15:00Z
Pre-release: False
Downloading scip-linux-amd64.tar.gz (8.1 MB)...
✓ Download completed
✓ SCIP installed to: /home/user/scip
✓ Installation verified successfully!

📝 Next steps:
   1. Restart your terminal or run: source /home/user/.bashrc
   2. Type 'scip --version' to verify
```

### SCIP Index Generation
```
============================================================
SCIP INDEX GENERATION
============================================================

1. Copying project...
Copying project from /home/user/my-project to /tmp/scip_analysis_xyz/my-project

2. Running verus-analyzer SCIP analysis...
Executing: verus-analyzer scip .
✓ verus-analyzer SCIP analysis completed successfully
✓ SCIP index file created: /tmp/scip_analysis_xyz/my-project/index.scip

3. Exporting SCIP index to JSON...
Executing: scip print --json index.scip
✓ SCIP JSON export completed successfully
✓ Output file: /tmp/scip_analysis_xyz/my-project/index_scip.json
  File size: 2.5 MB

============================================================
ANALYSIS COMPLETE
============================================================
✓ Project: /home/user/my-project
✓ Analyzer: verus-analyzer
✓ SCIP file: /tmp/scip_analysis_xyz/my-project/index.scip
✓ JSON output: /tmp/scip_analysis_xyz/my-project/index_scip.json

📄 SCIP index JSON available at: /tmp/scip_analysis_xyz/my-project/index_scip.json
```

## 🔗 Workflow Integration

You can chain these tools together for a complete analysis workflow:

```bash
# 1. Install tools
python3 verus_analyzer_installer.py
python3 rust_analyzer_installer.py
python3 scip_installer.py

# 2. Generate SCIP index for your project
python3 generate_scip_index.py /path/to/your/verus/project

# 3. The JSON output can be used for further analysis
cat index_scip.json | jq '.documents | length'  # Count indexed documents
```

## 🛠️ Development

Each script is self-contained and includes:
- Comprehensive error handling
- Progress bars for downloads
- Platform detection
- Path configuration
- Installation verification
- Cleanup options
