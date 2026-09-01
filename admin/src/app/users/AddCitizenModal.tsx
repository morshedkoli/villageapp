"use client";

import React from "react";
import { Save } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import { TextAreaField, TextField } from "@/components/TextField";
import { errorTextClass, primaryButtonClass } from "@/components/form-controls";
import type { CitizenFormValues } from "./citizen-form";

interface AddCitizenModalProps {
  open: boolean;
  form: CitizenFormValues;
  onChange: (patch: Partial<CitizenFormValues>) => void;
  onSubmit: (event: React.FormEvent) => void;
  onClose: () => void;
  loading: boolean;
  error: string;
}

export function AddCitizenModal({
  open,
  form,
  onChange,
  onSubmit,
  onClose,
  loading,
  error,
}: AddCitizenModalProps) {
  return (
    <FormModal open={open} title="Add Citizen" onClose={onClose} size="lg">
      <form onSubmit={onSubmit} className="space-y-5">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Full Name"
            value={form.name}
            onChange={(name) => onChange({ name })}
            placeholder="Citizen full name"
          />
          <TextField
            label="Profession"
            value={form.profession}
            onChange={(profession) => onChange({ profession })}
            placeholder="Profession"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Phone Number"
            value={form.phone}
            onChange={(phone) => onChange({ phone })}
            placeholder="Phone number"
          />
          <TextField
            label="Village"
            value={form.village}
            onChange={(village) => onChange({ village })}
            placeholder="Village name"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Email"
            type="email"
            value={form.email}
            onChange={(email) => onChange({ email })}
            placeholder="email@example.com"
          />
          <TextField
            label="NID Number"
            value={form.nidNumber}
            onChange={(nidNumber) => onChange({ nidNumber })}
            placeholder="NID number"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <TextField
            label="Blood Group"
            value={form.bloodGroup}
            onChange={(bloodGroup) => onChange({ bloodGroup })}
            placeholder="e.g. A+"
          />
          <TextField
            label="Date of Birth"
            type="date"
            value={form.dateOfBirth}
            onChange={(dateOfBirth) => onChange({ dateOfBirth })}
          />
        </div>

        <TextAreaField
          label="Address"
          value={form.address}
          onChange={(address) => onChange({ address })}
          placeholder="Full address"
        />

        <TextField
          label="Photo URL"
          type="url"
          value={form.photoUrl}
          onChange={(photoUrl) => onChange({ photoUrl })}
          placeholder="https://example.com/photo.jpg"
        />

        {error && <p className={errorTextClass}>{error}</p>}

        <div className="flex justify-end">
          <button type="submit" disabled={loading} className={primaryButtonClass}>
            {loading ? (
              "Saving..."
            ) : (
              <>
                <Save className="w-4 h-4" />
                Save Citizen
              </>
            )}
          </button>
        </div>
      </form>
    </FormModal>
  );
}
