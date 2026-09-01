"use client";

import React from "react";
import { Save } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import {
  SelectField,
  TextAreaField,
  TextField,
} from "@/components/TextField";
import { errorTextClass, primaryButtonClass } from "@/components/form-controls";
import {
  problemStatusOptions,
  type ProblemFormValues,
  type ProblemStatus,
} from "./problem-form";

interface AddProblemModalProps {
  open: boolean;
  form: ProblemFormValues;
  onChange: (patch: Partial<ProblemFormValues>) => void;
  onSubmit: (event: React.FormEvent) => void;
  onClose: () => void;
  loading: boolean;
  error: string;
}

export function AddProblemModal({
  open,
  form,
  onChange,
  onSubmit,
  onClose,
  loading,
  error,
}: AddProblemModalProps) {
  return (
    <FormModal open={open} title="Add Problem" onClose={onClose} size="md">
      <form onSubmit={onSubmit} className="space-y-5">
        <TextField
          label="Problem Title"
          value={form.title}
          onChange={(title) => onChange({ title })}
          placeholder="e.g. Road damage near school"
        />

        <TextAreaField
          label="Description"
          value={form.description}
          onChange={(description) => onChange({ description })}
          rows={4}
          placeholder="Describe the issue and why it needs attention"
        />

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Location"
            value={form.location}
            onChange={(location) => onChange({ location })}
            placeholder="e.g. North road, market area"
          />
          <SelectField<ProblemStatus>
            label="Status"
            value={form.status}
            onChange={(status) => onChange({ status })}
            options={problemStatusOptions}
          />
        </div>

        <TextField
          label="Photo URL"
          type="url"
          value={form.photoUrl}
          onChange={(photoUrl) => onChange({ photoUrl })}
          placeholder="https://example.com/photo.jpg"
        />

        {error && <p className={errorTextClass}>{error}</p>}

        <div className="flex justify-end">
          <button type="submit" disabled={loading} className={primaryButtonClass}>
            {loading ? (
              "Saving..."
            ) : (
              <>
                <Save className="w-4 h-4" />
                Save Problem
              </>
            )}
          </button>
        </div>
      </form>
    </FormModal>
  );
}
