import { getDB } from '../db';

const API_BASE = import.meta.env.VITE_API_URL ?? 'https://api.preflight.valderis.com';

async function getToken(): Promise<string | null> {
  try {
    const db = await getDB();
    const auth = await db.get('auth', 'session');
    return auth?.token ?? null;
  } catch {
    return null;
  }
}

export async function apiFetch<T>(
  path: string,
  options: RequestInit = {}
): Promise<T> {
  const token = await getToken();

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const maxRetries = options.method === 'POST' ? 3 : 1;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const res = await fetch(`${API_BASE}${path}`, {
        ...options,
        headers,
      });

      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        const status = res.status;
        // Retry on 5xx or 429, not on 4xx client errors
        if (attempt < maxRetries && (status >= 500 || status === 429)) {
          await new Promise(r => setTimeout(r, 1000 * attempt));
          continue;
        }
        throw new Error(body.error ?? `API error ${status}`);
      }

      return res.json() as Promise<T>;
    } catch (err) {
      if (attempt < maxRetries && err instanceof TypeError) {
        // Network error — retry
        await new Promise(r => setTimeout(r, 1000 * attempt));
        continue;
      }
      throw err;
    }
  }

  throw new Error('Request failed after retries');
}
