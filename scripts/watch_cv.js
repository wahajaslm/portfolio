import fs from 'fs';
import { exec } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const filePath = path.resolve(__dirname, '../docs/Wahaj_Aslam_CV.pages');
const scriptPath = path.resolve(__dirname, 'convert_cv.sh');

console.log(`Watching for changes in: ${filePath}`);

let debounceTimer;

try {
    fs.watch(filePath, { recursive: true }, (eventType, filename) => {
        if (debounceTimer) clearTimeout(debounceTimer);

        debounceTimer = setTimeout(() => {
            console.log(`Change detected. Generating PDF...`);

            exec(scriptPath, (error, stdout, stderr) => {
                if (error) {
                    console.error(`Error executing script: ${error.message}`);
                    return;
                }
                if (stderr) {
                    console.error(`Script stderr: ${stderr}`);
                }
                console.log(stdout);
            });
        }, 3000); // 3-second debounce to allow save to complete
    });
} catch (err) {
    console.error("Error setting up watcher:", err.message);
    console.error("Make sure the file exists at:", filePath);
}
