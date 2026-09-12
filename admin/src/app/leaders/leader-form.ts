import type { Leader } from "@/lib/models";

export interface LeaderFormValues {
  name: string;
  designation: string;
  phone: string;
  email: string;
  photoUrl: string;
  description: string;
  priority: string;
}

export const emptyLeaderForm: LeaderFormValues = {
  name: "",
  designation: "",
  phone: "",
  email: "",
  photoUrl: "",
  description: "",
  priority: "0",
};

export function leaderToForm(leader: Leader): LeaderFormValues {
  return {
    name: leader.name,
    designation: leader.designation,
    phone: leader.phone,
    email: leader.email,
    photoUrl: leader.photoUrl,
    description: leader.description,
    priority: String(leader.priority),
  };
}

/** The shape the API expects: `priority` as a number, everything else trimmed. */
export function leaderRequestBody(form: LeaderFormValues) {
  return {
    name: form.name.trim(),
    designation: form.designation.trim(),
    phone: form.phone.trim(),
    email: form.email.trim(),
    photoUrl: form.photoUrl.trim(),
    description: form.description.trim(),
    priority: Number(form.priority) || 0,
  };
}

/**
 * Mirrors the required fields of `createLeaderSchema` so the admin sees the
 * problem before a round trip. The server remains the authority.
 */
export function validateLeaderForm(form: LeaderFormValues): string | null {
  if (!form.name.trim()) return "Name is required.";
  if (!form.designation.trim()) return "Designation is required.";
  const priority = Number(form.priority);
  if (!Number.isFinite(priority) || priority < 0) {
    return "Display order must be zero or greater.";
  }
  return null;
}
