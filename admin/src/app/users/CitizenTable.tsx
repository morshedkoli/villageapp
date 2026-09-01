"use client";

import { Eye, ShieldBan, ShieldCheck, Users } from "lucide-react";
import { EmptyState } from "@/components/EmptyState";
import { tableHeadCellClass } from "@/components/form-controls";
import type { Citizen } from "@/lib/models";

interface CitizenTableProps {
  citizens: Citizen[];
  searching: boolean;
  onView: (citizen: Citizen) => void;
  onToggleBlock: (citizen: Citizen) => void;
}

export function CitizenTable({
  citizens,
  searching,
  onView,
  onToggleBlock,
}: CitizenTableProps) {
  if (citizens.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-border overflow-hidden">
        <EmptyState
          icon={Users}
          title={
            searching ? "No citizens match your search" : "No citizens registered"
          }
          description={
            searching
              ? "Try a different search term."
              : "Registered village citizens will appear here."
          }
        />
      </div>
    );
  }

  return (
    <div className="bg-white rounded-2xl border border-border overflow-hidden">
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-border bg-background/50">
              <th className={tableHeadCellClass}>Citizen</th>
              <th className={tableHeadCellClass}>Profession</th>
              <th className={tableHeadCellClass}>Phone</th>
              <th className={tableHeadCellClass}>Village</th>
              <th className={`${tableHeadCellClass} text-right`}>Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {citizens.map((citizen) => (
              <tr
                key={citizen.id}
                className="hover:bg-surface-hover/50 transition-colors"
              >
                <td className="px-5 py-4">
                  <div className="flex items-center gap-3">
                    {citizen.photoUrl ? (
                      <img
                        src={citizen.photoUrl}
                        alt=""
                        className="w-9 h-9 rounded-full object-cover shrink-0 ring-2 ring-border"
                      />
                    ) : (
                      <div className="w-9 h-9 rounded-full bg-primary-light text-primary flex items-center justify-center text-sm font-semibold shrink-0">
                        {citizen.name.charAt(0)}
                      </div>
                    )}
                    <div>
                      <div className="flex items-center gap-2">
                        <p className="text-sm font-medium text-text-primary">
                          {citizen.name}
                        </p>
                        {citizen.blocked && (
                          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-danger-light text-danger">
                            Blocked
                          </span>
                        )}
                      </div>
                      {citizen.email && (
                        <p className="text-xs text-text-muted">
                          {citizen.email}
                        </p>
                      )}
                    </div>
                  </div>
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {citizen.profession || "—"}
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {citizen.phone || "—"}
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {citizen.village || "—"}
                </td>
                <td className="px-5 py-4">
                  <div className="flex items-center justify-end gap-1">
                    <button
                      onClick={() => onView(citizen)}
                      className="p-2 rounded-lg hover:bg-surface-hover text-text-muted hover:text-text-primary transition-colors"
                      title="View Details"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => onToggleBlock(citizen)}
                      className={`p-2 rounded-lg transition-colors ${
                        citizen.blocked
                          ? "hover:bg-success-light text-text-muted hover:text-success"
                          : "hover:bg-danger-light text-text-muted hover:text-danger"
                      }`}
                      title={citizen.blocked ? "Unblock" : "Block"}
                    >
                      {citizen.blocked ? (
                        <ShieldCheck className="w-4 h-4" />
                      ) : (
                        <ShieldBan className="w-4 h-4" />
                      )}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
