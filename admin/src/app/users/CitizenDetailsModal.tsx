"use client";

import {
  Briefcase,
  Calendar,
  CreditCard,
  Droplets,
  Home,
  Mail,
  MapPin,
  Phone,
} from "lucide-react";
import { FormModal } from "@/components/FormModal";
import type { Citizen } from "@/lib/models";

export function CitizenDetailsModal({
  citizen,
  onClose,
}: {
  citizen: Citizen | null;
  onClose: () => void;
}) {
  const fields = citizen
    ? [
        { icon: Briefcase, label: "Profession", value: citizen.profession },
        { icon: Phone, label: "Phone", value: citizen.phone },
        { icon: MapPin, label: "Village", value: citizen.village },
        { icon: Home, label: "Address", value: citizen.address },
        { icon: CreditCard, label: "NID Number", value: citizen.nidNumber },
        { icon: Droplets, label: "Blood Group", value: citizen.bloodGroup },
        { icon: Calendar, label: "Date of Birth", value: citizen.dateOfBirth },
        { icon: Mail, label: "Email", value: citizen.email },
      ].filter((field) => field.value)
    : [];

  return (
    <FormModal
      open={citizen !== null}
      title="Citizen Details"
      onClose={onClose}
      size="md"
    >
      {citizen && (
        <div className="space-y-6">
          <div className="flex items-center gap-4">
            {citizen.photoUrl ? (
              <img
                src={citizen.photoUrl}
                alt=""
                className="w-16 h-16 rounded-2xl object-cover ring-2 ring-border"
              />
            ) : (
              <div className="w-16 h-16 rounded-2xl bg-primary-light text-primary flex items-center justify-center text-xl font-bold">
                {citizen.name.charAt(0)}
              </div>
            )}
            <div>
              <h3 className="text-lg font-semibold text-text-primary">
                {citizen.name}
              </h3>
              {citizen.email && (
                <p className="text-sm text-text-secondary">{citizen.email}</p>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 p-4 bg-background rounded-xl">
            {fields.map((field) => (
              <div key={field.label} className="flex items-center gap-3 text-sm">
                <field.icon className="w-4 h-4 text-text-muted shrink-0" />
                <div>
                  <p className="text-xs text-text-muted">{field.label}</p>
                  <p className="text-text-primary font-medium">{field.value}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </FormModal>
  );
}
