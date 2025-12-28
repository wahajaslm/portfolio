---
visibility: public
use_for_ai: true
title: "Turning a Portfolio Into a Queryable System"
summary: "Designing a Deterministic RAG Assistant on Cloudflare Workers"
year: "Technical Deep Dive"
format: "System Architecture"
code: "SYS-01"
cover_image: "https://images.unsplash.com/photo-1558494949-ef526bca4899?q=80&w=1000&auto=format&fit=crop"
tags: [rag, cloudflare-workers, ai, vector-search, system-design]
article_slug: "deterministic-rag-assistant"
---

Most technical portfolios are static descriptions of work. They contain useful information, but the structure is optimized for reading, not for answering questions.

A recruiter may want to know whether someone has worked on real-time audio systems, which programming languages they use daily, or what kind of constraints they have operated under. The answers are often present, but spread across different pages and written for narrative flow rather than direct retrieval.

This project explores a different approach: treating a portfolio as a small, well-defined dataset that can be queried directly. The goal was not to build a chatbot in the usual sense, but a constrained question–answering system that only responds using verifiable information from the portfolio itself.

---

## Why a generic chatbot was not sufficient

The most obvious way to add AI to a portfolio is to attach a chat interface and send user questions to a large language model. This approach breaks down quickly.

Language models tend to generalize, fill gaps, and smooth over missing details. That behavior is useful in many applications, but it is a poor fit for a portfolio, where precision matters more than fluency.

From the beginning, one constraint guided the design:

Every answer must be grounded in existing portfolio content, and the system must explicitly say when the information is not available.

This immediately pushed the design toward a retrieval-augmented generation setup, but with tighter controls than most RAG examples.

---

## Treating the portfolio as data

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

## Semantic chunking instead of arbitrary splitting

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

## A deterministic baseline before embeddings

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

## Adding embeddings with strict boundaries

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

## Overall system architecture

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

## Controlled answer generation

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

## Example queries and behavior

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

## Refactoring this into a reusable RAG template

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

## Closing remarks

This project treats AI as an interface layer, not an authority. The system does not decide what is true. It only retrieves and presents what has already been written.

By structuring the data carefully and keeping generation constrained, it becomes possible to ask precise questions and receive reliable answers from a static portfolio.
