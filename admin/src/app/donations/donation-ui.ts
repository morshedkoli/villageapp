import type { Donation } from "@/lib/models";

/** Badge colors keyed by the denormalized `paymentMethod` on a donation. */
export const paymentMethodStyles: Record<string, string> = {
  bKash: "bg-success-light text-success",
  Nagad: "bg-warning-light text-warning",
  Rocket: "bg-secondary-light text-secondary",
  Bank: "bg-info-light text-info",
  "Bank Transfer": "bg-info-light text-info",
  Cash: "bg-background text-text-secondary",
};

export function paymentMethodStyle(method: string): string {
  return paymentMethodStyles[method] ?? "bg-background text-text-secondary";
}

export type FilterPeriod = "all" | "today" | "week" | "month";
export type StatusFilter = "all" | Donation["status"];

export const FILTER_PERIODS: FilterPeriod[] = ["all", "today", "week", "month"];
export const STATUS_FILTERS: StatusFilter[] = [
  "all",
  "Pending",
  "Approved",
  "Rejected",
];

const PERIOD_LABELS: Record<FilterPeriod, string> = {
  all: "All",
  today: "Today",
  week: "This Week",
  month: "This Month",
};

export function periodLabel(period: FilterPeriod): string {
  return PERIOD_LABELS[period];
}

const PERIOD_WINDOW_MS: Record<Exclude<FilterPeriod, "all">, number> = {
  today: 86_400_000,
  week: 604_800_000,
  month: 2_592_000_000,
};

export function matchesPeriod(
  donation: Donation,
  period: FilterPeriod,
  now: Date
): boolean {
  if (period === "all") return true;
  return now.getTime() - donation.createdAt.getTime() < PERIOD_WINDOW_MS[period];
}

export interface MonthlyDonationPoint {
  month: string;
  amount: number;
}

/** Approved donation totals per calendar month, most recent 8 months. */
export function monthlyApprovedTotals(
  donations: Donation[]
): MonthlyDonationPoint[] {
  const totals = new Map<string, number>();

  for (const donation of donations) {
    if (donation.status !== "Approved") continue;
    const key = `${donation.createdAt.getFullYear()}-${String(
      donation.createdAt.getMonth() + 1
    ).padStart(2, "0")}`;
    totals.set(key, (totals.get(key) ?? 0) + donation.amount);
  }

  return Array.from(totals.entries())
    .sort(([a], [b]) => a.localeCompare(b))
    .slice(-8)
    .map(([month, amount]) => ({
      month: new Date(`${month}-01`).toLocaleDateString("en-US", {
        month: "short",
        year: "2-digit",
      }),
      amount,
    }));
}

export interface DonationTotals {
  pending: Donation[];
  pendingCount: number;
  pendingAmount: number;
  approvedCount: number;
  approvedAmount: number;
  rejectedCount: number;
}

export function summarizeDonations(donations: Donation[]): DonationTotals {
  const pending = donations.filter((d) => d.status === "Pending");
  const approved = donations.filter((d) => d.status === "Approved");

  return {
    pending,
    pendingCount: pending.length,
    pendingAmount: pending.reduce((sum, d) => sum + d.amount, 0),
    approvedCount: approved.length,
    approvedAmount: approved.reduce((sum, d) => sum + d.amount, 0),
    rejectedCount: donations.filter((d) => d.status === "Rejected").length,
  };
}
