import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROJECT_ROOT = path.resolve(__dirname, '..');
const CONTENT_DIR = path.join(PROJECT_ROOT, 'src/content');
const OUTPUT_FILE = path.join(PROJECT_ROOT, 'public/data/content.json');

/* ---------------------------------- */
/* File utilities                      */
/* ---------------------------------- */

function getAllFiles(dir, acc = []) {
  for (const file of fs.readdirSync(dir)) {
    const full = path.join(dir, file);
    if (fs.statSync(full).isDirectory()) {
      getAllFiles(full, acc);
    } else if (file.endsWith('.md')) {
      acc.push(full);
    }
  }
  return acc;
}

/* ---------------------------------- */
/* Text cleanup                        */
/* ---------------------------------- */

function cleanText(text) {
  return text
    .replace(/^---+$/gm, '')
    .replace(/`+/g, '')
    .replace(/\*\*/g, '')
    .replace(/__+/g, '')
    .replace(/^#+\s+/gm, '')
    .replace(/^[-*]\s+/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

/* ---------------------------------- */
/* Section splitter                    */
/* ---------------------------------- */

function splitSections(markdown) {
  const sections = {};
  let current = 'root';
  sections[current] = [];

  markdown.split('\n').forEach(line => {
    const header = line.match(/^(#{2,3})\s+(.*)$/);
    if (header) {
      current = header[2].toLowerCase();
      sections[current] = [];
    } else {
      sections[current].push(line);
    }
  });

  return sections;
}

/* ---------------------------------- */
/* Controlled vocabularies             */
/* ---------------------------------- */

const LANGUAGES = ['C', 'C++', 'Python', 'MATLAB', 'Bash', 'Swift'];
const TOOLS = [
  'FFmpeg', 'MediaInfo', 'Adobe Audition',
  'Core Audio', 'vDSP', 'GitLab CI', 'Git'
];
const AUDIO_KEYWORDS = [
  'audio', 'dsp', 'codec', 'speech',
  'pitch', 'spectral', 'lpc', 'streaming'
];
const REALTIME_KEYWORDS = [
  'latency', 'real-time', 'timing', 'jitter',
  'deadline', 'frame', 'buffer', 'ms', 'us'
];

/* ---------------------------------- */
/* Chunk extraction                    */
/* ---------------------------------- */

function extractChunks(content, collection, slug) {
  const chunks = [];
  const seen = new Set();
  const sections = splitSections(content);

  const add = (kind, text) => {
    const cleaned = cleanText(text);
    if (!cleaned || seen.has(cleaned)) return;
    seen.add(cleaned);
    chunks.push({ kind, text: cleaned });
  };

  /* ---- SECTION-BASED (SAFE) ---- */

  if (collection === 'profile') {
    if (sections['1. who i am']) {
      add('profile.summary', sections['1. who i am'].join('\n'));
    }
  }

  if (collection === 'experience') {
    if (sections['role summary']) {
      sections['role summary'].forEach(line =>
        add('experience.summary', line)
      );
    }
    if (sections['critical listening & perceptual analysis']) {
      add(
        'experience.evaluation_listening',
        sections['critical listening & perceptual analysis'].join('\n')
      );
    }
  }

  if (collection === 'projects') {
    if (sections['overview']) {
      add('projects.overview', sections['overview'].join('\n'));
    }
    if (sections['problem statement']) {
      add('projects.challenge', sections['problem statement'].join('\n'));
    }
  }

  /* ---- SENTENCE-LEVEL FACT MINING ---- */

  const normalized = content
    .replace(/(\n|^)\s*[-*]\s+/g, '. ')
    .replace(/\n+/g, ' ');

  normalized.split(/[.?!]\s+/).forEach(sentence => {
    const lower = sentence.toLowerCase();

    if (AUDIO_KEYWORDS.some(k => lower.includes(k))) {
      add('experience.audio_dsp', sentence);
    }

    // Use word boundary for real-time keywords to avoid false positives (e.g. "systems" matching "ms")
    if (REALTIME_KEYWORDS.some(k => new RegExp(`\\b${k}\\b`).test(lower))) {
      add('experience.real_time', sentence);
    }
  });

  /* ---- ATOMIC SKILLS ---- */

  LANGUAGES.forEach(lang => {
    if (content.includes(lang)) {
      add('skills.languages', lang);
    }
  });

  TOOLS.forEach(tool => {
    if (content.includes(tool)) {
      add('skills.tools', tool);
    }
  });

  return chunks;
}

/* ---------------------------------- */
/* Fact aggregation (CRITICAL)         */
/* ---------------------------------- */

function extractFacts(chunks) {
  const facts = {
    languages: [],
    tools: [],
    audio_dsp: [],
    real_time: []
  };

  const push = (arr, v) => {
    if (!arr.includes(v)) arr.push(v);
  };

  chunks.forEach(c => {
    if (c.kind === 'skills.languages') push(facts.languages, c.text);
    if (c.kind === 'skills.tools') push(facts.tools, c.text);
    if (c.kind === 'experience.audio_dsp') push(facts.audio_dsp, c.text);
    if (c.kind === 'experience.real_time') push(facts.real_time, c.text);
  });

  return facts;
}

/* ---------------------------------- */
/* Export                              */
/* ---------------------------------- */

function exportContent() {
  console.log('Exporting from:', CONTENT_DIR);

  const files = getAllFiles(CONTENT_DIR);
  const output = [];

  files.forEach(file => {
    const raw = fs.readFileSync(file, 'utf8');
    const { data, content } = matter(raw);

    const relativePath = path.relative(CONTENT_DIR, file);
    const parts = relativePath.split(path.sep);
    const collection = parts[0];

    let slug = parts.at(-1).replace('.md', '');
    if (slug === 'index') {
      slug = parts.slice(1, -1).join('/');
    }
    if (data.article_slug) slug = data.article_slug;

    const url =
      collection === 'projects' ? `/projects/${slug}/` : null;

    const chunks = extractChunks(content, collection, slug);
    const facts = extractFacts(chunks);

    output.push({
      id: relativePath,
      collection,
      slug,
      url,
      word_count: content.split(/\s+/).length,
      data,
      content,
      chunks,
      facts
    });
  });

  fs.mkdirSync(path.dirname(OUTPUT_FILE), { recursive: true });
  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2));
  console.log(`Exported ${output.length} documents`);
}

exportContent();