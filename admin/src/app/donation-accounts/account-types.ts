import { CreditCard, Landmark, Smartphone } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { PaymentAccount } from "@/lib/models";

export interface AccountTypeMeta {
  value: string;
  label: string;
  color: string;
  icon: LucideIcon;
}

export const accountTypeOptions: AccountTypeMeta[] = [
  { value: "bkash", label: "bKash", color: "#E2136E", icon: Smartphone },
  { value: "nagad", label: "Nagad", color: "#FF6A00", icon: Smartphone },
  { value: "bank", label: "Bank", color: "#1E40AF", icon: Landmark },
  { value: "rocket", label: "Rocket", color: "#8B2FA0", icon: Smartphone },
];

export function getAccountTypeMeta(type: string): AccountTypeMeta {
  return (
    accountTypeOptions.find((option) => option.value === type) ?? {
      value: type,
      label: type || "Other",
      color: "#6B7280",
      icon: CreditCard,
    }
  );
}

/** An account is only shown to donors once it has both a number and a holder. */
export function isAccountComplete(account: PaymentAccount): boolean {
  return account.number.trim() !== "" && account.name.trim() !== "";
}

export function createEmptyAccount(): PaymentAccount {
  const id =
    typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
      ? crypto.randomUUID()
      : `account-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  return { id, type: "bkash", number: "", name: "" };
}
