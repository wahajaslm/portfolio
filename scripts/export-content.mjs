import fs from "fs";
import path from "path";
import matter from "gray-matter";

const CONTENT_ROOT = "src/content";
const OUTPUT_FILE = "public/data/content.json";

function walk(dir) {
  let results = [];
  for (const file of fs.readdirSync(dir)) {
    const full = path.join(dir, file);
    if (fs.statSync(full).isDirectory()) {
      results = results.concat(walk(full));
    } else if (file.endsWith(".md")) {
      results.push(full);
    }
  }
  return results;
}

const files = walk(CONTENT_ROOT);
const documents = [];

for (const file of files) {
  const raw = fs.readFileSync(file, "utf8");
  const { data, content } = matter(raw);

  const relPath = file
    .replace(CONTENT_ROOT + "/", "")
    .replace("/index.md", "")
    .replace(".md", "");

  const type = relPath.split("/")[0];

  documents.push({
    id: relPath,
    type,
    title: data.title || relPath.split("/").pop(),
    tags: data.tags || [],
    visibility: data.visibility || "public",
    text: content.replace(/\s+/g, " ").trim()
  });
}

fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
fs.writeFileSync(OUTPUT_FILE, JSON.stringify(documents, null, 2));

console.log(`✔ Exported ${documents.length} documents`);
