import { Receipt } from "lucide-react";
import { EmptyState } from "@/components/EmptyState";
import { tableHeadCellClass } from "@/components/form-controls";
import { formatBDT, formatDate } from "@/lib/utils";
import type { ExpenseEntry } from "@/lib/models";
import { categoryIcon } from "./expense-ui";

export function ExpenseTable({ expenses }: { expenses: ExpenseEntry[] }) {
  if (expenses.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-border overflow-hidden">
        <EmptyState
          icon={Receipt}
          title="No expenses recorded"
          description="Add the first expense entry to start tracking village spending."
        />
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl border border-border overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border bg-background/50">
              <th className={tableHeadCellClass}>Category</th>
              <th className={tableHeadCellClass}>Project</th>
              <th className={tableHeadCellClass}>Amount</th>
              <th className={tableHeadCellClass}>Date</th>
              <th className={tableHeadCellClass}>Notes</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {expenses.map((expense) => {
              const Icon = categoryIcon(expense.category);
              return (
                <tr
                  key={expense.id}
                  className="hover:bg-surface-hover/50 transition-colors"
                >
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-background flex items-center justify-center">
                        <Icon className="w-4 h-4 text-text-muted" />
                      </div>
                      <span className="text-sm font-medium text-text-primary">
                        {expense.category}
                      </span>
                    </div>
                  </td>
                  <td className="px-5 py-4 text-sm text-text-secondary">
                    {expense.project}
                  </td>
                  <td className="px-5 py-4 text-sm font-semibold text-text-primary">
                    {formatBDT(expense.amount)}
                  </td>
                  <td className="px-5 py-4 text-sm text-text-muted">
                    {formatDate(expense.date)}
                  </td>
                  <td className="px-5 py-4 text-sm text-text-secondary max-w-xs">
                    <span className="line-clamp-2">{expense.notes || "-"}</span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
