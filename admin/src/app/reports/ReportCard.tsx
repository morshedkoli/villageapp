"use client";

import { Download } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface ReportCardProps {
  icon: LucideIcon;
  iconClass: string;
  title: string;
  subtitle: string;
  description: string;
  onDownloadCsv: () => void;
  onDownloadPdf: () => void;
}

/** One downloadable report: a heading, a count summary and CSV/PDF buttons. */
export function ReportCard({
  icon: Icon,
  iconClass,
  title,
  subtitle,
  description,
  onDownloadCsv,
  onDownloadPdf,
}: ReportCardProps) {
  return (
    <div className="bg-white rounded-2xl border border-border p-6 flex flex-col justify-between">
      <div>
        <div className="flex items-center gap-3 mb-4">
          <div
            className={`w-10 h-10 rounded-xl flex items-center justify-center ${iconClass}`}
          >
            <Icon className="w-5 h-5" />
          </div>
          <div>
            <h3 className="text-base font-semibold text-text-primary">
              {title}
            </h3>
            <p className="text-xs text-text-muted">{subtitle}</p>
          </div>
        </div>
        <p className="text-sm text-text-secondary mb-6">{description}</p>
      </div>
      <div className="flex items-center gap-3 flex-wrap">
        <button
          onClick={onDownloadCsv}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary-dark transition-colors"
        >
          <Download className="w-4 h-4" />
          CSV
        </button>
        <button
          onClick={onDownloadPdf}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium bg-background border border-border text-text-primary hover:bg-surface-hover transition-colors"
        >
          <Download className="w-4 h-4" />
          PDF
        </button>
      </div>
    </div>
  );
}
