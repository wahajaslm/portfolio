#!/bin/bash

# Define paths (absolute paths are safer for AppleScript)
REPO_ROOT=$(pwd)
INPUT_FILE="$REPO_ROOT/docs/Wahaj_Aslam_CV.pages"
OUTPUT_FILE="$REPO_ROOT/public/Wahaj_Aslam_CV.pdf"

echo "Converting $INPUT_FILE to PDF..."

# Use AppleScript to control Pages
osascript <<EOF
tell application "Pages"
    set theDoc to open ("$INPUT_FILE" as POSIX file)
    export theDoc to ("$OUTPUT_FILE" as POSIX file) as PDF
    close theDoc
end tell
EOF

echo "Done! Updated $OUTPUT_FILE"

# Also copy to docs folder to keep them in sync
DOCS_PDF="$REPO_ROOT/docs/Wahaj_Aslam_CV.pdf"
cp "$OUTPUT_FILE" "$DOCS_PDF"
echo "Synced to $DOCS_PDF"
