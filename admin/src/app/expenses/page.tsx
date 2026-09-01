"use client";

import React, { useMemo, useState } from "react";
import { Plus, Search } from "lucide-react";
import { useExpenses, useProjects } from "@/lib/hooks";
import { apiClient, errorMessage } from "@/lib/api-client";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { formatBDT } from "@/lib/utils";
import { AddExpenseModal } from "./AddExpenseModal";
import { ExpenseCategorySummary } from "./ExpenseCategorySummary";
import { ExpenseTable } from "./ExpenseTable";
import {
  emptyExpenseForm,
  matchesExpenseSearch,
  totalsByCategory,
  validateExpenseForm,
  type ExpenseFormValues,
} from "./expense-ui";

export default function ExpensesPage() {
  const { data: projects } = useProjects();
  const { data: expenses, loading } = useExpenses();
  const [search, setSearch] = useState("");
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [form, setForm] = useState<ExpenseFormValues>(emptyExpenseForm);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  const filteredExpenses = useMemo(
    () => expenses.filter((expense) => matchesExpenseSearch(expense, search)),
    [expenses, search]
  );

  const categoryTotals = useMemo(
    () => totalsByCategory(filteredExpenses),
    [filteredExpenses]
  );

  const totalExpenses = filteredExpenses.reduce(
    (sum, expense) => sum + expense.amount,
    0
  );

  const closeCreateModal = () => {
    setShowCreateModal(false);
    setForm(emptyExpenseForm);
    setError("");
  };

  const handleCreateExpense = async (event: React.FormEvent) => {
    event.preventDefault();

    const validationError = validateExpenseForm(form);
    if (validationError) {
      setError(validationError);
      return;
    }

    setSaving(true);
    setError("");
    try {
      await apiClient.post("/api/expenses", {
        ...form,
        amount: Number(form.amount),
      });
      closeCreateModal();
    } catch (err: unknown) {
      setError(errorMessage(err, "Failed to add expense"));
    } finally {
      setSaving(false);
    }
  };

  if (loading) return <LoadingSkeleton />;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-4 flex-wrap">
        <div>
          <h1 className="text-2xl font-bold text-text-primary">Expenses</h1>
          <p className="text-sm text-text-secondary mt-1">
            Total: {formatBDT(totalExpenses)} across {filteredExpenses.length}{" "}
            entries
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap">
          <div className="relative w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input
              type="text"
              placeholder="Search by project, category, or note..."
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
            Add Expense
          </button>
        </div>
      </div>

      <ExpenseCategorySummary totals={categoryTotals} />

      <ExpenseTable expenses={filteredExpenses} />

      <AddExpenseModal
        open={showCreateModal}
        form={form}
        onChange={(patch) => setForm((prev) => ({ ...prev, ...patch }))}
        onSubmit={handleCreateExpense}
        onClose={closeCreateModal}
        projects={projects}
        loading={saving}
        error={error}
      />
    </div>
  );
}
