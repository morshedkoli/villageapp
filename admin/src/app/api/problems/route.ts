import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { createProblemSchema, idQuerySchema } from "@/lib/schemas";

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

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  await getAdminDb().collection("problems").doc(id).delete();
  return NextResponse.json({ ok: true });
});
