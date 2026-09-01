"use client";

import React, { useMemo, useState } from "react";
import { Plus, Search } from "lucide-react";
import { useUsers } from "@/lib/hooks";
import { apiClient, errorMessage } from "@/lib/api-client";
import { blockUser } from "@/lib/firestore-service";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import type { Citizen } from "@/lib/models";
import { AddCitizenModal } from "./AddCitizenModal";
import { CitizenDetailsModal } from "./CitizenDetailsModal";
import { CitizenTable } from "./CitizenTable";
import {
  emptyCitizenForm,
  validateCitizenForm,
  type CitizenFormValues,
} from "./citizen-form";

function matchesSearch(citizen: Citizen, query: string): boolean {
  return (
    citizen.name.toLowerCase().includes(query) ||
    (citizen.email ?? "").toLowerCase().includes(query) ||
    citizen.phone.includes(query) ||
    citizen.village.toLowerCase().includes(query)
  );
}

export default function UsersPage() {
  const { data: users, loading } = useUsers();
  const [blockTarget, setBlockTarget] = useState<Citizen | null>(null);
  const [viewCitizen, setViewCitizen] = useState<Citizen | null>(null);
  const [search, setSearch] = useState("");
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createLoading, setCreateLoading] = useState(false);
  const [createError, setCreateError] = useState("");
  const [form, setForm] = useState<CitizenFormValues>(emptyCitizenForm);

  const filtered = useMemo(() => {
    if (!search) return users;
    const query = search.toLowerCase();
    return users.filter((citizen) => matchesSearch(citizen, query));
  }, [users, search]);

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setForm(emptyCitizenForm);
    setCreateError("");
  };

  const handleCreateCitizen = async (event: React.FormEvent) => {
    event.preventDefault();

    const validationError = validateCitizenForm(form);
    if (validationError) {
      setCreateError(validationError);
      return;
    }

    setCreateLoading(true);
    setCreateError("");
    try {
      await apiClient.post("/api/users", form);
      closeCreateModal();
    } catch (err: unknown) {
      setCreateError(errorMessage(err, "Failed to add citizen"));
    } finally {
      setCreateLoading(false);
    }
  };

  if (loading) return <LoadingSkeleton />;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-text-primary">Citizens</h1>
          <p className="text-sm text-text-secondary mt-1">
            {users.length} registered citizens
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap">
          <div className="relative w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input
              type="text"
              placeholder="Search by name, email, phone..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2.5 bg-white rounded-xl border border-border text-sm text-text-primary placeholder:text-text-muted focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"
            />
          </div>
          <button
            onClick={() => setShowCreateModal(true)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-all"
          >
            <Plus className="w-4 h-4" />
            Add Citizen
          </button>
        </div>
      </div>

      <CitizenTable
        citizens={filtered}
        searching={search.length > 0}
        onView={setViewCitizen}
        onToggleBlock={setBlockTarget}
      />

      <CitizenDetailsModal
        citizen={viewCitizen}
        onClose={() => setViewCitizen(null)}
      />

      <ConfirmDialog
        open={blockTarget !== null}
        title={blockTarget?.blocked ? "Unblock Citizen" : "Block Citizen"}
        message={
          blockTarget?.blocked
            ? `Are you sure you want to unblock ${blockTarget?.name}? They will regain access to the platform.`
            : `Are you sure you want to block ${blockTarget?.name}? They will lose access to the platform.`
        }
        variant={blockTarget?.blocked ? "warning" : "danger"}
        confirmLabel={blockTarget?.blocked ? "Unblock" : "Block"}
        loadingLabel={blockTarget?.blocked ? "Unblocking..." : "Blocking..."}
        onConfirm={async () => {
          if (blockTarget) await blockUser(blockTarget.id, !blockTarget.blocked);
          setBlockTarget(null);
        }}
        onCancel={() => setBlockTarget(null)}
      />

      <AddCitizenModal
        open={showCreateModal}
        form={form}
        onChange={(patch) => setForm((prev) => ({ ...prev, ...patch }))}
        onSubmit={handleCreateCitizen}
        onClose={closeCreateModal}
        loading={createLoading}
        error={createError}
      />
    </div>
  );
}
