import { FolderKanban, Scale, TrendingDown, Wallet } from "lucide-react";
import { availableBalance, type VillageOverview } from "@/lib/models";
import { formatBDT } from "@/lib/utils";

export function FundSummary({
  overview,
  projectCount,
}: {
  overview: VillageOverview | null;
  projectCount: number;
}) {
  const stats = [
    {
      label: "Total Fund",
      value: formatBDT(overview?.totalFundCollected ?? 0),
      icon: Wallet,
      color: "text-primary",
      bg: "bg-primary-light",
    },
    {
      label: "Total Spent",
      value: formatBDT(overview?.totalSpent ?? 0),
      icon: TrendingDown,
      color: "text-danger",
      bg: "bg-danger-light",
    },
    {
      label: "Available Balance",
      value: overview ? formatBDT(availableBalance(overview)) : formatBDT(0),
      icon: Scale,
      color: "text-success",
      bg: "bg-success-light",
    },
    {
      label: "Total Projects",
      value: projectCount.toString(),
      icon: FolderKanban,
      color: "text-secondary",
      bg: "bg-secondary-light",
    },
  ];

  return (
    <div className="bg-white rounded-2xl border border-border p-6">
      <h2 className="text-base font-semibold text-text-primary mb-4">
        Village Fund Summary
      </h2>
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat) => (
          <div
            key={stat.label}
            className="flex items-center gap-3 p-4 bg-background rounded-xl"
          >
            <div
              className={`w-10 h-10 rounded-xl ${stat.bg} flex items-center justify-center`}
            >
              <stat.icon className={`w-5 h-5 ${stat.color}`} />
            </div>
            <div>
              <p className="text-xs text-text-muted">{stat.label}</p>
              <p className="text-lg font-bold text-text-primary">
                {stat.value}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
