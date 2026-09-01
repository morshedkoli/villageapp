import { NextResponse } from "next/server";
import { FieldValue, Transaction } from "firebase-admin/firestore";
import type {
  DocumentReference,
  Firestore,
} from "firebase-admin/firestore";
import { getAdminDb } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody, parseQuery } from "@/lib/api-handler";
import { badRequest, notFound } from "@/lib/api-error";
import { villageRef } from "@/lib/village";
import {
  createDonationSchema,
  donationActionSchema,
  idQuerySchema,
} from "@/lib/schemas";

interface PaymentTargetDetails {
  paymentMethod: string;
  receivedAccountId: string;
  receivedAccountLabel: string;
}

/**
 * Resolves the free-form `paymentTarget` ("cash" or a payment account id) into
 * the denormalized fields stored on the donation.
 */
function resolvePaymentTarget(
  paymentTarget: string,
  villageData: Record<string, unknown> | undefined
): PaymentTargetDetails {
  if (paymentTarget === "cash") {
    return {
      paymentMethod: "Cash",
      receivedAccountId: "",
      receivedAccountLabel: "Cash",
    };
  }

  const accounts = Array.isArray(villageData?.paymentAccounts)
    ? (villageData.paymentAccounts as Array<Record<string, unknown>>)
    : [];

  const account = accounts.find(
    (entry) => String(entry.id ?? "") === paymentTarget
  );

  if (!account) {
    throw badRequest("Selected receiving account is no longer available");
  }

  const accountType = String(account.type ?? "").trim();
  const accountNumber = String(account.number ?? "").trim();
  const holderName = String(account.name ?? "").trim();

  return {
    paymentMethod: accountType || "Account",
    receivedAccountId: String(account.id ?? ""),
    receivedAccountLabel: [accountType, accountNumber, holderName]
      .filter(Boolean)
      .join(" • "),
  };
}

/**
 * Records an approved donation: credits the village fund, writes the matching
 * ledger row (tagged with `donationId` so it can be reversed) and announces it.
 */
function applyApproval(
  tx: Transaction,
  db: Firestore,
  params: {
    donationId: string;
    amount: number;
    donorName: string;
    adminEmail: string;
  }
) {
  const { donationId, amount, donorName, adminEmail } = params;

  tx.set(
    villageRef(db),
    { totalFundCollected: FieldValue.increment(amount) },
    { merge: true }
  );

  tx.set(db.collection("fund_transactions").doc(), {
    type: "donation",
    donationId,
    amount,
    reference: donorName,
    createdAt: FieldValue.serverTimestamp(),
    addedBy: adminEmail,
  });

  tx.set(db.collection("notifications").doc(), {
    title: "নতুন অনুদান",
    body: `${donorName} ৳${amount} অনুদান দিয়েছেন`,
    type: "donation",
    source: "admin",
    createdAt: FieldValue.serverTimestamp(),
  });
}

/**
 * Undoes {@link applyApproval}: debits the fund by the donation amount and
 * removes its ledger rows. Used when an approved donation is rejected or
 * deleted — without this the village fund total drifts upward permanently.
 *
 * Ledger rows are read through the transaction so a concurrent approval or
 * delete conflicts instead of double-reversing. Rows written before
 * `donationId` existed carry no link back to the donation, so there is nothing
 * to delete for them — the fund correction still applies.
 */
async function reverseApproval(
  tx: Transaction,
  db: Firestore,
  donationRef: DocumentReference,
  amount: number
): Promise<void> {
  const ledgerRows = await tx.get(
    // Single-field equality only: Firestore auto-indexes it, so this needs no
    // composite index deployment.
    db.collection("fund_transactions").where("donationId", "==", donationRef.id)
  );

  if (amount > 0) {
    tx.set(
      villageRef(db),
      { totalFundCollected: FieldValue.increment(-amount) },
      { merge: true }
    );
  }

  for (const row of ledgerRows.docs) {
    tx.delete(row.ref);
  }
}

export const POST = withAdminRoute(async (req, { email }) => {
  const input = await parseJsonBody(req, createDonationSchema);
  const db = getAdminDb();
  const donationRef = db.collection("donations").doc();
  const donorRef = db.collection("users").doc(input.userId);

  await db.runTransaction(async (tx) => {
    // Both reads happen inside the transaction so a donor deleted (or a
    // payment account removed) mid-request aborts instead of writing a
    // donation that points at something that no longer exists.
    const [donorSnap, villageSnap] = await Promise.all([
      tx.get(donorRef),
      tx.get(villageRef(db)),
    ]);

    if (!donorSnap.exists) {
      throw badRequest("Selected user does not exist");
    }

    const donorName = String(donorSnap.data()?.name ?? "").trim();
    if (!donorName) {
      throw badRequest("Selected user is missing a name");
    }

    const target = resolvePaymentTarget(input.paymentTarget, villageSnap.data());

    tx.set(donationRef, {
      donorName,
      amount: input.amount,
      ...target,
      senderNumber: input.senderNumber,
      transactionId: input.transactionId,
      userId: input.userId,
      status: input.status,
      createdAt: FieldValue.serverTimestamp(),
      addedBy: email,
      source: "admin",
    });

    if (input.status === "Approved") {
      applyApproval(tx, db, {
        donationId: donationRef.id,
        amount: input.amount,
        donorName,
        adminEmail: email,
      });
    }
  });

  return NextResponse.json({ ok: true });
});

export const DELETE = withAdminRoute(async (req) => {
  const { id } = parseQuery(req, idQuerySchema);
  const db = getAdminDb();
  const donationRef = db.collection("donations").doc(id);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(donationRef);
    if (!snap.exists) {
      throw notFound("Donation not found");
    }

    const data = snap.data();
    // Deleting an approved donation must give the money back, or the village
    // fund total stays inflated with no record explaining it.
    if (data?.status === "Approved") {
      await reverseApproval(
        tx,
        db,
        donationRef,
        Math.max(0, Math.round(Number(data.amount ?? 0)))
      );
    }

    tx.delete(donationRef);
  });

  return NextResponse.json({ ok: true });
});

export const PATCH = withAdminRoute(async (req, { email }) => {
  const { id, action } = await parseJsonBody(req, donationActionSchema);
  const db = getAdminDb();
  const donationRef = db.collection("donations").doc(id);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(donationRef);
    if (!snap.exists) {
      throw notFound("Donation not found");
    }

    const data = snap.data() ?? {};
    const status = String(data.status ?? "Pending");
    const amount = Math.max(0, Math.round(Number(data.amount ?? 0)));
    const donorName = String(data.donorName ?? "Anonymous");

    if (action === "approve") {
      if (status === "Approved") return;

      tx.update(donationRef, {
        status: "Approved",
        approvedBy: email,
        approvedAt: FieldValue.serverTimestamp(),
      });

      applyApproval(tx, db, {
        donationId: donationRef.id,
        amount,
        donorName,
        adminEmail: email,
      });
      return;
    }

    if (status === "Rejected") return;

    // Rejecting a donation that was already approved has to unwind the credit.
    if (status === "Approved") {
      await reverseApproval(tx, db, donationRef, amount);
    }

    tx.update(donationRef, {
      status: "Rejected",
      rejectedBy: email,
      rejectedAt: FieldValue.serverTimestamp(),
    });
  });

  return NextResponse.json({ ok: true });
});
