import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import {
  createProjectSchema,
  idQuerySchema,
  updateProjectSchema,
} from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const project = await parseJsonBody(req, createProjectSchema);

  await getAdminDb().collection("projects").add({
    ...project,
    createdAt: FieldValue.serverTimestamp(),
    addedBy: email,
  });

  return NextResponse.json({ ok: true });
});

export const PATCH = withAdminRoute(async (req, { email }) => {
  const { id, ...project } = await parseJsonBody(req, updateProjectSchema);

  await getAdminDb()
    .collection("projects")
    .doc(id)
    .set(
      {
        ...project,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: email,
      },
      { merge: true }
    );

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  await getAdminDb().collection("projects").doc(id).delete();
  return NextResponse.json({ ok: true });
});
