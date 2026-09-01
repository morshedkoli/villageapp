import type { ProblemReport } from "@/lib/models";

export type ProblemStatus = ProblemReport["status"];

export interface ProblemFormValues {
  title: string;
  description: string;
  location: string;
  photoUrl: string;
  status: ProblemStatus;
}

export const emptyProblemForm: ProblemFormValues = {
  title: "",
  description: "",
  location: "",
  photoUrl: "",
  status: "Pending",
};

export const problemStatusOptions = [
  { value: "Pending", label: "Pending" },
  { value: "Approved", label: "Approved" },
  { value: "Completed", label: "Completed" },
];

/**
 * Mirrors the required fields of `createProblemSchema` so the admin sees the
 * problem before a round trip. The server remains the authority.
 */
export function validateProblemForm(form: ProblemFormValues): string | null {
  if (!form.title.trim()) return "Problem title is required.";
  if (!form.description.trim()) return "Problem description is required.";
  return null;
}

export interface ProblemAdvance {
  status: ProblemStatus;
  label: string;
}

/**
 * The single moderation step available from a given status: Pending problems
 * get approved, approved ones get completed, completed ones are done.
 */
export function nextProblemStep(status: ProblemStatus): ProblemAdvance | null {
  if (status === "Pending") return { status: "Approved", label: "Approve" };
  if (status === "Approved") return { status: "Completed", label: "Mark Complete" };
  return null;
}
