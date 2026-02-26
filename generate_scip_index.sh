#!/bin/bash
#
# SCIP Index Generator
#
# Copies a project, runs an analyzer (verus-analyzer or rust-analyzer) to generate SCIP data,
# and exports the SCIP index to JSON format.
#

set -e

# Default values
ANALYZER="verus-analyzer"
OUTPUT_DIR=""
JSON_OUTPUT=""
KEEP_COPY=false
CHECK_TOOLS=false
PROJECT=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] PROJECT

Copy a project and generate SCIP index in JSON format.

Arguments:
  PROJECT                    Path to the project to analyze

Options:
  -a, --analyzer ANALYZER    Analyzer to use: verus-analyzer (default) or rust-analyzer
  -o, --output-dir DIR       Directory to copy project to (default: temporary directory)
  -j, --json-output FILE     Output file for JSON export (default: index_scip.json in project)
  -k, --keep-copy            Keep the copied project after analysis
  -c, --check-tools          Check if required tools are available and exit
  -h, --help                 Show this help message

Examples:
  $(basename "$0") /path/to/project
  $(basename "$0") /path/to/project --analyzer rust-analyzer
  $(basename "$0") /path/to/project --output-dir /tmp/analysis
  $(basename "$0") /path/to/project --keep-copy --output-dir ./analysis
EOF
}

check_analyzer() {
    local analyzer_name="$1"
    if command -v "$analyzer_name" &> /dev/null; then
        local version
        version=$("$analyzer_name" --version 2>&1 || true)
        echo -e "${GREEN}✓${NC} $analyzer_name is available"
        echo "  Version: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $analyzer_name not found in PATH"
        return 1
    fi
}

check_scip() {
    if command -v scip &> /dev/null; then
        local version
        version=$(scip --version 2>&1 || scip --help 2>&1 | head -1 || echo "unknown")
        echo -e "${GREEN}✓${NC} SCIP is available"
        echo "  Version: $version"
        return 0
    else
        echo -e "${RED}✗${NC} SCIP not found in PATH"
        echo "  Install SCIP using: ./scip_installer.py"
        return 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--analyzer)
            ANALYZER="$2"
            if [[ "$ANALYZER" != "verus-analyzer" && "$ANALYZER" != "rust-analyzer" ]]; then
                echo "Error: Analyzer must be 'verus-analyzer' or 'rust-analyzer'"
                exit 1
            fi
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -j|--json-output)
            JSON_OUTPUT="$2"
            shift 2
            ;;
        -k|--keep-copy)
            KEEP_COPY=true
            shift
            ;;
        -c|--check-tools)
            CHECK_TOOLS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [[ -z "$PROJECT" ]]; then
                PROJECT="$1"
            else
                echo "Error: Multiple projects specified"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check required tools
echo "Checking required tools..."
ANALYZER_OK=true
SCIP_OK=true

check_analyzer "$ANALYZER" || ANALYZER_OK=false
check_scip || SCIP_OK=false

if $CHECK_TOOLS; then
    if $ANALYZER_OK && $SCIP_OK; then
        echo -e "\n${GREEN}✓${NC} All required tools are available"
        exit 0
    else
        echo -e "\n${RED}✗${NC} Some required tools are missing"
        exit 1
    fi
fi

# Validate project argument
if [[ -z "$PROJECT" ]]; then
    echo "Error: PROJECT argument is required"
    usage
    exit 1
fi

# Resolve project path
PROJECT=$(realpath "$PROJECT")

if [[ ! -e "$PROJECT" ]]; then
    echo "Error: Source project not found: $PROJECT"
    exit 1
fi

if [[ ! -d "$PROJECT" ]]; then
    echo "Error: Source is not a directory: $PROJECT"
    exit 1
fi

# Check tools are available
if ! $ANALYZER_OK; then
    echo -e "\nError: $ANALYZER is not available"
    echo "Install it using: ./verus_analyzer_installer.py"
    exit 1
fi

if ! $SCIP_OK; then
    echo -e "\nError: SCIP is not available"
    echo "Install it using: ./scip_installer.py"
    exit 1
fi

echo ""
echo "============================================================"
echo "SCIP INDEX GENERATION"
echo "============================================================"

# Step 1: Copy project
echo ""
echo "1. Copying project..."

PROJECT_NAME=$(basename "$PROJECT")
TEMP_DIR=""

if [[ -n "$OUTPUT_DIR" ]]; then
    DEST_PATH=$(realpath "$OUTPUT_DIR" 2>/dev/null || echo "$OUTPUT_DIR")
    if [[ -e "$DEST_PATH" ]]; then
        echo "Removing existing destination: $DEST_PATH"
        rm -rf "$DEST_PATH"
    fi
    mkdir -p "$(dirname "$DEST_PATH")"
    PROJECT_COPY="$DEST_PATH"
else
    TEMP_DIR=$(mktemp -d -t scip_analysis_XXXXXX)
    PROJECT_COPY="$TEMP_DIR/$PROJECT_NAME"
fi

echo "Copying project from $PROJECT to $PROJECT_COPY"
cp -r "$PROJECT" "$PROJECT_COPY"

# Step 2: Run analyzer SCIP
echo ""
echo "2. Running $ANALYZER SCIP analysis..."
echo "Executing: $ANALYZER scip ."

pushd "$PROJECT_COPY" > /dev/null

if $ANALYZER scip . 2>&1; then
    echo -e "${GREEN}✓${NC} $ANALYZER SCIP analysis completed successfully"
else
    echo -e "${RED}✗${NC} $ANALYZER SCIP analysis failed"
    popd > /dev/null
    exit 1
fi

# Check if index.scip was created
SCIP_FILE="$PROJECT_COPY/index.scip"
if [[ -f "$SCIP_FILE" ]]; then
    echo -e "${GREEN}✓${NC} SCIP index file created: $SCIP_FILE"
else
    echo -e "${YELLOW}⚠${NC} SCIP index file not found at expected location: $SCIP_FILE"
    # Look for SCIP files
    FOUND_SCIP=$(find "$PROJECT_COPY" -name "*.scip" -type f | head -1)
    if [[ -n "$FOUND_SCIP" ]]; then
        echo "Found SCIP file: $FOUND_SCIP"
        SCIP_FILE="$FOUND_SCIP"
    else
        echo -e "${RED}✗${NC} No SCIP file found"
        popd > /dev/null
        exit 1
    fi
fi

# Step 3: Export to JSON
echo ""
echo "3. Exporting SCIP index to JSON..."

# Change to the directory containing the SCIP file (matches Python behavior)
SCIP_DIR=$(dirname "$SCIP_FILE")
SCIP_FILENAME=$(basename "$SCIP_FILE")

if [[ -n "$JSON_OUTPUT" ]]; then
    JSON_FILE=$(realpath "$JSON_OUTPUT" 2>/dev/null || echo "$JSON_OUTPUT")
else
    # Put JSON in same directory as SCIP file (matches Python behavior)
    JSON_FILE="$SCIP_DIR/index_scip.json"
fi

popd > /dev/null
pushd "$SCIP_DIR" > /dev/null

echo "Executing: scip print --json $SCIP_FILENAME"

# Redirect stdout to JSON file, capture stderr separately (don't corrupt JSON)
SCIP_STDERR_FILE=$(mktemp)
if scip print --json "$SCIP_FILENAME" > "$JSON_FILE" 2>"$SCIP_STDERR_FILE"; then
    SCIP_SUCCESS=true
else
    SCIP_SUCCESS=false
fi
SCIP_STDERR=$(cat "$SCIP_STDERR_FILE" 2>/dev/null)
rm -f "$SCIP_STDERR_FILE"

if $SCIP_SUCCESS; then
    echo -e "${GREEN}✓${NC} SCIP JSON export completed successfully"
    echo -e "${GREEN}✓${NC} Output file: $JSON_FILE"

    # Check file size
    FILE_SIZE=$(stat -f%z "$JSON_FILE" 2>/dev/null || stat -c%s "$JSON_FILE" 2>/dev/null || echo "0")
    if [[ "$FILE_SIZE" -gt 0 ]]; then
        SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc 2>/dev/null || echo "unknown")
        echo "  File size: ${SIZE_MB} MB"
    else
        echo -e "${YELLOW}⚠${NC} Output file is empty"
        rm -f "$JSON_FILE"
        popd > /dev/null
        exit 1
    fi
else
    echo -e "${RED}✗${NC} SCIP JSON export failed"
    if [[ -n "$SCIP_STDERR" ]]; then
        echo "Error: $SCIP_STDERR"
    fi
    # Clean up empty file
    if [[ -f "$JSON_FILE" ]]; then
        FILE_SIZE=$(stat -f%z "$JSON_FILE" 2>/dev/null || stat -c%s "$JSON_FILE" 2>/dev/null || echo "0")
        if [[ "$FILE_SIZE" -eq 0 ]]; then
            rm -f "$JSON_FILE"
        fi
    fi
    popd > /dev/null
    exit 1
fi

popd > /dev/null

# Summary
echo ""
echo "============================================================"
echo "ANALYSIS COMPLETE"
echo "============================================================"
echo -e "${GREEN}✓${NC} Project: $PROJECT"
echo -e "${GREEN}✓${NC} Analyzer: $ANALYZER"
echo -e "${GREEN}✓${NC} Project copy: $PROJECT_COPY"
echo -e "${GREEN}✓${NC} SCIP file: $SCIP_FILE"
echo -e "${GREEN}✓${NC} JSON output: $JSON_FILE"

# Cleanup
if ! $KEEP_COPY && [[ -n "$TEMP_DIR" ]]; then
    echo ""
    echo "Cleaning up temporary project copy..."
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✓${NC} Temporary files cleaned up"
elif ! $KEEP_COPY && [[ -n "$OUTPUT_DIR" ]]; then
    echo ""
    echo "Note: Project copy kept at $PROJECT_COPY (use --keep-copy to suppress this message)"
fi

echo ""
echo "📄 SCIP index JSON available at: $JSON_FILE"
