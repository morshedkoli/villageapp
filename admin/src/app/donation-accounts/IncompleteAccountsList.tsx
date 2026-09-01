"use client";

import { Edit2, Trash2 } from "lucide-react";
import type { PaymentAccount } from "@/lib/models";
import { getAccountTypeMeta } from "./account-types";

/**
 * Accounts saved without a number or holder name. Donors never see them, so
 * they are surfaced here for the admin to finish or remove.
 */
export function IncompleteAccountsList({
  accounts,
  onEdit,
  onDelete,
}: {
  accounts: PaymentAccount[];
  onEdit: (account: PaymentAccount) => void;
  onDelete: (account: PaymentAccount) => void;
}) {
  if (accounts.length === 0) return null;

  return (
    <div className="mt-8">
      <h3 className="text-lg font-semibold text-text-primary mb-4">
        Incomplete Accounts
      </h3>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {accounts.map((account) => {
          const meta = getAccountTypeMeta(account.type);
          const Icon = meta.icon;
          return (
            <div
              key={account.id}
              className="bg-white rounded-xl border-2 border-dashed border-orange-300 p-4 flex items-center justify-between"
            >
              <div className="flex items-center gap-3">
                <div
                  className="w-10 h-10 rounded-lg flex items-center justify-center"
                  style={{ backgroundColor: `${meta.color}15` }}
                >
                  <Icon className="w-5 h-5" style={{ color: meta.color }} />
                </div>
                <div>
                  <p className="font-medium text-text-primary">{meta.label}</p>
                  <p className="text-xs text-orange-600">
                    Incomplete - needs setup
                  </p>
                </div>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => onEdit(account)}
                  className="p-2 rounded-lg bg-orange-50 hover:bg-orange-100 transition-all"
                >
                  <Edit2 className="w-4 h-4 text-orange-600" />
                </button>
                <button
                  onClick={() => onDelete(account)}
                  className="p-2 rounded-lg hover:bg-red-50 transition-all"
                >
                  <Trash2 className="w-4 h-4 text-text-muted hover:text-red-600" />
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
