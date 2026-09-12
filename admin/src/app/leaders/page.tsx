"use client";

import React, { useState } from "react";
import { Plus } from "lucide-react";
import { useLeaders } from "@/lib/hooks";
import { apiClient, errorMessage } from "@/lib/api-client";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import type { Leader } from "@/lib/models";
import { LeaderEditorModal } from "./LeaderEditorModal";
import { LeaderTable } from "./LeaderTable";
import {
  emptyLeaderForm,
  leaderRequestBody,
  leaderToForm,
  validateLeaderForm,
  type LeaderFormValues,
} from "./leader-form";

export default function LeadersPage() {
  const { data: leaders, loading } = useLeaders();
  const [editorOpen, setEditorOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState<LeaderFormValues>(emptyLeaderForm);
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState("");
  const [actionError, setActionError] = useState("");
  const [deleteTarget, setDeleteTarget] = useState<Leader | null>(null);

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyLeaderForm);
    setFormError("");
    setEditorOpen(true);
  };

  const openEdit = (leader: Leader) => {
    setEditingId(leader.id);
    setForm(leaderToForm(leader));
    setFormError("");
    setEditorOpen(true);
  };

  const closeEditor = () => {
    setEditorOpen(false);
    setEditingId(null);
    setForm(emptyLeaderForm);
    setFormError("");
  };

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();

    const validationError = validateLeaderForm(form);
    if (validationError) {
      setFormError(validationError);
      return;
    }

    setSaving(true);
    setFormError("");
    try {
      const body = leaderRequestBody(form);
      if (editingId) {
        await apiClient.patch("/api/leaders", { id: editingId, ...body });
      } else {
        await apiClient.post("/api/leaders", body);
      }
      closeEditor();
    } catch (err: unknown) {
      setFormError(errorMessage(err, "Failed to save committee member"));
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (leader: Leader) => {
    setActionError("");
    try {
      await apiClient.delete("/api/leaders", { id: leader.id });
      setDeleteTarget(null);
    } catch (err: unknown) {
      setActionError(errorMessage(err, "Failed to remove committee member"));
    }
  };

  if (loading) return <LoadingSkeleton />;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-text-primary">Committee</h1>
          <p className="text-sm text-text-secondary mt-1">
            {leaders.length} members shown on the app&apos;s Leaders screen
          </p>
        </div>
        <button
          onClick={openCreate}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-all"
        >
          <Plus className="w-4 h-4" />
          Add Member
        </button>
      </div>

      {actionError && (
        <div className="bg-danger-light border border-danger/20 text-danger rounded-xl px-4 py-3 text-sm">
          {actionError}
        </div>
      )}

      <LeaderTable
        leaders={leaders}
        onEdit={openEdit}
        onDelete={setDeleteTarget}
      />

      <LeaderEditorModal
        open={editorOpen}
        editing={editingId !== null}
        form={form}
        onChange={(patch) => setForm((prev) => ({ ...prev, ...patch }))}
        onSubmit={handleSubmit}
        onClose={closeEditor}
        loading={saving}
        error={formError}
      />

      <ConfirmDialog
        open={deleteTarget !== null}
        title="Remove Committee Member"
        message={`Remove ${deleteTarget?.name ?? "this member"} from the committee? They will disappear from the app's Leaders screen.`}
        confirmLabel="Remove"
        loadingLabel="Removing..."
        onCancel={() => setDeleteTarget(null)}
        onConfirm={async () => {
          if (deleteTarget) await handleDelete(deleteTarget);
        }}
      />
    </div>
  );
}
