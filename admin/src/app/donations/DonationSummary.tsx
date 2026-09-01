import { Ban, CircleDollarSign, Clock } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { formatBDT } from "@/lib/utils";
import type { DonationTotals } from "./donation-ui";

function SummaryCard({
  icon: Icon,
  iconClass,
  label,
  value,
  caption,
  captionClass,
}: {
  icon: LucideIcon;
  iconClass: string;
  label: string;
  value: number;
  caption?: string;
  captionClass?: string;
}) {
  return (
    <div className="bg-white rounded-2xl border border-border p-5 flex items-center gap-4">
      <div
        className={`w-11 h-11 rounded-xl flex items-center justify-center ${iconClass}`}
      >
        <Icon className="w-5 h-5" />
      </div>
      <div>
        <p className="text-xs font-medium text-text-muted uppercase tracking-wider">
          {label}
        </p>
        <p className="text-lg font-bold text-text-primary">{value}</p>
        {caption && (
          <p className={`text-xs font-medium ${captionClass}`}>{caption}</p>
        )}
      </div>
    </div>
  );
}

export function DonationSummary({ totals }: { totals: DonationTotals }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <SummaryCard
        icon={Clock}
        iconClass="bg-warning-light text-warning"
        label="Pending"
        value={totals.pendingCount}
        caption={formatBDT(totals.pendingAmount)}
        captionClass="text-warning"
      />
      <SummaryCard
        icon={CircleDollarSign}
        iconClass="bg-success-light text-success"
        label="Approved"
        value={totals.approvedCount}
        caption={formatBDT(totals.approvedAmount)}
        captionClass="text-success"
      />
      <SummaryCard
        icon={Ban}
        iconClass="bg-danger-light text-danger"
        label="Rejected"
        value={totals.rejectedCount}
      />
    </div>
  );
}
