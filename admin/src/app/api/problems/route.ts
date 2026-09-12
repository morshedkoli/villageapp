import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { notFound } from "@/lib/api-error";
import {
  createProblemSchema,
  idQuerySchema,
  updateProblemStatusSchema,
} from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createProblemSchema);

  await getAdminDb().collection("problems").add({
    ...input,
    createdAt: FieldValue.serverTimestamp(),
    reportedBy: email,
    reportedByName: "Admin",
    source: "admin",
  });

  return NextResponse.json({ ok: true });
});

export const PATCH = withAdminRoute(async (req, { email }) => {
  const { id, status } = await parseJsonBody(req, updateProblemStatusSchema);
  const problemRef = getAdminDb().collection("problems").doc(id);

  const snap = await problemRef.get();
  if (!snap.exists) {
    throw notFound("Problem not found");
  }

  await problemRef.update({
    status,
    statusUpdatedAt: FieldValue.serverTimestamp(),
    statusUpdatedBy: email,
  });

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  await getAdminDb().collection("problems").doc(id).delete();
  return NextResponse.json({ ok: true });
});
