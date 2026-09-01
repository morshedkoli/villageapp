"use client";

import { useState } from "react";
import { Check, Copy, Edit2, Trash2 } from "lucide-react";
import type { PaymentAccount } from "@/lib/models";
import { getAccountTypeMeta } from "./account-types";

interface AccountCardProps {
  account: PaymentAccount;
  onEdit: (account: PaymentAccount) => void;
  onDelete: (account: PaymentAccount) => void;
}

function ReadOnlyField({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="bg-surface px-4 py-3 rounded-xl border border-border">
      <p
        className={`text-base font-semibold text-text-primary ${
          mono ? "font-mono tracking-wide" : ""
        }`}
        aria-label={label}
      >
        {value}
      </p>
    </div>
  );
}

export function AccountCard({ account, onEdit, onDelete }: AccountCardProps) {
  const meta = getAccountTypeMeta(account.type);
  const Icon = meta.icon;
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(account.number);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error("Failed to copy:", err);
    }
  };

  return (
    <div
      className="bg-white rounded-2xl border-2 overflow-hidden shadow-sm hover:shadow-md transition-all"
      style={{ borderColor: `${meta.color}33` }}
    >
      <div
        className="px-6 py-4"
        style={{
          backgroundColor: `${meta.color}08`,
          borderBottom: `1px solid ${meta.color}22`,
        }}
      >
        <div className="flex items-center gap-3">
          <div
            className="w-12 h-12 rounded-xl flex items-center justify-center shadow-sm"
            style={{ backgroundColor: `${meta.color}15` }}
          >
            <Icon className="w-6 h-6" style={{ color: meta.color }} />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-bold" style={{ color: meta.color }}>
              {meta.label}
            </h3>
            <span className="inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-md bg-green-50 text-green-700 mt-1">
              <div className="w-1.5 h-1.5 rounded-full bg-green-500" />
              Active
            </span>
          </div>
        </div>
      </div>

      <div className="p-6 space-y-4 relative">
        <div className="absolute top-4 right-4 flex gap-2">
          <button
            onClick={() => onEdit(account)}
            className="p-2 rounded-lg border border-border bg-white hover:bg-surface transition-all"
            title="Edit account"
          >
            <Edit2 className="w-4 h-4 text-text-muted" />
          </button>
          <button
            onClick={() => onDelete(account)}
            className="p-2 rounded-lg border border-border bg-white hover:bg-red-50 hover:border-red-200 transition-all"
            title="Delete account"
          >
            <Trash2 className="w-4 h-4 text-text-muted hover:text-red-600" />
          </button>
        </div>

        <div>
          <label className="block text-xs font-semibold text-text-muted uppercase tracking-wide mb-2">
            Account Number
          </label>
          <div className="flex items-center gap-2">
            <div className="flex-1">
              <ReadOnlyField label="Account number" value={account.number} mono />
            </div>
            <button
              onClick={handleCopy}
              className="p-3 rounded-xl border border-border bg-white hover:bg-surface transition-all"
              title="Copy account number"
            >
              {copied ? (
                <Check className="w-5 h-5 text-green-600" />
              ) : (
                <Copy className="w-5 h-5 text-text-muted" />
              )}
            </button>
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold text-text-muted uppercase tracking-wide mb-2">
            Account Holder
          </label>
          <ReadOnlyField label="Account holder" value={account.name} />
        </div>
      </div>
    </div>
  );
}
