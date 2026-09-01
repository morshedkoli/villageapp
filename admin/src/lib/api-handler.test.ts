import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";

const verifyAdmin = vi.fn();
vi.mock("./verify-admin", () => ({ verifyAdmin }));

// Imported after the mocks are registered.
const {
  withApiErrorHandling,
  withAdminRoute,
  parseJsonBody,
  parseQuery,
} = await import("./api-handler");
const { ApiError, badRequest } = await import("./api-error");

function makeRequest(url = "http://localhost/api/test"): NextRequest {
  return new NextRequest(url, { method: "POST" });
}

function jsonRequest(body: unknown): NextRequest {
  return new NextRequest("http://localhost/api/test", {
    method: "POST",
    body: JSON.stringify(body),
    headers: { "Content-Type": "application/json" },
  });
}

describe("withApiErrorHandling", () => {
  let consoleErrorSpy: ReturnType<typeof vi.spyOn>;

  beforeEach(() => {
    consoleErrorSpy = vi.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    consoleErrorSpy.mockRestore();
  });

  it("passes through a successful response unchanged", async () => {
    const handler = withApiErrorHandling(async () =>
      NextResponse.json({ ok: true })
    );
    const res = await handler(makeRequest());
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true });
  });

  it("converts a thrown Error into a 500 JSON response", async () => {
    const handler = withApiErrorHandling(async () => {
      throw new Error("Firestore is down");
    });
    const res = await handler(makeRequest());
    expect(res.status).toBe(500);
    expect(await res.json()).toEqual({ error: "Firestore is down" });
    expect(consoleErrorSpy).toHaveBeenCalled();
  });

  it("falls back to a generic message for non-Error throws", async () => {
    const handler = withApiErrorHandling(async () => {
      throw "just a string";
    });
    const res = await handler(makeRequest());
    expect(res.status).toBe(500);
    expect(await res.json()).toEqual({ error: "Unexpected server error" });
  });

  it("maps an ApiError to its own status without logging a 500", async () => {
    const handler = withApiErrorHandling(async () => {
      throw badRequest("Amount must be positive");
    });
    const res = await handler(makeRequest());
    expect(res.status).toBe(400);
    expect(await res.json()).toEqual({ error: "Amount must be positive" });
    expect(consoleErrorSpy).not.toHaveBeenCalled();
  });

  it("maps a ZodError to a 400 naming the offending field", async () => {
    const schema = z.object({ amount: z.number() });
    const handler = withApiErrorHandling(async (req) => {
      await parseJsonBody(req, schema);
      return NextResponse.json({ ok: true });
    });

    const res = await handler(jsonRequest({ amount: "lots" }));
    expect(res.status).toBe(400);
    expect((await res.json()).error).toContain("amount");
  });

  it("validates a missing body as an empty object", async () => {
    const schema = z.object({ name: z.string() });
    const handler = withApiErrorHandling(async (req) => {
      await parseJsonBody(req, schema);
      return NextResponse.json({ ok: true });
    });

    const res = await handler(makeRequest());
    expect(res.status).toBe(400);
  });
});

describe("withAdminRoute", () => {
  beforeEach(() => {
    verifyAdmin.mockReset();
  });

  it("passes the verified admin email to the handler", async () => {
    verifyAdmin.mockResolvedValue({ ok: true, email: "admin@example.com" });

    const handler = withAdminRoute(async (_req, ctx) =>
      NextResponse.json({ email: ctx.email })
    );

    const res = await handler(makeRequest());
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ email: "admin@example.com" });
  });

  it("short-circuits with the verifier's status and never calls the handler", async () => {
    verifyAdmin.mockResolvedValue({
      ok: false,
      status: 401,
      error: "Signed-in user is not an admin",
    });
    const handler = vi.fn();

    const res = await withAdminRoute(handler)(makeRequest());

    expect(res.status).toBe(401);
    expect(await res.json()).toEqual({ error: "Signed-in user is not an admin" });
    expect(handler).not.toHaveBeenCalled();
  });

  it("still maps errors thrown by the handler", async () => {
    verifyAdmin.mockResolvedValue({ ok: true, email: "admin@example.com" });

    const handler = withAdminRoute(async () => {
      throw new ApiError(403, "Not allowed");
    });

    const res = await handler(makeRequest());
    expect(res.status).toBe(403);
    expect(await res.json()).toEqual({ error: "Not allowed" });
  });
});

describe("parseQuery", () => {
  it("validates search params", () => {
    const schema = z.object({ id: z.string().min(1) });
    const req = makeRequest("http://localhost/api/test?id=abc");
    expect(parseQuery(req, schema)).toEqual({ id: "abc" });
  });

  it("throws when a required param is absent", () => {
    const schema = z.object({ id: z.string().min(1) });
    expect(() => parseQuery(makeRequest(), schema)).toThrow();
  });
});
