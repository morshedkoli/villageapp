"use client";

import { Pencil, Trash2, UserRound, Users2 } from "lucide-react";
import { EmptyState } from "@/components/EmptyState";
import { tableHeadCellClass } from "@/components/form-controls";
import type { Leader } from "@/lib/models";

interface LeaderTableProps {
  leaders: Leader[];
  onEdit: (leader: Leader) => void;
  onDelete: (leader: Leader) => void;
}

export function LeaderTable({ leaders, onEdit, onDelete }: LeaderTableProps) {
  if (leaders.length === 0) {
    return (
      <div className="bg-white rounded-2xl border border-border overflow-hidden">
        <EmptyState
          icon={Users2}
          title="No committee members yet"
          description="Members added here appear on the app's Leaders screen. Until then that screen is empty."
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
              <th className={tableHeadCellClass}>Member</th>
              <th className={tableHeadCellClass}>Designation</th>
              <th className={tableHeadCellClass}>Phone</th>
              <th className={tableHeadCellClass}>Order</th>
              <th className={`${tableHeadCellClass} text-right`}>Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border-light">
            {leaders.map((leader) => (
              <tr
                key={leader.id}
                className="hover:bg-surface-hover/50 transition-colors"
              >
                <td className="px-5 py-4">
                  <div className="flex items-center gap-3">
                    {leader.photoUrl ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={leader.photoUrl}
                        alt={leader.name}
                        className="w-9 h-9 rounded-full object-cover"
                      />
                    ) : (
                      <div className="w-9 h-9 rounded-full bg-surface-hover flex items-center justify-center">
                        <UserRound className="w-4 h-4 text-text-muted" />
                      </div>
                    )}
                    <div>
                      <p className="text-sm font-medium text-text-primary">
                        {leader.name}
                      </p>
                      {leader.description && (
                        <p className="text-[12px] text-text-secondary line-clamp-1">
                          {leader.description}
                        </p>
                      )}
                    </div>
                  </div>
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {leader.designation}
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {leader.phone || "—"}
                </td>
                <td className="px-5 py-4 text-sm text-text-secondary">
                  {leader.priority}
                </td>
                <td className="px-5 py-4">
                  <div className="flex items-center justify-end gap-1">
                    <button
                      onClick={() => onEdit(leader)}
                      title="Edit"
                      className="p-2 rounded-lg hover:bg-surface-hover transition-colors text-text-secondary"
                    >
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => onDelete(leader)}
                      title="Remove"
                      className="p-2 rounded-lg hover:bg-danger-light transition-colors text-danger"
                    >
                      <Trash2 className="w-4 h-4" />
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
