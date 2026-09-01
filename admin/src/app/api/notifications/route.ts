import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { createNotificationSchema, idQuerySchema } from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createNotificationSchema);

  await getAdminDb().collection("notifications").add({
    title: input.title,
    body: input.body,
    type: input.type,
    source: "admin",
    createdAt: FieldValue.serverTimestamp(),
    addedBy: email,
  });

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  await getAdminDb().collection("notifications").doc(id).delete();
  return NextResponse.json({ ok: true });
});
