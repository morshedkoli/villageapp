import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody } from "@/lib/api-handler";
import { villageRef } from "@/lib/village";
import { createUserSchema } from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createUserSchema);
  const db = getAdminDb();
  const userRef = db.collection("users").doc();

  await db.runTransaction(async (tx) => {
    tx.set(userRef, {
      ...input,
      isCitizen: true,
      blocked: false,
      addedBy: email,
      createdAt: FieldValue.serverTimestamp(),
    });

    tx.set(
      villageRef(db),
      { totalCitizens: FieldValue.increment(1) },
      { merge: true }
    );
  });

  return NextResponse.json({ ok: true });
});
