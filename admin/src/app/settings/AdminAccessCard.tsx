"use client";

import React, { useState } from "react";
import { Check, Plus, Shield, Trash2 } from "lucide-react";
import { SectionCard } from "@/components/SectionCard";
import {
  errorTextClass,
  fieldClass,
  labelClass,
} from "@/components/form-controls";
import { isBootstrapAdminEmail } from "@/lib/admin-access";
import type { AdminAccount } from "@/lib/models";

interface AdminAccessCardProps {
  admins: AdminAccount[];
  loading: boolean;
  saving: boolean;
  saved: boolean;
  error: string;
  onAdd: (email: string) => Promise<boolean>;
  onRequestRevoke: (email: string) => void;
}

function AdminRow({
  admin,
  onRequestRevoke,
}: {
  admin: AdminAccount;
  onRequestRevoke: (email: string) => void;
}) {
  // Bootstrap admins come from configuration, so they cannot be revoked here.
  const isBootstrap = isBootstrapAdminEmail(admin.email);

  return (
    <div className="flex items-center justify-between gap-3 rounded-xl bg-background px-4 py-3">
      <div className="min-w-0">
        <p className="text-sm font-medium text-text-primary break-all">
          {admin.email}
        </p>
        {admin.addedBy && (
          <p className="text-xs text-text-muted break-all">
            Added by {admin.addedBy}
          </p>
        )}
      </div>
      <div className="flex items-center gap-2 shrink-0">
        <span className="text-xs font-medium text-primary bg-primary-light px-2.5 py-1 rounded-lg">
          {isBootstrap ? "Bootstrap" : "Admin"}
        </span>
        {!isBootstrap && (
          <button
            type="button"
            onClick={() => onRequestRevoke(admin.email)}
            title="Revoke Admin Access"
            className="p-1.5 text-text-muted hover:text-danger hover:bg-danger-light rounded-lg transition-colors"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        )}
      </div>
    </div>
  );
}

export function AdminAccessCard({
  admins,
  loading,
  saving,
  saved,
  error,
  onAdd,
  onRequestRevoke,
}: AdminAccessCardProps) {
  const [email, setEmail] = useState("");

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    if (await onAdd(email)) setEmail("");
  };

  return (
    <SectionCard
      icon={Shield}
      title="Admin Access"
      description="Add a new admin by email address"
      className="h-fit"
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className={labelClass}>Admin Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="name@example.com"
            className={fieldClass}
          />
          <p className="text-xs text-text-muted mt-2">
            The user can sign in with this email and will get admin access
            automatically.
          </p>
        </div>

        <button
          type="submit"
          disabled={saving}
          className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-text-primary text-white hover:bg-text-primary/90 transition-all disabled:opacity-50"
        >
          {saved ? (
            <>
              <Check className="w-4 h-4" />
              Added!
            </>
          ) : saving ? (
            "Adding..."
          ) : (
            <>
              <Plus className="w-4 h-4" />
              Add Admin
            </>
          )}
        </button>

        {error && <p className={errorTextClass}>{error}</p>}
      </form>

      <div className="mt-6 pt-6 border-t border-border">
        <p className="text-sm font-medium text-text-primary mb-3">
          Current Admins
        </p>
        <div className="space-y-2">
          {loading ? (
            <p className="text-sm text-text-muted">Loading admins...</p>
          ) : admins.length === 0 ? (
            <p className="text-sm text-text-muted">
              No extra admins added yet.
            </p>
          ) : (
            admins.map((admin) => (
              <AdminRow
                key={admin.id}
                admin={admin}
                onRequestRevoke={onRequestRevoke}
              />
            ))
          )}
        </div>
      </div>
    </SectionCard>
  );
}
