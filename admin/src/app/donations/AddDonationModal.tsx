"use client";

import React from "react";
import { HeartHandshake } from "lucide-react";
import { FormModal } from "@/components/FormModal";
import {
  errorTextClass,
  fieldClass,
  labelClass,
  primaryButtonClass,
} from "@/components/form-controls";
import type { CreateDonationValues } from "./useDonationActions";

export interface SelectOption {
  value: string;
  label: string;
}

interface AddDonationModalProps {
  open: boolean;
  form: CreateDonationValues;
  onChange: (patch: Partial<CreateDonationValues>) => void;
  onSubmit: (event: React.FormEvent) => void;
  onClose: () => void;
  userOptions: SelectOption[];
  usersLoading: boolean;
  receivingOptions: SelectOption[];
  loading: boolean;
  error: string;
}

function citizenPlaceholder(loading: boolean, hasUsers: boolean): string {
  if (loading) return "Loading citizens...";
  return hasUsers ? "Select a citizen" : "No citizens available";
}

export function AddDonationModal({
  open,
  form,
  onChange,
  onSubmit,
  onClose,
  userOptions,
  usersLoading,
  receivingOptions,
  loading,
  error,
}: AddDonationModalProps) {
  return (
    <FormModal open={open} title="Add Donation" onClose={onClose} size="md">
      <form onSubmit={onSubmit} className="space-y-5">
        <div>
          <label className={labelClass}>Citizen</label>
          <select
            value={form.userId}
            onChange={(e) => onChange({ userId: e.target.value })}
            disabled={usersLoading || userOptions.length === 0}
            className={fieldClass}
          >
            <option value="">
              {citizenPlaceholder(usersLoading, userOptions.length > 0)}
            </option>
            {userOptions.map((option) => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className={labelClass}>Amount</label>
            <input
              type="number"
              min="1"
              step="1"
              value={form.amount}
              onChange={(e) => onChange({ amount: e.target.value })}
              placeholder="5000"
              className={fieldClass}
            />
          </div>
          <div>
            <label className={labelClass}>Status</label>
            <select
              value={form.status}
              onChange={(e) =>
                onChange({ status: e.target.value as "Pending" | "Approved" })
              }
              className={fieldClass}
            >
              <option value="Approved">Approved</option>
              <option value="Pending">Pending</option>
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className={labelClass}>Received In</label>
            <select
              value={form.paymentTarget}
              onChange={(e) => onChange({ paymentTarget: e.target.value })}
              className={fieldClass}
            >
              {receivingOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className={labelClass}>Sender Number</label>
            <input
              type="text"
              value={form.senderNumber}
              onChange={(e) => onChange({ senderNumber: e.target.value })}
              placeholder="Optional phone/account number"
              className={fieldClass}
            />
          </div>
        </div>

        <div>
          <label className={labelClass}>Transaction ID</label>
          <input
            type="text"
            value={form.transactionId}
            onChange={(e) => onChange({ transactionId: e.target.value })}
            placeholder="Optional transaction reference"
            className={fieldClass}
          />
        </div>

        {error && <p className={errorTextClass}>{error}</p>}

        <div className="flex justify-end">
          <button type="submit" disabled={loading} className={primaryButtonClass}>
            {loading ? (
              "Saving..."
            ) : (
              <>
                <HeartHandshake className="w-4 h-4" />
                Save Donation
              </>
            )}
          </button>
        </div>
      </form>
    </FormModal>
  );
}
