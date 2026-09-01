import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { badRequest, notFound } from "@/lib/api-error";
import { villageRef } from "@/lib/village";
import { createExpenseSchema, idQuerySchema } from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createExpenseSchema);
  const db = getAdminDb();
  const expenseRef = db.collection("fund_transactions").doc();

  await db.runTransaction(async (tx) => {
    tx.set(expenseRef, {
      type: "expense",
      amount: input.amount,
      reference: input.project,
      project: input.project,
      category: input.category || "Other",
      notes: input.notes,
      createdAt: FieldValue.serverTimestamp(),
      addedBy: email,
    });

    tx.set(
      villageRef(db),
      { totalSpent: FieldValue.increment(input.amount) },
      { merge: true }
    );
  });

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  const db = getAdminDb();
  const expenseRef = db.collection("fund_transactions").doc(id);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(expenseRef);
    if (!snap.exists) {
      throw notFound("Expense not found");
    }

    const data = snap.data() as { type?: string; amount?: number } | undefined;
    if (data?.type !== "expense") {
      throw badRequest("Transaction is not an expense");
    }

    const amount = Math.max(0, Math.round(Number(data.amount ?? 0)));
    tx.delete(expenseRef);

    if (amount > 0) {
      tx.set(
        villageRef(db),
        { totalSpent: FieldValue.increment(-amount) },
        { merge: true }
      );
    }
  });

  return NextResponse.json({ ok: true });
});
