import { describe, it, expect, vi, beforeEach } from "vitest";
import type { NextRequest } from "next/server";

const verifyIdToken = vi.fn();
const docGet = vi.fn();

vi.mock("./firebase-admin", () => ({
  getAdminAuth: () => ({ verifyIdToken }),
  getAdminDb: () => ({
    collection: () => ({
      doc: () => ({ get: docGet }),
    }),
  }),
}));

vi.mock("./admin-access", async () => {
  const actual = await vi.importActual<typeof import("./admin-access")>(
    "./admin-access"
  );
  return actual;
});

// Imported after the mocks are registered.
const { verifyAdmin } = await import("./verify-admin");

function makeRequest(authHeader?: string): NextRequest {
  return {
    headers: {
      get: (name: string) =>
        name.toLowerCase() === "authorization" ? authHeader ?? null : null,
    },
  } as unknown as NextRequest;
}

beforeEach(() => {
  verifyIdToken.mockReset();
  docGet.mockReset();
});

describe("verifyAdmin", () => {
  it("rejects requests without a bearer token", async () => {
    const result = await verifyAdmin(makeRequest());
    expect(result).toEqual({ ok: false, status: 401, error: "Missing bearer token" });
  });

  it("accepts a token with the admin custom claim", async () => {
    verifyIdToken.mockResolvedValue({ email: "user@example.com", admin: true });
    const result = await verifyAdmin(makeRequest("Bearer good-token"));
    expect(result).toEqual({ ok: true, email: "user@example.com" });
  });

  it("accepts the bootstrap admin email even without the custom claim", async () => {
    verifyIdToken.mockResolvedValue({ email: "murshedkoli@gmail.com", admin: false });
    const result = await verifyAdmin(makeRequest("Bearer good-token"));
    expect(result).toEqual({ ok: true, email: "murshedkoli@gmail.com" });
  });

  it("accepts a user listed in the Firestore admins collection", async () => {
    verifyIdToken.mockResolvedValue({ email: "someone@example.com", admin: false });
    docGet.mockResolvedValue({ exists: true });
    const result = await verifyAdmin(makeRequest("Bearer good-token"));
    expect(result).toEqual({ ok: true, email: "someone@example.com" });
  });

  it("rejects a signed-in non-admin user", async () => {
    verifyIdToken.mockResolvedValue({ email: "someone@example.com", admin: false });
    docGet.mockResolvedValue({ exists: false });
    const result = await verifyAdmin(makeRequest("Bearer good-token"));
    expect(result).toEqual({
      ok: false,
      status: 401,
      error: "Signed-in user is not an admin",
    });
  });

  it("rejects a token with no email", async () => {
    verifyIdToken.mockResolvedValue({ email: undefined, admin: false });
    const result = await verifyAdmin(makeRequest("Bearer good-token"));
    expect(result).toEqual({
      ok: false,
      status: 401,
      error: "No email associated with this account",
    });
  });

  it("returns 401 for an invalid/expired token", async () => {
    verifyIdToken.mockRejectedValue(new Error("Decoding Firebase ID token failed"));
    const result = await verifyAdmin(makeRequest("Bearer bad-token"));
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.status).toBe(401);
  });

  it("returns 500 when the failure looks like a server misconfiguration", async () => {
    verifyIdToken.mockRejectedValue(new Error("project_id is required"));
    const result = await verifyAdmin(makeRequest("Bearer bad-token"));
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.status).toBe(500);
  });
});
