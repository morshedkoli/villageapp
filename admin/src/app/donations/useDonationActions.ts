"use client";

import { useCallback, useState } from "react";
import { apiClient, errorMessage } from "@/lib/api-client";
import type { Donation } from "@/lib/models";

export interface CreateDonationValues {
  userId: string;
  amount: string;
  paymentTarget: string;
  senderNumber: string;
  transactionId: string;
  status: "Pending" | "Approved";
}

export const emptyDonationForm: CreateDonationValues = {
  userId: "",
  amount: "",
  paymentTarget: "cash",
  senderNumber: "",
  transactionId: "",
  status: "Approved",
};

/**
 * Every write the donations page performs. Kept out of the page component so
 * the JSX stays presentational and the approve/reject/bulk flows share one
 * error and in-flight state.
 */
export function useDonationActions() {
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [actionError, setActionError] = useState("");
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState("");

  const approve = useCallback(
    async (id: string) => {
      setActionLoading(id);
      setActionError("");
      try {
        // The status change fires `onDonationApprovedNotifyAll`, which writes
        // the feed entry and the push. Sending one from here too announced
        // every approval twice.
        await apiClient.patch("/api/donations", { id, action: "approve" });
      } catch (err) {
        setActionError(errorMessage(err, "Failed to approve donation"));
        console.error("Failed to approve donation:", err);
      } finally {
        setActionLoading(null);
      }
    },
    []
  );

  const reject = useCallback(async (id: string) => {
    setActionLoading(id);
    setActionError("");
    try {
      await apiClient.patch("/api/donations", { id, action: "reject" });
    } catch (err) {
      setActionError(errorMessage(err, "Failed to reject donation"));
      console.error("Failed to reject donation:", err);
    } finally {
      setActionLoading(null);
    }
  }, []);

  /**
   * Approves each selected donation independently: one failure must not stop
   * the rest, so failures are collected and reported after the run.
   */
  const bulkApprove = useCallback(async (toApprove: Donation[]) => {
    if (toApprove.length === 0) return;

    setActionError("");
    let failureCount = 0;

    for (const donation of toApprove) {
      try {
        // Each approval announces itself through
        // `onDonationApprovedNotifyAll`; no summary push from here.
        await apiClient.patch("/api/donations", {
          id: donation.id,
          action: "approve",
        });
      } catch (err) {
        failureCount++;
        console.error(`Failed to approve donation ${donation.id}:`, err);
      }
    }

    if (failureCount > 0) {
      setActionError(
        `${failureCount} of ${toApprove.length} donations could not be approved.`
      );
    }
  }, []);

  const create = useCallback(async (form: CreateDonationValues) => {
    const amount = Number(form.amount);

    if (!form.userId) {
      setCreateError("Please select a citizen.");
      return false;
    }
    if (!Number.isFinite(amount) || amount <= 0) {
      setCreateError("Enter a valid amount greater than zero.");
      return false;
    }

    setCreateLoading(true);
    setCreateError("");
    try {
      await apiClient.post("/api/donations", { ...form, amount });
      return true;
    } catch (err) {
      setCreateError(errorMessage(err, "Failed to add donation"));
      return false;
    } finally {
      setCreateLoading(false);
    }
  }, []);

  return {
    actionLoading,
    actionError,
    createLoading,
    createError,
    setCreateError,
    approve,
    reject,
    bulkApprove,
    create,
  };
}
