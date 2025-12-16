
import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROJECT_ROOT = path.resolve(__dirname, '..');
const CONTENT_DIR = path.join(PROJECT_ROOT, 'src/content');
const OUTPUT_FILE = path.join(PROJECT_ROOT, 'public/data/content.json');

function getAllFiles(dirPath, arrayOfFiles) {
  const files = fs.readdirSync(dirPath);

  arrayOfFiles = arrayOfFiles || [];

  files.forEach(function (file) {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles);
    } else {
      if (file.endsWith('.md')) {
        arrayOfFiles.push(path.join(dirPath, "/", file));
      }
    }
  });

  return arrayOfFiles;
}

function exportContent() {
  console.log('Exporting content from', CONTENT_DIR);

  if (!fs.existsSync(CONTENT_DIR)) {
    console.error('Content directory not found:', CONTENT_DIR);
    process.exit(1);
  }

  const files = getAllFiles(CONTENT_DIR);
  const data = files.map(file => {
    const fileContent = fs.readFileSync(file, 'utf8');
    try {
      console.log(`Processing: ${file}`);
      const { data, content } = matter(fileContent);
      // Get relative path from src/content to use as ID
      const relativePath = path.relative(CONTENT_DIR, file);

      const parts = relativePath.split('/');
      const collection = parts[0];
      const filename = parts[parts.length - 1];
      const slugBase = path.dirname(relativePath).split(path.sep).slice(1).join('/'); // remove collection

      // Heuristic for slug: if filename is index.md, use parent dir. Else use filename.
      let slug = filename === 'index.md' ? slugBase : path.join(slugBase, path.basename(filename, '.md'));
      // Remove leading slash if any
      if (slug.startsWith('/')) slug = slug.substring(1);

      // Override slug if in frontmatter
      if (data.article_slug) slug = data.article_slug;

      // Construct URL (naive assumption based on standard Astro routing)
      let url = null;
      if (collection === 'projects') {
        url = `/projects/${slug}/`;
      }

      const wordCount = content.split(/\s+/).length;

      return {
        id: relativePath,
        collection,
        slug,
        url,
        word_count: wordCount,
        data,
        content
      };
    } catch (e) {
      console.error(`Error parsing file: ${file}`);
      console.error(e);
      process.exit(1);
    }
  });

  // Ensure output directory exists
  const outputDir = path.dirname(OUTPUT_FILE);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(data, null, 2));
  console.log(`Exported ${data.length} files to ${OUTPUT_FILE}`);
}

exportContent();
