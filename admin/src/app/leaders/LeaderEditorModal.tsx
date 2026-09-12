"use client";

import React from "react";
import { Save } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import { TextAreaField, TextField } from "@/components/TextField";
import { errorTextClass, primaryButtonClass } from "@/components/form-controls";
import type { LeaderFormValues } from "./leader-form";

interface LeaderEditorModalProps {
  open: boolean;
  editing: boolean;
  form: LeaderFormValues;
  onChange: (patch: Partial<LeaderFormValues>) => void;
  onSubmit: (event: React.FormEvent) => void;
  onClose: () => void;
  loading: boolean;
  error: string;
}

export function LeaderEditorModal({
  open,
  editing,
  form,
  onChange,
  onSubmit,
  onClose,
  loading,
  error,
}: LeaderEditorModalProps) {
  return (
    <FormModal
      open={open}
      title={editing ? "Edit Committee Member" : "Add Committee Member"}
      onClose={onClose}
      size="md"
    >
      <form onSubmit={onSubmit} className="space-y-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Name"
            value={form.name}
            onChange={(name) => onChange({ name })}
            placeholder="e.g. মোঃ আব্দুল কাদের"
          />
          <TextField
            label="Designation"
            value={form.designation}
            onChange={(designation) => onChange({ designation })}
            placeholder="e.g. গ্রাম সভাপতি"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Phone"
            value={form.phone}
            onChange={(phone) => onChange({ phone })}
            placeholder="01XXXXXXXXX"
          />
          <TextField
            label="Email"
            type="email"
            value={form.email}
            onChange={(email) => onChange({ email })}
            placeholder="optional"
          />
        </div>

        <TextField
          label="Photo URL"
          type="url"
          value={form.photoUrl}
          onChange={(photoUrl) => onChange({ photoUrl })}
          placeholder="https://example.com/photo.jpg"
        />

        <TextAreaField
          label="Description"
          value={form.description}
          onChange={(description) => onChange({ description })}
          rows={3}
          placeholder="Responsibilities shown under the name in the app"
        />

        <TextField
          label="Display Order"
          type="number"
          min="0"
          value={form.priority}
          onChange={(priority) => onChange({ priority })}
        >
          <p className="mt-1 text-[12px] text-text-muted">
            Lower numbers appear first on the app&apos;s Leaders screen.
          </p>
        </TextField>

        {error && <p className={errorTextClass}>{error}</p>}

        <div className="flex justify-end">
          <button type="submit" disabled={loading} className={primaryButtonClass}>
            {loading ? (
              "Saving..."
            ) : (
              <>
                <Save className="w-4 h-4" />
                {editing ? "Save Changes" : "Add Member"}
              </>
            )}
          </button>
        </div>
      </form>
    </FormModal>
  );
}
