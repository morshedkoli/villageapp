"use client";

import { AlertTriangle, CheckCircle2, ShieldCheck } from "lucide-react";
import { EmptyState } from "@/components/EmptyState";
import { StatusBadge } from "@/components/StatusBadge";
import { tableHeadCellClass } from "@/components/form-controls";
import { formatDate } from "@/lib/utils";
import type { ProblemReport } from "@/lib/models";
import { nextProblemStep, type ProblemStatus } from "./problem-form";

interface ProblemTableProps {
  problems: ProblemReport[];
  onView: (problem: ProblemReport) => void;
  onAdvance: (problem: ProblemReport, status: ProblemStatus) => void;
}

/** Icon for the moderation step a problem can be advanced to. */
function AdvanceIcon({ status }: { status: ProblemStatus }) {
  return status === "Approved" ? (
    <ShieldCheck className="w-4 h-4" />
  ) : (
    <CheckCircle2 className="w-4 h-4" />
  );
}

export function ProblemTable({
  problems,
  onView,
  onAdvance,
}: ProblemTableProps) {
  if (problems.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-border overflow-hidden">
        <EmptyState
          icon={AlertTriangle}
          title="No problems reported"
          description="All reported village problems will appear here for moderation."
        />
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl border border-border overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border bg-background/50">
              <th className={tableHeadCellClass}>Problem</th>
              <th className={tableHeadCellClass}>Location</th>
              <th className={tableHeadCellClass}>Status</th>
              <th className={tableHeadCellClass}>Reported By</th>
              <th className={tableHeadCellClass}>Date</th>
              <th className={`${tableHeadCellClass} text-right`}>Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {problems.map((problem) => {
              const step = nextProblemStep(problem.status);
              return (
                <tr
                  key={problem.id}
                  className="hover:bg-surface-hover/50 transition-colors cursor-pointer"
                  onClick={() => onView(problem)}
                >
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      {problem.photoUrl ? (
                        <img
                          src={problem.photoUrl}
                          alt=""
                          className="w-10 h-10 rounded-xl object-cover shrink-0"
                        />
                      ) : (
                        <div className="w-10 h-10 rounded-xl bg-background flex items-center justify-center shrink-0">
                          <AlertTriangle className="w-5 h-5 text-text-muted" />
                        </div>
                      )}
                      <p className="text-sm font-medium text-text-primary">
                        {problem.title}
                      </p>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-sm text-text-secondary">
                    {problem.location || "—"}
                  </td>
                  <td className="px-5 py-4">
                    <StatusBadge status={problem.status} />
                  </td>
                  <td className="px-5 py-4 text-sm text-text-secondary">
                    {problem.reportedByName}
                  </td>
                  <td className="px-5 py-4 text-sm text-text-muted">
                    {formatDate(problem.createdAt)}
                  </td>
                  <td className="px-5 py-4">
                    {/* The row itself opens the details modal. */}
                    <div
                      className="flex items-center justify-end gap-1"
                      onClick={(e) => e.stopPropagation()}
                    >
                      {step && (
                        <button
                          onClick={() => onAdvance(problem, step.status)}
                          className={`p-2 rounded-lg text-text-muted transition-colors ${
                            step.status === "Approved"
                              ? "hover:bg-info-light hover:text-info"
                              : "hover:bg-success-light hover:text-success"
                          }`}
                          title={step.label}
                        >
                          <AdvanceIcon status={step.status} />
                        </button>
                      )}
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
