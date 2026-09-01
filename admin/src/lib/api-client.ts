"use client";

import { auth } from "./firebase";

/**
 * Client-side wrapper for the admin API routes. Attaches a fresh Firebase ID
 * token, sets the JSON content type, and normalizes error responses so callers
 * can rely on a thrown `Error` with the server's message.
 *
 * Every mutation in the admin UI goes through here — building the headers by
 * hand in each page is how the `user?.getIdToken()` variants drifted into
 * silently sending unauthenticated requests.
 */
async function authorizedHeaders(
  extra?: HeadersInit
): Promise<Record<string, string>> {
  const user = auth.currentUser;
  if (!user) {
    throw new Error("You are signed out. Please sign in again.");
  }

  const token = await user.getIdToken();
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${token}`,
    ...(extra as Record<string, string> | undefined),
  };
}

export async function authFetch(
  path: string,
  init: RequestInit = {}
): Promise<Response> {
  return fetch(path, {
    ...init,
    headers: await authorizedHeaders(init.headers),
  });
}

/**
 * Performs an authenticated request and returns the parsed JSON body, throwing
 * the server's `{ error }` message (or a status fallback) on a non-2xx.
 */
export async function authJson<T = unknown>(
  path: string,
  init: RequestInit = {}
): Promise<T> {
  const res = await authFetch(path, init);
  const data = (await res.json().catch(() => ({}))) as T & { error?: string };

  if (!res.ok) {
    throw new Error(data.error || `Request failed (${res.status})`);
  }

  return data;
}

/** Any JSON-serializable request payload — typed form objects included. */
type JsonBody = object;

export const apiClient = {
  get: <T = unknown>(path: string) => authJson<T>(path),
  post: <T = unknown>(path: string, body: JsonBody) =>
    authJson<T>(path, { method: "POST", body: JSON.stringify(body) }),
  patch: <T = unknown>(path: string, body: JsonBody) =>
    authJson<T>(path, { method: "PATCH", body: JSON.stringify(body) }),
  delete: <T = unknown>(path: string, params?: Record<string, string>) => {
    const query = params ? `?${new URLSearchParams(params).toString()}` : "";
    return authJson<T>(`${path}${query}`, { method: "DELETE" });
  },
};

/** Extracts a user-facing message from an unknown thrown value. */
export function errorMessage(error: unknown, fallback = "Something went wrong"): string {
  return error instanceof Error && error.message ? error.message : fallback;
}
