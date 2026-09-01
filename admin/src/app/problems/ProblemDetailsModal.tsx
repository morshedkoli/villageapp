"use client";

import { Calendar, CheckCircle2, MapPin, ShieldCheck, User } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import { StatusBadge } from "@/components/StatusBadge";
import type { ProblemReport } from "@/lib/models";
import { nextProblemStep, type ProblemStatus } from "./problem-form";

function MetaRow({
  icon: Icon,
  value,
}: {
  icon: typeof MapPin;
  value: string;
}) {
  return (
    <div className="flex items-center gap-2 text-sm">
      <Icon className="w-4 h-4 text-text-muted" />
      <span className="text-text-secondary">{value}</span>
    </div>
  );
}

export function ProblemDetailsModal({
  problem,
  onClose,
  onAdvance,
}: {
  problem: ProblemReport | null;
  onClose: () => void;
  onAdvance: (problem: ProblemReport, status: ProblemStatus) => void;
}) {
  const step = problem ? nextProblemStep(problem.status) : null;

  return (
    <FormModal
      open={problem !== null}
      title="Problem Details"
      onClose={onClose}
      size="md"
    >
      {problem && (
        <div className="space-y-5">
          <div className="flex items-start justify-between">
            <div>
              <h3 className="text-lg font-semibold text-text-primary">
                {problem.title}
              </h3>
              <div className="mt-2">
                <StatusBadge status={problem.status} />
              </div>
            </div>
          </div>

          {problem.photoUrl && (
            <img
              src={problem.photoUrl}
              alt="Problem photo"
              className="w-full rounded-xl max-h-64 object-cover"
            />
          )}

          <p className="text-sm text-text-secondary leading-relaxed">
            {problem.description}
          </p>

          <div className="grid grid-cols-2 gap-4 p-4 bg-background rounded-xl">
            <MetaRow icon={MapPin} value={problem.location || "Not specified"} />
            <MetaRow icon={User} value={problem.reportedByName} />
            <MetaRow
              icon={Calendar}
              value={problem.createdAt.toLocaleString()}
            />
          </div>

          {step && (
            <div className="flex gap-2 pt-2 border-t border-border">
              <button
                onClick={() => {
                  onAdvance(problem, step.status);
                  onClose();
                }}
                className={`flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-xl text-white transition-colors ${
                  step.status === "Approved"
                    ? "bg-info hover:bg-info/90"
                    : "bg-success hover:bg-success/90"
                }`}
              >
                {step.status === "Approved" ? (
                  <ShieldCheck className="w-4 h-4" />
                ) : (
                  <CheckCircle2 className="w-4 h-4" />
                )}
                {step.label}
              </button>
            </div>
          )}
        </div>
      )}
    </FormModal>
  );
}
