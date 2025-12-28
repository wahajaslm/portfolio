#!/bin/bash
REPO_ROOT=$(pwd)
INPUT_FILE="$REPO_ROOT/docs/Wahaj_Aslam_CV_old.pages"
OUTPUT_FILE="$REPO_ROOT/cv_old_exported.txt"

osascript <<EOF
tell application "Pages"
    set theDoc to open ("$INPUT_FILE" as POSIX file)
    export theDoc to ("$OUTPUT_FILE" as POSIX file) as unformatted text
    close theDoc
end tell
EOF
