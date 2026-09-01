"use client";

import { useCallback, useState } from "react";
import { apiClient, errorMessage } from "@/lib/api-client";
import { sendPushNotification } from "@/lib/push";
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

function donationAnnouncement(donorName: string, amount: number) {
  return {
    title: "নতুন অনুদান",
    body: `${donorName} ৳${amount} অনুদান দিয়েছেন`,
    type: "donation",
  };
}

/**
 * Every write the donations page performs. Kept out of the page component so
 * the JSX stays presentational and the approve/reject/bulk flows share one
 * error and in-flight state.
 */
export function useDonationActions(donations: Donation[]) {
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [actionError, setActionError] = useState("");
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState("");

  const approve = useCallback(
    async (id: string) => {
      setActionLoading(id);
      setActionError("");
      try {
        await apiClient.patch("/api/donations", { id, action: "approve" });

        const donation = donations.find((d) => d.id === id);
        if (donation) {
          await sendPushNotification(
            donationAnnouncement(donation.donorName, donation.amount)
          );
        }
      } catch (err) {
        setActionError(errorMessage(err, "Failed to approve donation"));
        console.error("Failed to approve donation:", err);
      } finally {
        setActionLoading(null);
      }
    },
    [donations]
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
    let successCount = 0;
    let totalApproved = 0;
    let failureCount = 0;

    for (const donation of toApprove) {
      try {
        await apiClient.patch("/api/donations", {
          id: donation.id,
          action: "approve",
        });
        successCount++;
        totalApproved += donation.amount;
      } catch (err) {
        failureCount++;
        console.error(`Failed to approve donation ${donation.id}:`, err);
      }
    }

    if (successCount > 0) {
      await sendPushNotification({
        title: "নতুন অনুদান",
        body: `${successCount}টি অনুদান অনুমোদিত হয়েছে — মোট ৳${totalApproved}`,
        type: "donation",
      });
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
