import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";

/**
 * White panel with an icon, title and subtitle header — the repeating shell for
 * the settings sections and other detail panels.
 */
export function SectionCard({
  icon: Icon,
  iconClass = "bg-primary-light text-primary",
  title,
  description,
  className = "",
  children,
}: {
  icon: LucideIcon;
  iconClass?: string;
  title: string;
  description?: string;
  className?: string;
  children: ReactNode;
}) {
  return (
    <div className={`bg-white rounded-2xl border border-border p-6 ${className}`}>
      <div className="flex items-center gap-3 mb-6">
        <div
          className={`w-10 h-10 rounded-xl flex items-center justify-center ${iconClass}`}
        >
          <Icon className="w-5 h-5" />
        </div>
        <div>
          <h2 className="text-base font-semibold text-text-primary">{title}</h2>
          {description && (
            <p className="text-xs text-text-muted">{description}</p>
          )}
        </div>
      </div>
      {children}
    </div>
  );
}
