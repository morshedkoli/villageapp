"use client";

import React from "react";
import { Check, Pencil, Save, Settings, X } from "lucide-react";
import { SectionCard } from "@/components/SectionCard";
import {
  errorTextClass,
  fieldClass,
  labelClass,
} from "@/components/form-controls";
import type { useVillageName } from "./useVillageName";

interface VillageNameCardProps {
  villageName: ReturnType<typeof useVillageName>;
  currentName: string;
  onRequestSave: () => void;
}

export function VillageNameCard({
  villageName,
  currentName,
  onRequestSave,
}: VillageNameCardProps) {
  const handleSubmit = (event: React.FormEvent) => {
    event.preventDefault();
    if (!villageName.isDirty) return;
    onRequestSave();
  };

  return (
    <SectionCard
      icon={Settings}
      title="Village Configuration"
      description="Update your village details"
    >
      <form onSubmit={handleSubmit} className="space-y-5">
        <div>
          <label className={labelClass}>Village Name</label>
          {villageName.editing ? (
            <input
              type="text"
              value={villageName.value}
              onChange={(e) => villageName.setValue(e.target.value)}
              className={fieldClass}
            />
          ) : (
            <div className="flex items-center justify-between gap-3 rounded-xl border border-border bg-background px-4 py-3">
              <span className="text-sm text-text-primary font-medium">
                {currentName || "Our Village"}
              </span>
              <button
                type="button"
                onClick={villageName.startEditing}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white border border-border text-sm font-medium text-text-primary hover:bg-surface-hover transition-colors"
              >
                <Pencil className="w-4 h-4" />
                Edit
              </button>
            </div>
          )}
        </div>

        {villageName.editing && (
          <div className="flex items-center gap-3">
            <button
              type="submit"
              disabled={villageName.saving}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-all disabled:opacity-50"
            >
              {villageName.saved ? (
                <>
                  <Check className="w-4 h-4" />
                  Saved!
                </>
              ) : villageName.saving ? (
                "Saving..."
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Save Name
                </>
              )}
            </button>
            <button
              type="button"
              onClick={villageName.cancelEditing}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-background hover:bg-surface-hover text-text-primary border border-border transition-all"
            >
              <X className="w-4 h-4" />
              Cancel
            </button>
          </div>
        )}

        {villageName.error && (
          <p className={errorTextClass}>{villageName.error}</p>
        )}
      </form>
    </SectionCard>
  );
}
