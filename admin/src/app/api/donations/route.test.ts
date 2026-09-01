import { describe, it, expect, beforeEach, vi } from "vitest";
import { NextRequest } from "next/server";
import {
  FakeFirestore,
  FieldValue,
} from "@/lib/__fixtures__/fake-firestore";

const store = new FakeFirestore();
const verifyAdmin = vi.fn();

vi.mock("firebase-admin/firestore", () => ({ FieldValue }));
vi.mock("@/lib/firebase-admin", () => ({ getAdminDb: () => store }));
vi.mock("@/lib/verify-admin", () => ({ verifyAdmin }));

// Imported after the mocks are registered.
const { POST, PATCH, DELETE } = await import("./route");

const ADMIN_EMAIL = "admin@example.com";
const VILLAGE_PATH = "villages/main_village";

function jsonRequest(method: string, body: unknown): NextRequest {
  return new NextRequest("http://localhost/api/donations", {
    method,
    body: JSON.stringify(body),
    headers: { "Content-Type": "application/json" },
  });
}

function queryRequest(method: string, query: string): NextRequest {
  return new NextRequest(`http://localhost/api/donations?${query}`, { method });
}

function fundTotal(): number {
  return Number(store.get(VILLAGE_PATH)?.totalFundCollected ?? 0);
}

function donationLedgerRows() {
  return store
    .collectionDocs("fund_transactions")
    .filter(([, data]) => data.type === "donation");
}

beforeEach(() => {
  store.docs.clear();
  verifyAdmin.mockReset();
  verifyAdmin.mockResolvedValue({ ok: true, email: ADMIN_EMAIL });

  store.seed(VILLAGE_PATH, {
    totalFundCollected: 1000,
    paymentAccounts: [
      { id: "acct-1", type: "bkash", number: "0170000", name: "Village Fund" },
    ],
  });
  store.seed("users/user-1", { name: "Rahim" });
});

describe("POST /api/donations", () => {
  it("credits the fund and writes a linked ledger row for an approved donation", async () => {
    const res = await POST(
      jsonRequest("POST", {
        userId: "user-1",
        amount: 500,
        paymentTarget: "cash",
        status: "Approved",
      })
    );

    expect(res.status).toBe(200);
    expect(fundTotal()).toBe(1500);

    const rows = donationLedgerRows();
    expect(rows).toHaveLength(1);
    expect(rows[0][1].amount).toBe(500);
    expect(rows[0][1].donationId).toBeTypeOf("string");
  });

  it("does not touch the fund for a pending donation", async () => {
    await POST(
      jsonRequest("POST", {
        userId: "user-1",
        amount: 500,
        paymentTarget: "cash",
        status: "Pending",
      })
    );

    expect(fundTotal()).toBe(1000);
    expect(donationLedgerRows()).toHaveLength(0);
  });

  it("rejects an unknown donor without writing anything", async () => {
    const res = await POST(
      jsonRequest("POST", {
        userId: "missing",
        amount: 500,
        paymentTarget: "cash",
      })
    );

    expect(res.status).toBe(400);
    expect(await res.json()).toEqual({ error: "Selected user does not exist" });
    expect(fundTotal()).toBe(1000);
    expect(store.collectionDocs("donations")).toHaveLength(0);
  });

  it("rejects a payment target that is no longer configured", async () => {
    const res = await POST(
      jsonRequest("POST", {
        userId: "user-1",
        amount: 500,
        paymentTarget: "acct-gone",
      })
    );

    expect(res.status).toBe(400);
    expect(await res.json()).toEqual({
      error: "Selected receiving account is no longer available",
    });
    expect(store.collectionDocs("donations")).toHaveLength(0);
  });

  it("rejects a non-positive amount", async () => {
    const res = await POST(
      jsonRequest("POST", {
        userId: "user-1",
        amount: 0,
        paymentTarget: "cash",
      })
    );

    expect(res.status).toBe(400);
    expect(fundTotal()).toBe(1000);
  });

  it("propagates the verifier's status for a non-admin caller", async () => {
    verifyAdmin.mockResolvedValue({
      ok: false,
      status: 401,
      error: "Missing bearer token",
    });

    const res = await POST(jsonRequest("POST", {}));

    expect(res.status).toBe(401);
    expect(fundTotal()).toBe(1000);
  });
});

describe("PATCH /api/donations", () => {
  it("credits the fund when a pending donation is approved", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 300,
      donorName: "Rahim",
    });

    const res = await PATCH(jsonRequest("PATCH", { id: "d1", action: "approve" }));

    expect(res.status).toBe(200);
    expect(fundTotal()).toBe(1300);
    expect(store.get("donations/d1")?.status).toBe("Approved");
    expect(donationLedgerRows()).toHaveLength(1);
  });

  it("is idempotent when approving an already-approved donation", async () => {
    store.seed("donations/d1", {
      status: "Approved",
      amount: 300,
      donorName: "Rahim",
    });

    await PATCH(jsonRequest("PATCH", { id: "d1", action: "approve" }));

    expect(fundTotal()).toBe(1000);
    expect(donationLedgerRows()).toHaveLength(0);
  });

  it("debits the fund when an approved donation is later rejected", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 300,
      donorName: "Rahim",
    });
    await PATCH(jsonRequest("PATCH", { id: "d1", action: "approve" }));
    expect(fundTotal()).toBe(1300);

    await PATCH(jsonRequest("PATCH", { id: "d1", action: "reject" }));

    expect(fundTotal()).toBe(1000);
    expect(store.get("donations/d1")?.status).toBe("Rejected");
    expect(donationLedgerRows()).toHaveLength(0);
  });

  it("leaves the fund alone when rejecting a pending donation", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 300,
      donorName: "Rahim",
    });

    await PATCH(jsonRequest("PATCH", { id: "d1", action: "reject" }));

    expect(fundTotal()).toBe(1000);
    expect(store.get("donations/d1")?.status).toBe("Rejected");
  });

  it("does not debit twice when a rejected donation is rejected again", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 300,
      donorName: "Rahim",
    });
    await PATCH(jsonRequest("PATCH", { id: "d1", action: "approve" }));
    await PATCH(jsonRequest("PATCH", { id: "d1", action: "reject" }));
    await PATCH(jsonRequest("PATCH", { id: "d1", action: "reject" }));

    expect(fundTotal()).toBe(1000);
  });

  it("404s for a donation that does not exist", async () => {
    const res = await PATCH(
      jsonRequest("PATCH", { id: "nope", action: "approve" })
    );

    expect(res.status).toBe(404);
    expect(await res.json()).toEqual({ error: "Donation not found" });
  });

  it("400s for an unknown action", async () => {
    const res = await PATCH(jsonRequest("PATCH", { id: "d1", action: "burn" }));
    expect(res.status).toBe(400);
  });
});

describe("DELETE /api/donations", () => {
  it("gives the money back when an approved donation is deleted", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 400,
      donorName: "Rahim",
    });
    await PATCH(jsonRequest("PATCH", { id: "d1", action: "approve" }));
    expect(fundTotal()).toBe(1400);

    const res = await DELETE(queryRequest("DELETE", "id=d1"));

    expect(res.status).toBe(200);
    expect(fundTotal()).toBe(1000);
    expect(store.get("donations/d1")).toBeUndefined();
    expect(donationLedgerRows()).toHaveLength(0);
  });

  it("leaves the fund alone when deleting a pending donation", async () => {
    store.seed("donations/d1", {
      status: "Pending",
      amount: 400,
      donorName: "Rahim",
    });

    await DELETE(queryRequest("DELETE", "id=d1"));

    expect(fundTotal()).toBe(1000);
    expect(store.get("donations/d1")).toBeUndefined();
  });

  it("404s for a donation that does not exist", async () => {
    const res = await DELETE(queryRequest("DELETE", "id=nope"));
    expect(res.status).toBe(404);
  });

  it("400s when no id is supplied", async () => {
    const res = await DELETE(queryRequest("DELETE", ""));
    expect(res.status).toBe(400);
  });
});
