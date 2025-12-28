---
visibility: public
use_for_ai: true
title: "My Live Portfolio — VHS"
summary: "A living tape about why I turned my career into an adaptive portfolio instead of a flat PDF—humorous, reflective, and stubbornly alive."
year: "Personal System"
format: "Project Archive"
code: "VHS-09"
cover_image: "https://images.unsplash.com/photo-1516116216624-53e697fedbea?q=80&w=1000&auto=format&fit=crop"
tags: [portfolio, web_design, javascript, css, html, accessibility, writing, branding, ai, storytelling]
article_slug: "my-live-portfolio"
---

I didn’t create this project because I was looking for another section to add to my website. I created it because I discovered something mildly disturbing after years of working.

**My CV had become a stranger.**

The titles were correct and the job descriptions were technically accurate, but the real substance of my work was completely missing. The problems I solved, the systems I built, and the mistakes I learned from didn't exist on paper. Everything felt flattened and dehydrated. My career looked like an over-compressed audio file that was recognizable but missing all the richness. The strangest part wasn’t that others couldn’t see the real work I had done. The strangest part was that I had started to forget half of it myself.

It hit me when I tried to update my CV properly. Scrolling through old sections, I realized I had to think hard just to remember certain projects I once worked on daily. Technical decisions I made confidently back then were now blurry details buried under years of new responsibilities. That’s when it clicked.

**A CV is not a portrait. It is a passport photo.**

It is flat, tiny, and only vaguely similar to the real person. I decided I didn’t want to be represented by something that forgettable.

Before anything became a project, it became an excavation. I opened old internship reports, thesis documents, job folders, research notes, side projects, and random screenshots. I even found files with suspicious names like `final_v3_realfinal_OK.pdf`. Some of it made me laugh, some of it made me nostalgic. But the more I organized, the more overwhelming it became because a mountain of content is still a mountain. If I tried to dump all of it onto a webpage, I knew no one would read it—not even me. Organization alone wasn’t enough. I needed something that could make sense of it all.

This was the moment the idea sharpened. Instead of juggling fifteen versions of a CV or writing summaries for every purpose, I wondered if my portfolio could adapt. I wanted to know if it could answer different questions or tell different stories based on what someone needs to know.

**What if my career could talk back?**

That is how the idea of a Live Portfolio came to life. It is a system that doesn’t just display my work, but actually understands it. Emotions got me started, but systems thinking finished the idea. I began treating my career like an engineering problem. I took all the raw data of documents and timelines, structured them by skills and responsibilities, and looked for the meaning in what those experiences actually say about me. It became an encoder for my professional identity: taking the messy but meaningful journey as input, and outputting tailored, coherent human explanations.

This felt more like me than any CV I had ever written. Part of this project is absolutely me refusing to let anyone judge my entire engineering life in the eight seconds they spend scanning a CV. But the other part is personal. I realized I needed something alive that grows with me. It is a rebellion against being reduced to two pages, a system that keeps my work alive instead of archived, and a tool that helps me understand myself as much as others understand me. Most of all, it’s an honest attempt to represent myself properly—not as a static document, but as an ongoing story.

---

## Turning a Portfolio Into a Queryable System

Designing a Deterministic RAG Assistant on Cloudflare Workers

Most technical portfolios are static descriptions of work. They contain useful information, but the structure is optimized for reading, not for answering questions.

A recruiter may want to know whether someone has worked on real-time audio systems, which programming languages they use daily, or what kind of constraints they have operated under. The answers are often present, but spread across different pages and written for narrative flow rather than direct retrieval.

This project explores a different approach: treating a portfolio as a small, well-defined dataset that can be queried directly. The goal was not to build a chatbot in the usual sense, but a constrained question–answering system that only responds using verifiable information from the portfolio itself.

---

### 1. Why a generic chatbot was not sufficient

The most obvious way to add AI to a portfolio is to attach a chat interface and send user questions to a large language model. This approach breaks down quickly.

Language models tend to generalize, fill gaps, and smooth over missing details. That behavior is useful in many applications, but it is a poor fit for a portfolio, where precision matters more than fluency.

From the beginning, one constraint guided the design:

Every answer must be grounded in existing portfolio content, and the system must explicitly say when the information is not available.

This immediately pushed the design toward a retrieval-augmented generation setup, but with tighter controls than most RAG examples.

---

### 2. Treating the portfolio as data

The portfolio already existed as Markdown files used by a static site generator. These files were written for human readers and contained headers, lists, formatting, and narrative sections.

Instead of letting the AI interpret rendered pages, the first step was to create a dedicated export pipeline that converts all portfolio content into a structured JSON file. This file becomes the single source of truth for the assistant.

Each Markdown file is parsed and converted into an object containing metadata, raw text, and a set of smaller semantic chunks.

A simplified version of the export logic looks like this:

```js
const files = getAllFiles(CONTENT_DIR);

const data = files.map(file => {
  const raw = fs.readFileSync(file, 'utf8');
  const { data: frontmatter, content } = matter(raw);

  return {
    id: file,
    collection: detectCollection(file),
    slug: detectSlug(file),
    data: frontmatter,
    content,
    chunks: extractChunks(content)
  };
});
```

The important point is that this step is deterministic. There is no AI involved. The same Markdown input always produces the same JSON output.

---

### 3. Semantic chunking instead of arbitrary splitting

Many RAG systems split text by character count or token length. That approach works for large documents, but portfolios are small and intent-driven.

Here, chunking is semantic and explicit. Each chunk represents one idea and is labeled with a type, such as:
	•	skills.languages
	•	experience.audio_dsp
	•	projects.real_time
	•	experience.constraints

Chunk extraction is based on headers and known section names rather than token limits.

For example, in the export script:

```js
if (collection === 'skills') {
  addListChunks('skills.languages', getListItems(/Languages/i));
  addListChunks('skills.tools', getListItems(/Tools/i));
  addListChunks('skills.domains', getListItems(/DSP & Audio/i));
}
```

These labels later allow the retrieval layer to treat skills, experience, and projects differently without relying on probabilistic inference.

At this stage, most of the intelligence is already encoded in the data preparation step. The model is intentionally kept simple.

---

### 4. A deterministic baseline before embeddings

Before introducing embeddings, a keyword-based retrieval layer was implemented as a baseline.

Incoming questions were matched against chunk text and metadata. Some information, such as skills and profile summaries, was always included. Experience and project chunks were ranked by relevance.

This logic ran directly inside the Cloudflare Worker:

```js
function scoreChunk(question, chunk, tags = []) {
  const qWords = question.toLowerCase().split(/\s+/);
  const text = chunk.text.toLowerCase();
  const tagText = tags.join(" ").toLowerCase();

  return qWords.filter(
    w => text.includes(w) || tagText.includes(w)
  ).length;
}
```

This approach was predictable and safe, but insufficient for questions that relied on meaning rather than exact wording.

---

### 5. Adding embeddings with strict boundaries

Embeddings were introduced to improve retrieval quality, not to loosen control.

Each semantic chunk is converted into an embedding and stored in a Cloudflare Vectorize index. Metadata such as chunk type and source document is preserved alongside the vector.

Index creation is handled once during setup:

```bash
wrangler vectorize create portfolio_chunks --dimensions=768
```

Chunk ingestion happens offline or during a controlled update process, not at runtime.

At query time, the worker performs semantic search:

```js
const embedding = await env.AI.run(
  "@cf/baai/bge-base-en-v1.5",
  { text: question }
);

const results = await env.VECTOR_INDEX.query(
  embedding.data[0],
  { topK: 6 }
);
```

The result is a ranked list of chunks, each of which still corresponds to a specific, authored piece of text.

---

### 6. Overall system architecture

Once all pieces are in place, the architecture is straightforward:

```
Static HTML / JS site (GitHub Pages)
        |
        | POST question
        v
Cloudflare Worker
        |
        | vector search
        v
Vectorize index (semantic chunks)
        |
        | selected context
        v
Language model (answer generation)
```

The static site never talks to the model directly. All logic is centralized in the worker, which keeps the system auditable and versioned.

---

### 7. Controlled answer generation

The model is used only after retrieval, and only to turn retrieved evidence into a readable answer.

The system prompt is intentionally strict:

```js
{
  role: "system",
  content:
    "You are a portfolio assistant for recruiters and hiring managers. " +
    "Answer only using the provided context. " +
    "Do not generalize or infer beyond the text. " +
    "Use explicit terms and concrete examples."
}
```

If the retrieved context does not contain the answer, the model is expected to say so.

This constraint prevents hallucinated seniority, inflated scope, or inferred responsibilities.

---

### 8. Example queries and behavior

A question such as:

**What audio and DSP experience does Wahaj have and which languages does he know?**

produces an answer assembled from multiple chunk types:
	•	experience.audio_dsp
	•	projects.real_time
	•	skills.languages

The response is concise, grounded, and traceable to specific portfolio sections.

By contrast, a question like:

**How long did he work at Fraunhofer?**

correctly returns that the information is not present, exposing a documentation gap rather than guessing.

---

### 9. Refactoring this into a reusable RAG template

Although this system was built for a personal portfolio, the design generalizes cleanly.

A reusable template consists of four layers:

**Content preparation**
Markdown or text files are parsed, normalized, and chunked semantically.

**Indexing**
Each chunk becomes one embedding with preserved metadata.

**Retrieval**
Semantic search selects evidence deterministically with hard limits.

**Generation**
A constrained prompt produces readable answers without inference.

This template works particularly well for small, high-signal datasets where correctness matters more than creativity.

---

### Closing remarks

This project treats AI as an interface layer, not an authority. The system does not decide what is true. It only retrieves and presents what has already been written.

By structuring the data carefully and keeping generation constrained, it becomes possible to ask precise questions and receive reliable answers from a static portfolio.
