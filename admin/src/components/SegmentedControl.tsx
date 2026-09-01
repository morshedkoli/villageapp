"use client";

/**
 * Pill-style filter switch used across the admin list pages (status filters,
 * time-period filters). Generic over the option union so callers keep their
 * literal types.
 */
export function SegmentedControl<T extends string>({
  options,
  value,
  onChange,
  labelFor,
}: {
  options: readonly T[];
  value: T;
  onChange: (next: T) => void;
  labelFor: (option: T) => string;
}) {
  return (
    <div className="flex items-center gap-1 bg-background rounded-xl p-1">
      {options.map((option) => (
        <button
          key={option}
          type="button"
          onClick={() => onChange(option)}
          className={`px-3 py-1.5 text-xs font-medium rounded-lg transition-colors capitalize ${
            value === option
              ? "bg-white text-text-primary shadow-sm"
              : "text-text-muted hover:text-text-secondary"
          }`}
        >
          {labelFor(option)}
        </button>
      ))}
    </div>
  );
}
