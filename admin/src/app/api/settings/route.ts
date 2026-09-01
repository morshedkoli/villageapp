import { NextResponse } from "next/server";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody } from "@/lib/api-handler";
import { villageRef } from "@/lib/village";
import { updateSettingsSchema } from "@/lib/schemas";

export const PATCH = withAdminRoute(async (req) => {
  const input = await parseJsonBody(req, updateSettingsSchema);

  const updateData: Record<string, unknown> = {};
  if (input.name !== undefined) updateData.name = input.name;
  if (input.paymentAccounts !== undefined) {
    updateData.paymentAccounts = input.paymentAccounts;
  }

  await villageRef(getAdminDb()).set(updateData, { merge: true });

  return NextResponse.json({ ok: true });
});
