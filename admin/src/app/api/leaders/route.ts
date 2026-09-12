import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { notFound } from "@/lib/api-error";
import {
  createLeaderSchema,
  idQuerySchema,
  updateLeaderSchema,
} from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createLeaderSchema);

  await getAdminDb().collection("leaders").add({
    ...input,
    createdAt: FieldValue.serverTimestamp(),
    addedBy: email,
  });

  return NextResponse.json({ ok: true });
});

export const PATCH = withAdminRoute(async (req, { email }) => {
  const { id, ...leader } = await parseJsonBody(req, updateLeaderSchema);
  const leaderRef = getAdminDb().collection("leaders").doc(id);

  const snap = await leaderRef.get();
  if (!snap.exists) {
    throw notFound("Leader not found");
  }

  await leaderRef.set(
    {
      ...leader,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: email,
    },
    { merge: true }
  );

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  await getAdminDb().collection("leaders").doc(id).delete();
  return NextResponse.json({ ok: true });
});
