// index.js - Cloudflare Worker for portfolio GPT
var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

var CACHE = null;
var CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json"
};
async function loadContent() {
    if (CACHE) return CACHE;
    const res = await fetch("https://wahajaslm.github.io/portfolio/data/content.json");
    CACHE = await res.json();
    return CACHE;
}
__name(loadContent, "loadContent");
function scoreChunk(question, chunk, tags = []) {
    const qWords = question.toLowerCase().split(/\s+/);
    const text = chunk.text.toLowerCase();
    const tagText = tags.join(" ").toLowerCase();
    return qWords.filter(
        (w) => text.includes(w) || tagText.includes(w)
    ).length;
}
__name(scoreChunk, "scoreChunk");
function retrieve(question, docs) {
    const always = [];
    const scored = [];
    for (const doc of docs) {
        if (!doc.data?.use_for_ai) continue;
        const tags = doc.data?.tags || [];
        for (const chunk of doc.chunks || []) {
            if (chunk.kind === "skills.languages" || chunk.kind === "skills.domains") {
                always.push(chunk);
                continue;
            }
            const score = scoreChunk(question, chunk, tags);
            if (score > 0) scored.push({ ...chunk, score });
        }
    }
    // Sort scored chunks by relevance descending
    scored.sort((a, b) => b.score - a.score);
    // Prioritize scored chunks over always chunks
    const merged = [...scored, ...always];
    const seen = new Set();
    return merged.filter((c) => {
        const key = c.kind + c.text;
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
    }).slice(0, 8);
}
__name(retrieve, "retrieve");
function buildContext(chunks) {
    return chunks.map(
        (c) => `### ${c.kind.toUpperCase()}
${c.text}`
    ).join("\n\n");
}
__name(buildContext, "buildContext");
var index_default = {
    async fetch(req, env) {
        if (req.method === "OPTIONS") {
            return new Response(null, { headers: CORS_HEADERS });
        }
        if (req.method !== "POST") {
            return new Response(
                JSON.stringify({ error: "POST only" }),
                { status: 405, headers: CORS_HEADERS }
            );
        }
        try {
            const body = await req.json();
            const question = body?.question?.trim();
            if (!question) {
                return new Response(
                    JSON.stringify({ answer: "" }),
                    { headers: CORS_HEADERS }
                );
            }
            if (env.CHAT_LOGS) {
                await env.CHAT_LOGS.put(
                    crypto.randomUUID(),
                    JSON.stringify({
                        question,
                        time: new Date().toISOString(),
                        page: req.headers.get("referer") || "unknown"
                    }),
                    { expirationTtl: 60 * 60 * 24 * 30 }
                );
            }
            const docs = await loadContent();
            const chunks = retrieve(question, docs);
            if (chunks.length === 0) {
                return new Response(
                    JSON.stringify({
                        answer: "This information is not present in Wahaj’s public portfolio."
                    }),
                    { headers: CORS_HEADERS }
                );
            }
            const context = buildContext(chunks);
            const result = await env.AI.run(
                "@cf/meta/llama-3-8b-instruct",
                {
                    messages: [
                        {
                            role: "system",
                            content: "You are a portfolio assistant for recruiters and hiring managers.\n\nRules:\n1. Answer ONLY using the provided context.\n2. Use this structure unless the question clearly requires otherwise:\n   - Short headline with descriptive text (1 line)\n   - Bullet points grouped by theme\n   - Concrete examples (tools, projects, roles)\n3. Do NOT generalize (e.g., avoid vague phrases like 'audio processing').\n   Use explicit terms taken directly from the context.\n4. Do NOT exaggerate scope, impact, or seniority.\n5. Prefer clarity over completeness.\n\nTone: professional, technical, concise.",
                        },
                        {
                            role: "user",
                            content: `CONTEXT:\n${context}\n\nQUESTION:\n${question}`
                        }
                    ],
                    max_tokens: 350
                }
            );
            const answer = result.response || result.choices?.[0]?.message?.content || "";
            return new Response(
                JSON.stringify({
                    answer: answer.trim() || "I could not generate a reliable answer from the available portfolio content."
                }),
                { headers: CORS_HEADERS }
            );
        } catch (err) {
            return new Response(
                JSON.stringify({ error: err.message }),
                { status: 500, headers: CORS_HEADERS }
            );
        }
    }
};
export { index_default as default };
