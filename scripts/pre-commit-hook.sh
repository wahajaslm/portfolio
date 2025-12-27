#!/bin/sh

# Check if the pages file is being committed
if git diff --cached --name-only | grep -q "docs/Wahaj_Aslam_CV.pages"; then
    echo "CV .pages file detected in commit. Regenerating PDF..."
    
    # Run the conversion script
    ./scripts/convert_cv.sh
    
    # Check if conversion succeeded
    if [ $? -eq 0 ]; then
        echo "PDF generation successful. Adding to commit..."
        git add public/Wahaj_Aslam_CV.pdf
    else
        echo "Error: PDF generation failed. Aborting commit."
        exit 1
    fi
fi

exit 0
