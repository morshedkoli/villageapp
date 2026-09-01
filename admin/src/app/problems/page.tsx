"use client";

import React, { useState } from "react";
import { Plus } from "lucide-react";
import { useProblems } from "@/lib/hooks";
import { apiClient, errorMessage } from "@/lib/api-client";
import { updateProblemStatus } from "@/lib/firestore-service";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import type { ProblemReport } from "@/lib/models";
import { AddProblemModal } from "./AddProblemModal";
import { ProblemDetailsModal } from "./ProblemDetailsModal";
import { ProblemTable } from "./ProblemTable";
import {
  emptyProblemForm,
  validateProblemForm,
  type ProblemFormValues,
  type ProblemStatus,
} from "./problem-form";

export default function ProblemsPage() {
  const { data: problems, loading } = useProblems();
  const [viewProblem, setViewProblem] = useState<ProblemReport | null>(null);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState("");
  const [form, setForm] = useState<ProblemFormValues>(emptyProblemForm);

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setForm(emptyProblemForm);
    setCreateError("");
  };

  const handleCreateProblem = async (event: React.FormEvent) => {
    event.preventDefault();

    const validationError = validateProblemForm(form);
    if (validationError) {
      setCreateError(validationError);
      return;
    }

    setCreateLoading(true);
    setCreateError("");
    try {
      await apiClient.post("/api/problems", form);
      closeCreateModal();
    } catch (err: unknown) {
      setCreateError(errorMessage(err, "Failed to add problem"));
    } finally {
      setCreateLoading(false);
    }
  };

  const advanceProblem = (problem: ProblemReport, status: ProblemStatus) => {
    void updateProblemStatus(problem.id, status);
  };

  if (loading) return <LoadingSkeleton />;

  const pending = problems.filter((p) => p.status === "Pending").length;
  const approved = problems.filter((p) => p.status === "Approved").length;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-text-primary">Problems</h1>
          <p className="text-sm text-text-secondary mt-1">
            {problems.length} reported &middot; {pending} pending &middot;{" "}
            {approved} approved
          </p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-all"
        >
          <Plus className="w-4 h-4" />
          Add Problem
        </button>
      </div>

      <ProblemTable
        problems={problems}
        onView={setViewProblem}
        onAdvance={advanceProblem}
      />

      <ProblemDetailsModal
        problem={viewProblem}
        onClose={() => setViewProblem(null)}
        onAdvance={advanceProblem}
      />

      <AddProblemModal
        open={showCreateModal}
        form={form}
        onChange={(patch) => setForm((prev) => ({ ...prev, ...patch }))}
        onSubmit={handleCreateProblem}
        onClose={closeCreateModal}
        loading={createLoading}
        error={createError}
      />
    </div>
  );
}
