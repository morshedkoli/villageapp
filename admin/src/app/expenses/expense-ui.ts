import { Hammer, HardHat, Receipt, Truck, Wrench } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { ExpenseEntry } from "@/lib/models";

export const expenseCategories = [
  "Materials",
  "Labor",
  "Transport",
  "Equipment",
  "Other",
];

export const expenseCategoryOptions = expenseCategories.map((category) => ({
  value: category,
  label: category,
}));

const CATEGORY_ICONS: Record<string, LucideIcon> = {
  Materials: Hammer,
  Labor: HardHat,
  Transport: Truck,
  Equipment: Wrench,
};

/** Falls back to a generic receipt for categories added outside the list. */
export function categoryIcon(category: string): LucideIcon {
  return CATEGORY_ICONS[category] ?? Receipt;
}

export interface ExpenseFormValues {
  project: string;
  category: string;
  amount: string;
  notes: string;
}

export const emptyExpenseForm: ExpenseFormValues = {
  project: "",
  category: "Materials",
  amount: "",
  notes: "",
};

/**
 * Mirrors the required fields of `createExpenseSchema` so the admin sees the
 * problem before a round trip. The server remains the authority.
 */
export function validateExpenseForm(form: ExpenseFormValues): string | null {
  if (!form.project.trim()) return "Project or expense title is required.";
  const amount = Number(form.amount);
  if (!Number.isFinite(amount) || amount <= 0) {
    return "Enter a valid amount greater than zero.";
  }
  return null;
}

export function matchesExpenseSearch(
  expense: ExpenseEntry,
  query: string
): boolean {
  if (!query) return true;
  const needle = query.toLowerCase();
  return (
    expense.project.toLowerCase().includes(needle) ||
    expense.category.toLowerCase().includes(needle) ||
    (expense.notes ?? "").toLowerCase().includes(needle)
  );
}

export interface CategoryTotal {
  category: string;
  amount: number;
}

export function totalsByCategory(expenses: ExpenseEntry[]): CategoryTotal[] {
  const totals = new Map<string, number>();
  for (const expense of expenses) {
    totals.set(
      expense.category,
      (totals.get(expense.category) ?? 0) + expense.amount
    );
  }
  return Array.from(totals.entries()).map(([category, amount]) => ({
    category,
    amount,
  }));
}
