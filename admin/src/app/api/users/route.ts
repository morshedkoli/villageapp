import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody } from "@/lib/api-handler";
import { createUserSchema } from "@/lib/schemas";

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createUserSchema);

  // `totalCitizens` is owned by the `onCitizenRegisteredNotifyAll` Cloud
  // Function, which increments on every `users` create. Incrementing here as
  // well counted each admin-added citizen twice.
  await getAdminDb().collection("users").add({
    ...input,
    isCitizen: true,
    blocked: false,
    addedBy: email,
    createdAt: FieldValue.serverTimestamp(),
  });

  return NextResponse.json({ ok: true });
});
