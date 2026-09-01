"use client";

import { useCallback, useEffect, useState } from "react";
import { apiClient, errorMessage } from "@/lib/api-client";
import { normalizeAdminEmail } from "@/lib/admin-access";
import { useAuth } from "@/lib/AuthContext";
import type { AdminAccount } from "@/lib/models";

interface AdminResponse {
  admins?: Array<{
    id: string;
    email: string;
    addedBy?: string;
    addedAt?: string | null;
  }>;
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function sortByEmail(admins: AdminAccount[]): AdminAccount[] {
  return [...admins].sort((a, b) => a.email.localeCompare(b.email));
}

/**
 * Loads the admin allow-list and exposes add/revoke. Owns its own loading,
 * saving and error state so the settings page does not have to interleave it
 * with the village-name state.
 */
export function useAdminAccounts() {
  const { user } = useAuth();
  const [admins, setAdmins] = useState<AdminAccount[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (!user) {
      setAdmins([]);
      setLoading(false);
      return;
    }

    let active = true;

    const load = async () => {
      setLoading(true);
      try {
        const data = await apiClient.get<AdminResponse>("/api/admins");
        if (!active) return;
        setAdmins(
          (data.admins ?? []).map((admin) => ({
            id: admin.id,
            email: admin.email,
            addedBy: admin.addedBy ?? "",
            addedAt: admin.addedAt ? new Date(admin.addedAt) : undefined,
          }))
        );
      } catch {
        if (active) setAdmins([]);
      } finally {
        if (active) setLoading(false);
      }
    };

    void load();
    return () => {
      active = false;
    };
  }, [user]);

  const add = useCallback(
    async (rawEmail: string) => {
      const email = normalizeAdminEmail(rawEmail);

      if (!email) {
        setError("Please enter an email address.");
        return false;
      }
      if (!EMAIL_PATTERN.test(email)) {
        setError("Please enter a valid email address.");
        return false;
      }
      if (admins.some((admin) => admin.email === email)) {
        setError("This email already has admin access.");
        return false;
      }

      setSaving(true);
      setError("");
      try {
        await apiClient.post("/api/admins", { email });
        setAdmins((prev) =>
          sortByEmail([
            ...prev,
            { id: email, email, addedBy: user?.email ?? "" },
          ])
        );
        setSaved(true);
        setTimeout(() => setSaved(false), 2000);
        return true;
      } catch (err) {
        setError(errorMessage(err, "Failed to add admin"));
        return false;
      } finally {
        setSaving(false);
      }
    },
    [admins, user]
  );

  const revoke = useCallback(async (email: string) => {
    setError("");
    try {
      await apiClient.delete("/api/admins", { email });
      setAdmins((prev) => prev.filter((admin) => admin.email !== email));
      return true;
    } catch (err) {
      setError(errorMessage(err, "Failed to revoke admin access"));
      return false;
    }
  }, []);

  return { admins, loading, saving, saved, error, add, revoke };
}
