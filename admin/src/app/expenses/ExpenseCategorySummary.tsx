import { formatBDT } from "@/lib/utils";
import { categoryIcon, type CategoryTotal } from "./expense-ui";

export function ExpenseCategorySummary({
  totals,
}: {
  totals: CategoryTotal[];
}) {
  if (totals.length === 0) return null;

  return (
    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
      {totals.map((total) => {
        const Icon = categoryIcon(total.category);
        return (
          <div
            key={total.category}
            className="bg-white rounded-2xl border border-border p-4 hover:shadow-md transition-all"
          >
            <div className="w-10 h-10 rounded-xl bg-primary-light flex items-center justify-center mb-3">
              <Icon className="w-5 h-5 text-primary" />
            </div>
            <p className="text-xs text-text-muted font-medium">
              {total.category}
            </p>
            <p className="text-lg font-bold text-text-primary">
              {formatBDT(total.amount)}
            </p>
          </div>
        );
      })}
    </div>
  );
}
