"use client";

import React, { useMemo, useState } from "react";
import { Plus } from "lucide-react";
import { useDonations, usePaymentAccounts, useUsers } from "@/lib/hooks";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import { SegmentedControl } from "@/components/SegmentedControl";
import { formatBDT } from "@/lib/utils";
import { AddDonationModal, type SelectOption } from "./AddDonationModal";
import { AllDonationsTable } from "./AllDonationsTable";
import { DonationSummary } from "./DonationSummary";
import { DonationTrendChart } from "./DonationTrendChart";
import { PendingDonationsTable } from "./PendingDonationsTable";
import {
  FILTER_PERIODS,
  STATUS_FILTERS,
  matchesPeriod,
  monthlyApprovedTotals,
  periodLabel,
  summarizeDonations,
  type FilterPeriod,
  type StatusFilter,
} from "./donation-ui";
import {
  emptyDonationForm,
  useDonationActions,
  type CreateDonationValues,
} from "./useDonationActions";

export default function DonationsPage() {
  const { data: donations, loading } = useDonations();
  const { data: paymentAccounts } = usePaymentAccounts();
  const { data: users, loading: usersLoading } = useUsers();

  const [filter, setFilter] = useState<FilterPeriod>("all");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");
  const [approveId, setApproveId] = useState<string | null>(null);
  const [rejectId, setRejectId] = useState<string | null>(null);
  const [bulkApproveOpen, setBulkApproveOpen] = useState(false);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [form, setForm] = useState<CreateDonationValues>(emptyDonationForm);

  const actions = useDonationActions(donations);

  const receivingOptions = useMemo<SelectOption[]>(
    () => [
      { value: "cash", label: "Cash" },
      ...paymentAccounts.map((account) => ({
        value: account.id,
        label: [
          account.type ? account.type.toUpperCase() : "Account",
          account.number,
          account.name,
        ]
          .filter(Boolean)
          .join(" • "),
      })),
    ],
    [paymentAccounts]
  );

  const userOptions = useMemo<SelectOption[]>(
    () =>
      users.map((user) => ({
        value: user.id,
        label: [user.name, user.phone].filter(Boolean).join(" • "),
      })),
    [users]
  );

  const filtered = useMemo(() => {
    const now = new Date();
    return donations.filter(
      (donation) =>
        (statusFilter === "all" || donation.status === statusFilter) &&
        matchesPeriod(donation, filter, now)
    );
  }, [donations, filter, statusFilter]);

  const monthlyData = useMemo(
    () => monthlyApprovedTotals(donations),
    [donations]
  );

  const totals = useMemo(() => summarizeDonations(donations), [donations]);

  const filteredPending = filtered.filter((d) => d.status === "Pending");
  const selectedPending = totals.pending.filter((d) => selectedIds.has(d.id));
  const selectedAmount = selectedPending.reduce((sum, d) => sum + d.amount, 0);
  const allPendingSelected =
    totals.pending.length > 0 &&
    totals.pending.every((d) => selectedIds.has(d.id));

  const toggleSelect = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const toggleSelectAll = () => {
    setSelectedIds(
      allPendingSelected ? new Set() : new Set(totals.pending.map((d) => d.id))
    );
  };

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setForm(emptyDonationForm);
    actions.setCreateError("");
  };

  const handleCreate = async (event: React.FormEvent) => {
    event.preventDefault();
    if (await actions.create(form)) {
      closeCreateModal();
    }
  };

  const handleBulkApprove = async () => {
    await actions.bulkApprove(selectedPending);
    setSelectedIds(new Set());
    setBulkApproveOpen(false);
  };

  const donationById = (id: string | null) =>
    id ? donations.find((d) => d.id === id) : undefined;

  if (loading) return <LoadingSkeleton />;

  const totalAmount = filtered.reduce((sum, d) => sum + d.amount, 0);
  const approveTarget = donationById(approveId);
  const rejectTarget = donationById(rejectId);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-text-primary">
            Donations
            {totals.pendingCount > 0 && (
              <span className="ml-2 inline-flex items-center justify-center px-2.5 py-0.5 rounded-full text-xs font-bold bg-warning-light text-warning">
                {totals.pendingCount} pending
              </span>
            )}
          </h1>
          <p className="text-sm text-text-secondary mt-1">
            {filtered.length} donations &middot; Total: {formatBDT(totalAmount)}
          </p>
        </div>
        <div className="flex items-center gap-2 flex-wrap">
          <button
            onClick={() => setShowCreateModal(true)}
            className="flex items-center gap-2 px-4 py-2 text-sm font-semibold rounded-xl bg-primary text-white hover:bg-primary-dark transition-colors"
          >
            <Plus className="w-4 h-4" />
            Add Donation
          </button>
          <SegmentedControl
            options={STATUS_FILTERS}
            value={statusFilter}
            onChange={setStatusFilter}
            labelFor={(status) => (status === "all" ? "All Status" : status)}
          />
          <SegmentedControl
            options={FILTER_PERIODS}
            value={filter}
            onChange={setFilter}
            labelFor={periodLabel}
          />
        </div>
      </div>

      {actions.actionError && (
        <div className="bg-danger-light border border-danger/20 text-danger rounded-xl px-4 py-3 text-sm animate-fade-in">
          {actions.actionError}
        </div>
      )}

      <DonationSummary totals={totals} />

      {filteredPending.length > 0 && statusFilter === "all" && (
        <PendingDonationsTable
          donations={filteredPending}
          pendingAmount={totals.pendingAmount}
          selectedIds={selectedIds}
          selectedAmount={selectedAmount}
          allSelected={allPendingSelected}
          actionLoading={actions.actionLoading}
          onToggle={toggleSelect}
          onToggleAll={toggleSelectAll}
          onApprove={setApproveId}
          onReject={setRejectId}
          onBulkApprove={() => setBulkApproveOpen(true)}
        />
      )}

      {monthlyData.length > 0 && <DonationTrendChart data={monthlyData} />}

      <AllDonationsTable
        donations={filtered}
        actionLoading={actions.actionLoading}
        filtersApplied={filter !== "all" || statusFilter !== "all"}
        onApprove={setApproveId}
        onReject={setRejectId}
      />

      <ConfirmDialog
        open={approveId !== null}
        title="Approve Donation"
        message={`Are you sure you want to approve this donation? This will add ${formatBDT(
          approveTarget?.amount ?? 0
        )} from "${approveTarget?.donorName ?? ""}" to the village fund.`}
        variant="warning"
        confirmLabel="Approve"
        loadingLabel="Approving..."
        onConfirm={async () => {
          if (approveId) await actions.approve(approveId);
          setApproveId(null);
        }}
        onCancel={() => setApproveId(null)}
      />

      <ConfirmDialog
        open={rejectId !== null}
        title="Reject Donation"
        message={`Are you sure you want to reject the donation of ${formatBDT(
          rejectTarget?.amount ?? 0
        )} from "${
          rejectTarget?.donorName ?? ""
        }"? This donation will be marked as rejected.`}
        variant="danger"
        confirmLabel="Reject"
        loadingLabel="Rejecting..."
        onConfirm={async () => {
          if (rejectId) await actions.reject(rejectId);
          setRejectId(null);
        }}
        onCancel={() => setRejectId(null)}
      />

      <ConfirmDialog
        open={bulkApproveOpen}
        title="Bulk Approve Donations"
        message={`Are you sure you want to approve ${selectedIds.size} donation(s) totaling ${formatBDT(
          selectedAmount
        )}? This will add the full amount to the village fund.`}
        variant="warning"
        confirmLabel={`Approve ${selectedIds.size} Donations`}
        loadingLabel="Approving..."
        onConfirm={handleBulkApprove}
        onCancel={() => setBulkApproveOpen(false)}
      />

      <AddDonationModal
        open={showCreateModal}
        form={form}
        onChange={(patch) => setForm((prev) => ({ ...prev, ...patch }))}
        onSubmit={handleCreate}
        onClose={closeCreateModal}
        userOptions={userOptions}
        usersLoading={usersLoading}
        receivingOptions={receivingOptions}
        loading={actions.createLoading}
        error={actions.createError}
      />
    </div>
  );
}
