"use client";

import { CheckCircle, HandCoins, XCircle } from "lucide-react";
import { EmptyState } from "@/components/EmptyState";
import { StatusBadge } from "@/components/StatusBadge";
import { tableHeadCellClass } from "@/components/form-controls";
import { formatBDT, formatDate } from "@/lib/utils";
import type { Donation } from "@/lib/models";
import { paymentMethodStyle } from "./donation-ui";

const amountToneByStatus: Record<Donation["status"], string> = {
  Approved: "text-success",
  Pending: "text-warning",
  Rejected: "text-text-muted",
};

interface AllDonationsTableProps {
  donations: Donation[];
  actionLoading: string | null;
  filtersApplied: boolean;
  onApprove: (id: string) => void;
  onReject: (id: string) => void;
}

export function AllDonationsTable({
  donations,
  actionLoading,
  filtersApplied,
  onApprove,
  onReject,
}: AllDonationsTableProps) {
  return (
    <div className="bg-white rounded-2xl border border-border overflow-hidden">
      <div className="px-5 py-4 border-b border-border">
        <h3 className="text-sm font-semibold text-text-primary">
          All Donations
        </h3>
      </div>
      {donations.length === 0 ? (
        <EmptyState
          icon={HandCoins}
          title="No donations found"
          description={
            filtersApplied
              ? "Try a different filter."
              : "Donations will appear here once received."
          }
        />
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-border bg-background/50">
                <th className={tableHeadCellClass}>Donor</th>
                <th className={tableHeadCellClass}>Amount</th>
                <th className={tableHeadCellClass}>Method</th>
                <th className={tableHeadCellClass}>Transaction</th>
                <th className={tableHeadCellClass}>Status</th>
                <th className={tableHeadCellClass}>Date</th>
                <th className={`${tableHeadCellClass} text-right`}>Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border-light">
              {donations.map((donation) => {
                const isLoading = actionLoading === donation.id;
                return (
                  <tr
                    key={donation.id}
                    className="hover:bg-surface-hover/50 transition-colors"
                  >
                    <td className="px-5 py-4">
                      <p className="text-sm font-medium text-text-primary">
                        {donation.donorName}
                      </p>
                      {donation.senderNumber && (
                        <p className="text-xs text-text-muted mt-0.5">
                          {donation.senderNumber}
                        </p>
                      )}
                    </td>
                    <td className="px-5 py-4">
                      <span
                        className={`text-sm font-semibold ${
                          amountToneByStatus[donation.status]
                        }`}
                      >
                        {formatBDT(donation.amount)}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <span
                        className={`inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold ${paymentMethodStyle(
                          donation.paymentMethod
                        )}`}
                      >
                        {donation.paymentMethod}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <p className="text-xs text-text-primary font-mono">
                        {donation.transactionId || "—"}
                      </p>
                    </td>
                    <td className="px-5 py-4">
                      <StatusBadge status={donation.status} />
                    </td>
                    <td className="px-5 py-4 text-sm text-text-muted">
                      {formatDate(donation.createdAt)}
                    </td>
                    <td className="px-5 py-4">
                      <div className="flex justify-end gap-1">
                        {donation.status === "Pending" && (
                          <>
                            <button
                              onClick={() => onApprove(donation.id)}
                              disabled={isLoading}
                              className="p-2 rounded-lg hover:bg-success-light text-text-muted hover:text-success transition-colors disabled:opacity-50"
                              title="Approve"
                            >
                              <CheckCircle className="w-4 h-4" />
                            </button>
                            <button
                              onClick={() => onReject(donation.id)}
                              disabled={isLoading}
                              className="p-2 rounded-lg hover:bg-danger-light text-text-muted hover:text-danger transition-colors disabled:opacity-50"
                              title="Reject"
                            >
                              <XCircle className="w-4 h-4" />
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
