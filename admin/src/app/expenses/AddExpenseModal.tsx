"use client";

import React from "react";
import { Check } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import {
  SelectField,
  TextAreaField,
  TextField,
} from "@/components/TextField";
import { errorTextClass, primaryButtonClass } from "@/components/form-controls";
import type { DevelopmentProject } from "@/lib/models";
import { expenseCategoryOptions, type ExpenseFormValues } from "./expense-ui";

const PROJECT_DATALIST_ID = "expense-project-options";

interface AddExpenseModalProps {
  open: boolean;
  form: ExpenseFormValues;
  onChange: (patch: Partial<ExpenseFormValues>) => void;
  onSubmit: (event: React.FormEvent) => void;
  onClose: () => void;
  projects: DevelopmentProject[];
  loading: boolean;
  error: string;
}

export function AddExpenseModal({
  open,
  form,
  onChange,
  onSubmit,
  onClose,
  projects,
  loading,
  error,
}: AddExpenseModalProps) {
  return (
    <FormModal open={open} title="Add Expense" onClose={onClose} size="md">
      <form onSubmit={onSubmit} className="space-y-5">
        {/* Free text, with existing projects offered as suggestions — expenses
            may also be logged against one-off titles. */}
        <TextField
          label="Project or Expense Title"
          value={form.project}
          onChange={(project) => onChange({ project })}
          placeholder="e.g. Road Repair, School Materials"
          list={PROJECT_DATALIST_ID}
        >
          <datalist id={PROJECT_DATALIST_ID}>
            {projects.map((project) => (
              <option key={project.id} value={project.title} />
            ))}
          </datalist>
        </TextField>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <SelectField
            label="Category"
            value={form.category}
            onChange={(category) => onChange({ category })}
            options={expenseCategoryOptions}
          />
          <TextField
            label="Amount"
            type="number"
            min="1"
            step="1"
            value={form.amount}
            onChange={(amount) => onChange({ amount })}
            placeholder="5000"
          />
        </div>

        <TextAreaField
          label="Notes"
          value={form.notes}
          onChange={(notes) => onChange({ notes })}
          rows={4}
          placeholder="Optional details about this expense"
        />

        {error && <p className={errorTextClass}>{error}</p>}

        <div className="flex justify-end">
          <button type="submit" disabled={loading} className={primaryButtonClass}>
            {loading ? (
              "Saving..."
            ) : (
              <>
                <Check className="w-4 h-4" />
                Save Expense
              </>
            )}
          </button>
        </div>
      </form>
    </FormModal>
  );
}
