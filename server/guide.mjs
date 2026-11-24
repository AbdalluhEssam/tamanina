import { createServer } from 'node:http';
import { pathToFileURL } from 'node:url';

const maxBodyBytes = 32 * 1024;
const maxMessageLength = 1500;
const systemPrompt = [
  'You are the Tamanina assistant for an Islamic companion app.',
  'Answer concisely in the requested language.',
  'Do not invent Quran quotations, hadith, or sources.',
  'For individual religious rulings, explain the limits of a general answer and refer the user to a qualified scholar.',
].join(' ');

export function createGuideServer({
  apiKey = process.env.GROQ_API_KEY,
  model = process.env.GROQ_MODEL || 'openai/gpt-oss-20b',
  requestModel = fetch,
} = {}) {
  return createServer(async (request, response) => {
    function send(status, body) {
      response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8' });
      response.end(JSON.stringify(body));
    }

    if (request.url !== '/guide' || request.method !== 'POST') {
      send(404, { error: 'Not found' });
      return;
    }
    if (!apiKey) {
      send(503, { error: 'Assistant unavailable' });
      return;
    }

    let input;
    try {
      const chunks = [];
      let size = 0;
      for await (const chunk of request.iterator({ destroyOnReturn: false })) {
        size += chunk.length;
        if (size > maxBodyBytes) {
          request.resume();
          send(413, { error: 'Request too large' });
          return;
        }
        chunks.push(chunk);
      }
      input = JSON.parse(Buffer.concat(chunks).toString('utf8'));
    } catch {
      send(400, { error: 'Invalid JSON' });
      return;
    }

    const message = typeof input?.message === 'string' ? input.message.trim() : '';
    if (!message || message.length > maxMessageLength) {
      send(400, { error: 'Invalid message' });
      return;
    }

    const history = Array.isArray(input.history)
      ? input.history.slice(-6).filter(
          (turn) => ['user', 'assistant'].includes(turn?.role) &&
            typeof turn.content === 'string',
        ).map(({ role, content }) => ({ role, content: content.slice(0, maxMessageLength) }))
      : [];
    const language = input.language === 'ar' ? 'Arabic' : 'English';

    try {
      const completion = await requestModel('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model,
          messages: [
            { role: 'system', content: `${systemPrompt} Reply in ${language}.` },
            ...history,
            { role: 'user', content: message },
          ],
          max_completion_tokens: 600,
        }),
        signal: AbortSignal.timeout(10_000),
      });
      if (!completion.ok) {
        send(502, { error: 'Assistant unavailable' });
        return;
      }
      const result = await completion.json();
      const answer = result.choices?.[0]?.message?.content?.trim();
      send(answer ? 200 : 502, answer ? { answer } : { error: 'Assistant unavailable' });
    } catch {
      send(502, { error: 'Assistant unavailable' });
    }
  });
}

if (process.argv[1] && pathToFileURL(process.argv[1]).href === import.meta.url) {
  const port = Number(process.env.PORT || 8080);
  createGuideServer().listen(port, '127.0.0.1');
}
