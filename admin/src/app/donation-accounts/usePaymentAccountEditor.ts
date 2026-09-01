"use client";

import { useEffect, useState } from "react";
import { apiClient, errorMessage } from "@/lib/api-client";
import { usePaymentAccounts } from "@/lib/hooks";
import type { PaymentAccount } from "@/lib/models";
import { createEmptyAccount } from "./account-types";

/**
 * Editing state for the village payment accounts. The whole list is stored as
 * one array on the village document, so every add, edit and delete rewrites the
 * full array through `PATCH /api/settings`.
 */
export function usePaymentAccountEditor() {
  const { data: paymentAccounts, loading } = usePaymentAccounts();
  const [accounts, setAccounts] = useState<PaymentAccount[]>([]);
  const [editing, setEditing] = useState<PaymentAccount | null>(null);
  const [isNewAccount, setIsNewAccount] = useState(false);
  const [pendingDelete, setPendingDelete] = useState<PaymentAccount | null>(
    null
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    setAccounts(paymentAccounts);
  }, [paymentAccounts]);

  const save = async (next: PaymentAccount[]) => {
    setSaving(true);
    setError("");
    try {
      await apiClient.patch("/api/settings", { paymentAccounts: next });
      setAccounts(next);
      setEditing(null);
      return true;
    } catch (err) {
      setError(errorMessage(err, "Failed to update payment accounts"));
      return false;
    } finally {
      setSaving(false);
    }
  };

  const startAdd = () => {
    setEditing(createEmptyAccount());
    setIsNewAccount(true);
    setError("");
  };

  const startEdit = (account: PaymentAccount) => {
    setEditing({ ...account });
    setIsNewAccount(false);
    setError("");
  };

  const closeEditor = () => {
    setEditing(null);
    setError("");
  };

  const updateEditingField = (field: keyof PaymentAccount, value: string) => {
    setEditing((prev) => (prev ? { ...prev, [field]: value } : prev));
  };

  const saveEditing = async () => {
    if (!editing) return;
    const exists = accounts.some((account) => account.id === editing.id);
    await save(
      exists
        ? accounts.map((account) =>
            account.id === editing.id ? editing : account
          )
        : [...accounts, editing]
    );
  };

  const confirmDelete = async () => {
    if (!pendingDelete) return;
    await save(accounts.filter((account) => account.id !== pendingDelete.id));
    setPendingDelete(null);
  };

  return {
    loading,
    accounts,
    editing,
    isNewAccount,
    pendingDelete,
    saving,
    error,
    startAdd,
    startEdit,
    closeEditor,
    updateEditingField,
    saveEditing,
    setPendingDelete,
    confirmDelete,
  };
}
