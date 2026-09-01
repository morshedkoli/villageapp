import { NextResponse } from "next/server";
import { FieldValue } from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import {
  getBootstrapAdminEmails,
  isBootstrapAdminEmail,
} from "@/lib/admin-access";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { forbidden } from "@/lib/api-error";
import { adminEmailQuerySchema, createAdminSchema } from "@/lib/schemas";

export const GET = withAdminRoute(async () => {
  const snap = await getAdminDb().collection("admins").orderBy("email").get();

  const admins = [
    ...getBootstrapAdminEmails().map((email) => ({
      id: email,
      email,
      addedBy: "system",
      addedAt: null,
    })),
    ...snap.docs
      .map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          email: String(data.email ?? doc.id),
          addedBy: String(data.addedBy ?? ""),
          addedAt: data.addedAt?.toDate?.()?.toISOString?.() ?? null,
        };
      })
      // Bootstrap admins are listed above from config; drop stored copies so
      // the same account never appears twice.
      .filter((admin) => !isBootstrapAdminEmail(admin.email)),
  ];

  return NextResponse.json({ admins });
});

export const POST = withAdminRoute(async (req, { email: addedBy }) => {
  const { email } = await parseJsonBody(req, createAdminSchema);

  await getAdminDb().collection("admins").doc(email).set({
    email,
    addedBy,
    addedAt: FieldValue.serverTimestamp(),
  });

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { email } = parseQuery(req, adminEmailQuerySchema);

  if (isBootstrapAdminEmail(email)) {
    throw forbidden("Bootstrap admin accounts cannot be removed");
  }

  await getAdminDb().collection("admins").doc(email).delete();

  return NextResponse.json({ ok: true });
});
