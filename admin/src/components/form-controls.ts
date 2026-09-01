/**
 * Shared Tailwind class strings for form controls, so every input, select and
 * primary form button in the admin looks identical without repeating the same
 * long class list at each call site.
 */
export const fieldClass =
  "w-full px-4 py-2.5 rounded-xl border border-border bg-background text-sm text-text-primary focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all";

export const labelClass =
  "block text-sm font-medium text-text-primary mb-1.5";

export const primaryButtonClass =
  "inline-flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-all disabled:opacity-50";

export const errorTextClass =
  "text-sm text-danger bg-danger-light px-4 py-3 rounded-xl";

export const tableHeadCellClass =
  "px-5 py-3.5 text-left text-xs font-semibold text-text-secondary uppercase tracking-wider";
