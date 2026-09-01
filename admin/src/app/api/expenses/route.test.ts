import { describe, it, expect, beforeEach, vi } from "vitest";
import { NextRequest } from "next/server";
import { FakeFirestore, FieldValue } from "@/lib/__fixtures__/fake-firestore";

const store = new FakeFirestore();
const verifyAdmin = vi.fn();

vi.mock("firebase-admin/firestore", () => ({ FieldValue }));
vi.mock("@/lib/firebase-admin", () => ({ getAdminDb: () => store }));
vi.mock("@/lib/verify-admin", () => ({ verifyAdmin }));

// Imported after the mocks are registered.
const { POST, DELETE } = await import("./route");

const VILLAGE_PATH = "villages/main_village";

function jsonRequest(body: unknown): NextRequest {
  return new NextRequest("http://localhost/api/expenses", {
    method: "POST",
    body: JSON.stringify(body),
    headers: { "Content-Type": "application/json" },
  });
}

function deleteRequest(query: string): NextRequest {
  return new NextRequest(`http://localhost/api/expenses?${query}`, {
    method: "DELETE",
  });
}

function spentTotal(): number {
  return Number(store.get(VILLAGE_PATH)?.totalSpent ?? 0);
}

beforeEach(() => {
  store.docs.clear();
  verifyAdmin.mockReset();
  verifyAdmin.mockResolvedValue({ ok: true, email: "admin@example.com" });
  store.seed(VILLAGE_PATH, { totalSpent: 2000 });
});

describe("POST /api/expenses", () => {
  it("records the expense and increases the spent total", async () => {
    const res = await POST(
      jsonRequest({ project: "Road repair", category: "Civil", amount: 750 })
    );

    expect(res.status).toBe(200);
    expect(spentTotal()).toBe(2750);

    const [[, expense]] = store.collectionDocs("fund_transactions");
    expect(expense.type).toBe("expense");
    expect(expense.amount).toBe(750);
    expect(expense.project).toBe("Road repair");
  });

  it("defaults a blank category to Other", async () => {
    await POST(jsonRequest({ project: "Road repair", amount: 100 }));

    const [[, expense]] = store.collectionDocs("fund_transactions");
    expect(expense.category).toBe("Other");
  });

  it("rejects a missing project title", async () => {
    const res = await POST(jsonRequest({ amount: 100 }));

    expect(res.status).toBe(400);
    expect(spentTotal()).toBe(2000);
  });

  it("rejects a non-positive amount", async () => {
    const res = await POST(jsonRequest({ project: "Road repair", amount: -5 }));

    expect(res.status).toBe(400);
    expect(spentTotal()).toBe(2000);
  });
});

describe("DELETE /api/expenses", () => {
  it("reduces the spent total when an expense is removed", async () => {
    store.seed("fund_transactions/e1", { type: "expense", amount: 500 });

    const res = await DELETE(deleteRequest("id=e1"));

    expect(res.status).toBe(200);
    expect(spentTotal()).toBe(1500);
    expect(store.get("fund_transactions/e1")).toBeUndefined();
  });

  it("refuses to delete a donation ledger row through the expense route", async () => {
    store.seed("fund_transactions/d1", { type: "donation", amount: 500 });

    const res = await DELETE(deleteRequest("id=d1"));

    expect(res.status).toBe(400);
    expect(await res.json()).toEqual({ error: "Transaction is not an expense" });
    expect(store.get("fund_transactions/d1")).toBeDefined();
    expect(spentTotal()).toBe(2000);
  });

  it("404s for an expense that does not exist", async () => {
    const res = await DELETE(deleteRequest("id=nope"));
    expect(res.status).toBe(404);
  });
});
