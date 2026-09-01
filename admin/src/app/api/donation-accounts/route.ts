import { NextResponse } from "next/server";
import { getAdminDb } from "@/lib/firebase-admin";
import { withApiErrorHandling } from "@/lib/api-handler";
import { notFound } from "@/lib/api-error";
import { villageRef } from "@/lib/village";

export const dynamic = "force-dynamic";

interface PaymentAccount {
  id?: string;
  type?: string;
  number?: string;
  name?: string;
}

const TYPE_NAMES: Record<string, string> = {
  bkash: "bKash",
  nagad: "Nagad",
  bank: "Bank",
  rocket: "Rocket",
};

const TYPE_COLORS: Record<string, string> = {
  bkash: "#E2136E",
  nagad: "#FF6A00",
  bank: "#1E40AF",
  rocket: "#8B2FA0",
};

function getTypeName(type: string): string {
  return TYPE_NAMES[type.toLowerCase()] ?? type;
}

function getTypeColor(type: string): string {
  return TYPE_COLORS[type.toLowerCase()] ?? "#6B7280";
}

/**
 * GET /api/donation-accounts
 *
 * Public endpoint consumed by the Flutter client: the payment accounts the
 * village can receive donations on, with display metadata resolved server-side.
 */
export const GET = withApiErrorHandling(async () => {
  const villageDoc = await villageRef(getAdminDb()).get();
  if (!villageDoc.exists) {
    throw notFound("Village data not found");
  }

  const raw = villageDoc.data()?.paymentAccounts;
  const paymentAccounts: PaymentAccount[] = Array.isArray(raw) ? raw : [];

  // Half-configured accounts would render as blank rows in the app.
  const accounts = paymentAccounts
    .filter((account) => account.number?.trim() && account.name?.trim())
    .map((account) => ({
      id: account.id ?? "",
      type: account.type ?? "",
      typeName: getTypeName(account.type ?? ""),
      number: account.number ?? "",
      name: account.name ?? "",
      color: getTypeColor(account.type ?? ""),
    }));

  return NextResponse.json({
    success: true,
    accounts,
    count: accounts.length,
  });
});
