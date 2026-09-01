import type {
  DevelopmentProject,
  Donation,
  ExpenseEntry,
} from "@/lib/models";

export interface DateRange {
  from: string;
  to: string;
}

export const emptyRange: DateRange = { from: "", to: "" };

function monthKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
}

/** Every month that has at least one donation, project or expense, newest first. */
export function availableMonths(
  donations: Donation[],
  projects: DevelopmentProject[],
  expenses: ExpenseEntry[]
): string[] {
  const months = new Set<string>();

  for (const donation of donations) {
    if (donation.createdAt) months.add(monthKey(donation.createdAt));
  }
  for (const project of projects) {
    if (project.createdAt) months.add(monthKey(project.createdAt));
  }
  for (const expense of expenses) {
    if (expense.date) months.add(monthKey(expense.date));
  }

  return Array.from(months).sort().reverse();
}

export function monthLabel(month: string): string {
  const [year, monthNumber] = month.split("-");
  return new Date(Number(year), Number(monthNumber) - 1).toLocaleDateString(
    "en-US",
    { year: "numeric", month: "long" }
  );
}

/** Full calendar range for a `YYYY-MM` month key. */
export function monthRange(month: string): DateRange {
  const [year, monthNumber] = month.split("-");
  const lastDay = new Date(Number(year), Number(monthNumber), 0).getDate();
  return {
    from: `${month}-01`,
    to: `${month}-${String(lastDay).padStart(2, "0")}`,
  };
}

/** Month-to-date range, used by the "This Month" shortcut. */
export function currentMonthToDate(now = new Date()): DateRange {
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, "0");
  return {
    from: `${year}-${month}-01`,
    to: `${year}-${month}-${String(now.getDate()).padStart(2, "0")}`,
  };
}

/**
 * Filters by an inclusive date range. Records without a date are kept, since
 * excluding them would silently drop rows the admin can see in the tables.
 */
export function filterByDate<T extends { createdAt?: Date }>(
  items: T[],
  range: DateRange
): T[] {
  if (!range.from && !range.to) return items;

  return items.filter((item) => {
    if (!item.createdAt) return true;
    const time = item.createdAt.getTime();

    if (range.from && time < new Date(range.from).getTime()) return false;

    if (range.to) {
      const end = new Date(range.to);
      end.setHours(23, 59, 59, 999);
      if (time > end.getTime()) return false;
    }

    return true;
  });
}

/** Filename suffix describing the selected range, e.g. `-2026-01-01-to-…`. */
export function dateSuffix(range: DateRange): string {
  if (range.from && range.to) return `-${range.from}-to-${range.to}`;
  if (range.from) return `-from-${range.from}`;
  if (range.to) return `-to-${range.to}`;
  return "";
}

export function periodLine(range: DateRange): string {
  return `Period: ${range.from || "All time"} — ${range.to || "All time"}`;
}

export function sumBy<T>(items: T[], pick: (item: T) => number): number {
  return items.reduce((total, item) => total + pick(item), 0);
}
