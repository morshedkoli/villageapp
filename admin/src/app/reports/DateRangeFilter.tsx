"use client";

import {
  currentMonthToDate,
  emptyRange,
  monthLabel,
  monthRange,
  type DateRange,
} from "./report-data";

const controlClass =
  "px-3 py-2 rounded-xl border border-border bg-background text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-primary";

const smallLabelClass = "block text-xs text-text-muted mb-1.5";

export function DateRangeFilter({
  range,
  months,
  onChange,
}: {
  range: DateRange;
  months: string[];
  onChange: (next: DateRange) => void;
}) {
  return (
    <div className="bg-white rounded-2xl border border-border p-6">
      <h2 className="text-base font-semibold text-text-primary mb-4">
        Filter by Date
      </h2>
      <div className="flex items-end gap-4 flex-wrap">
        <div>
          <label className={smallLabelClass}>From</label>
          <input
            type="date"
            value={range.from}
            onChange={(e) => onChange({ ...range, from: e.target.value })}
            className={controlClass}
          />
        </div>
        <div>
          <label className={smallLabelClass}>To</label>
          <input
            type="date"
            value={range.to}
            onChange={(e) => onChange({ ...range, to: e.target.value })}
            className={controlClass}
          />
        </div>
        <div>
          <label className={smallLabelClass}>Month</label>
          <select
            value=""
            onChange={(e) => {
              if (e.target.value) onChange(monthRange(e.target.value));
            }}
            className={controlClass}
          >
            <option value="">All months</option>
            {months.map((month) => (
              <option key={month} value={month}>
                {monthLabel(month)}
              </option>
            ))}
          </select>
        </div>
        <div className="flex gap-2 items-end">
          <button
            onClick={() => onChange(currentMonthToDate())}
            className="px-3 py-2 rounded-xl text-xs font-medium bg-primary/10 text-primary hover:bg-primary/20 transition-colors"
          >
            This Month
          </button>
          <button
            onClick={() => onChange(emptyRange)}
            className="px-3 py-2 rounded-xl text-xs font-medium bg-background border border-border text-text-muted hover:text-text-primary transition-colors"
          >
            Clear
          </button>
        </div>
      </div>
    </div>
  );
}
