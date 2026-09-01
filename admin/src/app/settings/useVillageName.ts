"use client";

import { useEffect, useState } from "react";
import { apiClient, errorMessage } from "@/lib/api-client";
import type { VillageOverview } from "@/lib/models";

/**
 * Edit-in-place state for the village name: mirrors the live overview value
 * until the admin starts editing, then keeps their draft until save or cancel.
 */
export function useVillageName(overview: VillageOverview | null) {
  const [value, setValue] = useState("");
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    if (overview && !editing) setValue(overview.name);
  }, [overview, editing]);

  const startEditing = () => {
    setValue(overview?.name ?? "");
    setEditing(true);
    setError("");
  };

  const cancelEditing = () => {
    setValue(overview?.name ?? "");
    setEditing(false);
    setError("");
  };

  const save = async () => {
    setSaving(true);
    setError("");
    try {
      await apiClient.patch("/api/settings", { name: value });
      setEditing(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      setError(errorMessage(err, "Failed to update village name"));
    } finally {
      setSaving(false);
    }
  };

  /** A save is only meaningful for a non-empty name that actually changed. */
  const isDirty = value.trim().length > 0 && value !== overview?.name;

  return {
    value,
    setValue,
    editing,
    saving,
    saved,
    error,
    isDirty,
    startEditing,
    cancelEditing,
    save,
  };
}
