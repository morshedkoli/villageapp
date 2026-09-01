"use client";

import { CheckCheck, CheckCircle, Clock, XCircle } from "lucide-react";
import { formatBDT, formatDate } from "@/lib/utils";
import { tableHeadCellClass } from "@/components/form-controls";
import type { Donation } from "@/lib/models";
import { paymentMethodStyle } from "./donation-ui";

const checkboxClass =
  "w-4 h-4 rounded border-border-light text-success focus:ring-success/30 cursor-pointer accent-[#1F7A5A]";

interface PendingDonationsTableProps {
  donations: Donation[];
  pendingAmount: number;
  selectedIds: Set<string>;
  selectedAmount: number;
  allSelected: boolean;
  actionLoading: string | null;
  onToggle: (id: string) => void;
  onToggleAll: () => void;
  onApprove: (id: string) => void;
  onReject: (id: string) => void;
  onBulkApprove: () => void;
}

/** Review queue: the donations awaiting an approve/reject decision. */
export function PendingDonationsTable({
  donations,
  pendingAmount,
  selectedIds,
  selectedAmount,
  allSelected,
  actionLoading,
  onToggle,
  onToggleAll,
  onApprove,
  onReject,
  onBulkApprove,
}: PendingDonationsTableProps) {
  return (
    <div className="bg-white rounded-2xl border-2 border-warning/30 overflow-hidden animate-fade-in">
      <div className="px-5 py-4 bg-warning-light/50 border-b border-warning/20 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Clock className="w-5 h-5 text-warning" />
          <div>
            <h3 className="text-sm font-semibold text-text-primary">
              Pending Approval ({donations.length})
            </h3>
            <p className="text-xs text-text-muted">
              Total: {formatBDT(pendingAmount)} — Review and approve or reject
              donations
            </p>
          </div>
        </div>
        {selectedIds.size > 0 && (
          <button
            onClick={onBulkApprove}
            className="flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-xl bg-success text-white hover:bg-success/90 transition-colors"
          >
            <CheckCheck className="w-4 h-4" />
            Approve Selected ({selectedIds.size}) &middot;{" "}
            {formatBDT(selectedAmount)}
          </button>
        )}
      </div>
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border bg-background/50">
              <th className="px-5 py-3 text-left w-10">
                <input
                  type="checkbox"
                  checked={allSelected}
                  onChange={onToggleAll}
                  className={checkboxClass}
                />
              </th>
              <th className={tableHeadCellClass}>Donor</th>
              <th className={tableHeadCellClass}>Amount</th>
              <th className={tableHeadCellClass}>Method</th>
              <th className={tableHeadCellClass}>Transaction</th>
              <th className={tableHeadCellClass}>Date</th>
              <th className={`${tableHeadCellClass} text-right`}>Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {donations.map((donation) => {
              const isLoading = actionLoading === donation.id;
              const isSelected = selectedIds.has(donation.id);
              return (
                <tr
                  key={donation.id}
                  className={`transition-colors ${
                    isSelected
                      ? "bg-success-light/30"
                      : "hover:bg-surface-hover/50"
                  }`}
                >
                  <td className="px-5 py-3.5">
                    <input
                      type="checkbox"
                      checked={isSelected}
                      onChange={() => onToggle(donation.id)}
                      className={checkboxClass}
                    />
                  </td>
                  <td className="px-5 py-3.5">
                    <p className="text-sm font-medium text-text-primary">
                      {donation.donorName}
                    </p>
                    {donation.senderNumber && (
                      <p className="text-xs text-text-muted mt-0.5">
                        {donation.senderNumber}
                      </p>
                    )}
                  </td>
                  <td className="px-5 py-3.5">
                    <span className="text-sm font-semibold text-warning">
                      {formatBDT(donation.amount)}
                    </span>
                  </td>
                  <td className="px-5 py-3.5">
                    <span
                      className={`inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-semibold ${paymentMethodStyle(
                        donation.paymentMethod
                      )}`}
                    >
                      {donation.paymentMethod}
                    </span>
                  </td>
                  <td className="px-5 py-3.5">
                    <p className="text-xs text-text-primary font-mono">
                      {donation.transactionId || "—"}
                    </p>
                  </td>
                  <td className="px-5 py-3.5 text-sm text-text-muted">
                    {formatDate(donation.createdAt)}
                  </td>
                  <td className="px-5 py-3.5">
                    <div className="flex justify-end gap-1">
                      <button
                        onClick={() => onApprove(donation.id)}
                        disabled={isLoading}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-success-light text-success hover:bg-success hover:text-white text-xs font-semibold transition-colors disabled:opacity-50"
                        title="Approve"
                      >
                        <CheckCircle className="w-3.5 h-3.5" />
                        Approve
                      </button>
                      <button
                        onClick={() => onReject(donation.id)}
                        disabled={isLoading}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-danger-light text-danger hover:bg-danger hover:text-white text-xs font-semibold transition-colors disabled:opacity-50"
                        title="Reject"
                      >
                        <XCircle className="w-3.5 h-3.5" />
                        Reject
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
