"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { ChartCard } from "@/components/ChartCard";
import { formatBDT } from "@/lib/utils";
import type { MonthlyDonationPoint } from "./donation-ui";

const axisTick = { fill: "#9CA3AF" };

export function DonationTrendChart({
  data,
}: {
  data: MonthlyDonationPoint[];
}) {
  return (
    <ChartCard
      title="Donation Trend"
      description="Monthly approved donation amounts"
      className="animate-fade-in"
    >
      <ResponsiveContainer width="100%" height={220}>
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
          <XAxis
            dataKey="month"
            fontSize={12}
            tick={axisTick}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            fontSize={12}
            tick={axisTick}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip
            formatter={(value) => [formatBDT(Number(value)), "Amount"]}
            contentStyle={{
              borderRadius: "12px",
              border: "1px solid #E5E7EB",
              boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.05)",
              fontSize: "13px",
            }}
          />
          <Bar dataKey="amount" fill="#1F7A5A" radius={[6, 6, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </ChartCard>
  );
}
