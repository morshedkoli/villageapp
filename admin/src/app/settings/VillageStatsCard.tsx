import { Scale, TrendingDown, Users, Wallet } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { availableBalance, type VillageOverview } from "@/lib/models";
import { formatBDT } from "@/lib/utils";

interface Stat {
  label: string;
  value: string;
  icon: LucideIcon;
  color: string;
  bg: string;
}

function buildStats(overview: VillageOverview): Stat[] {
  return [
    {
      label: "Total Fund Collected",
      value: formatBDT(overview.totalFundCollected),
      icon: Wallet,
      color: "text-primary",
      bg: "bg-primary-light",
    },
    {
      label: "Total Spent",
      value: formatBDT(overview.totalSpent),
      icon: TrendingDown,
      color: "text-danger",
      bg: "bg-danger-light",
    },
    {
      label: "Available Balance",
      value: formatBDT(availableBalance(overview)),
      icon: Scale,
      color: "text-success",
      bg: "bg-success-light",
    },
    {
      label: "Total Citizens",
      value: overview.totalCitizens.toLocaleString(),
      icon: Users,
      color: "text-secondary",
      bg: "bg-secondary-light",
    },
  ];
}

export function VillageStatsCard({
  overview,
}: {
  overview: VillageOverview | null;
}) {
  const stats = overview ? buildStats(overview) : [];

  return (
    <div className="bg-white rounded-2xl border border-border p-6">
      <h2 className="text-base font-semibold text-text-primary mb-4">
        Village Statistics
      </h2>
      <div className="grid grid-cols-2 gap-4">
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
              <p className="text-base font-semibold text-text-primary">
                {stat.value}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
