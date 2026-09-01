"use client";

import React, { useState } from "react";
import { useVillageOverview } from "@/lib/hooks";
import { useAuth } from "@/lib/AuthContext";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import { AdminAccessCard } from "./AdminAccessCard";
import { AdminProfileCard } from "./AdminProfileCard";
import { PushNotificationsCard } from "./PushNotificationsCard";
import { VillageNameCard } from "./VillageNameCard";
import { VillageStatsCard } from "./VillageStatsCard";
import { useAdminAccounts } from "./useAdminAccounts";
import { useVillageName } from "./useVillageName";

export default function SettingsPage() {
  const { data: overview, loading } = useVillageOverview();
  const { user } = useAuth();
  const villageName = useVillageName(overview);
  const adminAccounts = useAdminAccounts();

  const [showRenameConfirm, setShowRenameConfirm] = useState(false);
  const [adminToRevoke, setAdminToRevoke] = useState<string | null>(null);

  if (loading) return <LoadingSkeleton />;

  const confirmRename = async () => {
    await villageName.save();
    setShowRenameConfirm(false);
  };

  const confirmRevoke = async () => {
    if (adminToRevoke && (await adminAccounts.revoke(adminToRevoke))) {
      setAdminToRevoke(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text-primary">Settings</h1>
        <p className="text-sm text-text-secondary mt-1">
          Manage village configuration and view statistics
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <VillageNameCard
            villageName={villageName}
            currentName={overview?.name ?? ""}
            onRequestSave={() => setShowRenameConfirm(true)}
          />
          <PushNotificationsCard />
          <VillageStatsCard overview={overview} />
        </div>

        <div className="space-y-6">
          {user && <AdminProfileCard user={user} />}
          <AdminAccessCard
            admins={adminAccounts.admins}
            loading={adminAccounts.loading}
            saving={adminAccounts.saving}
            saved={adminAccounts.saved}
            error={adminAccounts.error}
            onAdd={adminAccounts.add}
            onRequestRevoke={setAdminToRevoke}
          />
        </div>
      </div>

      <ConfirmDialog
        open={showRenameConfirm}
        title="Change Village Name"
        message={`Are you sure you want to change the village name to "${villageName.value}"? This will be visible to all citizens.`}
        variant="warning"
        confirmLabel="Confirm Change"
        loadingLabel="Saving..."
        onConfirm={confirmRename}
        onCancel={() => setShowRenameConfirm(false)}
      />

      <ConfirmDialog
        open={adminToRevoke !== null}
        title="Revoke Admin Access"
        message={`Are you sure you want to remove admin access for "${adminToRevoke}"? They will no longer be able to log in to the admin panel.`}
        variant="danger"
        confirmLabel="Revoke Access"
        loadingLabel="Revoking..."
        onConfirm={confirmRevoke}
        onCancel={() => setAdminToRevoke(null)}
      />
    </div>
  );
}
