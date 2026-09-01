"use client";

import { Save, X } from "lucide-react";
import type { PaymentAccount } from "@/lib/models";
import { accountTypeOptions, isAccountComplete } from "./account-types";

const editorFieldClass =
  "w-full px-4 py-3 rounded-xl border border-border bg-background text-text-primary focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all";

const editorLabelClass =
  "block text-sm font-semibold text-text-primary mb-2";

interface AccountEditorModalProps {
  account: PaymentAccount | null;
  isNew: boolean;
  saving: boolean;
  error: string;
  onChange: (field: keyof PaymentAccount, value: string) => void;
  onSave: () => void;
  onClose: () => void;
}

export function AccountEditorModal({
  account,
  isNew,
  saving,
  error,
  onChange,
  onSave,
  onClose,
}: AccountEditorModalProps) {
  if (!account) return null;

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-border px-6 py-4 flex items-center justify-between">
          <h3 className="text-lg font-semibold text-text-primary">
            {isNew ? "Add Account" : "Edit Account"}
          </h3>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-surface transition-all"
          >
            <X className="w-5 h-5 text-text-muted" />
          </button>
        </div>

        <div className="p-6 space-y-4">
          <div>
            <label className={editorLabelClass}>Account Type</label>
            <select
              value={account.type}
              onChange={(e) => onChange("type", e.target.value)}
              className={editorFieldClass}
            >
              {accountTypeOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className={editorLabelClass}>Account Number</label>
            <input
              type="text"
              value={account.number}
              onChange={(e) => onChange("number", e.target.value)}
              placeholder="e.g. 01XXXXXXXXX or IBAN"
              className={editorFieldClass}
            />
          </div>

          <div>
            <label className={editorLabelClass}>Account Holder Name</label>
            <input
              type="text"
              value={account.name}
              onChange={(e) => onChange("name", e.target.value)}
              placeholder="Full name of account holder"
              className={editorFieldClass}
            />
          </div>

          {error && (
            <div className="bg-red-50 border border-red-200 rounded-xl p-4">
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          <div className="flex gap-3 pt-4">
            <button
              onClick={onClose}
              className="flex-1 px-4 py-3 rounded-xl border border-border bg-white text-text-primary font-medium hover:bg-surface transition-all"
            >
              Cancel
            </button>
            <button
              onClick={onSave}
              disabled={saving || !isAccountComplete(account)}
              className="flex-1 px-4 py-3 rounded-xl bg-primary text-white font-medium hover:bg-primary/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {saving ? (
                "Saving..."
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Save Account
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
