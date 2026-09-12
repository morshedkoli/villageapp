export interface VillageOverview {
  name: string;
  totalCitizens: number;
  totalFundCollected: number;
  totalSpent: number;
}

export function availableBalance(v: VillageOverview): number {
  return v.totalFundCollected - v.totalSpent;
}

export interface Donation {
  id: string;
  donorName: string;
  amount: number;
  paymentMethod: string;
  receivedAccountId?: string;
  receivedAccountLabel?: string;
  createdAt: Date;
  userId: string;
  status: "Pending" | "Approved" | "Rejected";
  transactionId: string;
  senderNumber: string;
}

export interface ProblemReport {
  id: string;
  title: string;
  description: string;
  status: "Pending" | "Approved" | "Completed";
  photoUrl: string;
  location: string;
  createdAt: Date;
  reportedBy: string;
  reportedByName: string;
}

export interface DevelopmentProject {
  id: string;
  title: string;
  description: string;
  estimatedCost: number;
  allocatedFunds: number;
  status: "Planning" | "In Progress" | "Completed";
  photos: string[];
  updates: string[];
  spendingReport: string[];
  createdAt?: Date;
}

export interface Citizen {
  id: string;
  name: string;
  profession: string;
  phone: string;
  photoUrl: string;
  village: string;
  email?: string;
  address?: string;
  nidNumber?: string;
  bloodGroup?: string;
  dateOfBirth?: string;
  isCitizen?: boolean;
  blocked?: boolean;
}

export interface AppNotification {
  id: string;
  title: string;
  body: string;
  type: "donation" | "problem" | "citizen" | "project" | "general" | "registration";
  source: "user" | "admin";
  createdAt: Date;
}

export interface PaymentAccount {
  id: string;
  type: string;
  number: string;
  name: string;
}

export type PaymentAccounts = PaymentAccount[];

export interface AdminAccount {
  id: string;
  email: string;
  addedAt?: Date;
  addedBy?: string;
}

/**
 * A village committee member, shown on the app's Leaders screen. Until this
 * collection has rows that screen shows its empty state — the Android client
 * used to substitute placeholder names, which villagers read as real contacts.
 */
export interface Leader {
  id: string;
  name: string;
  designation: string;
  phone: string;
  email: string;
  photoUrl: string;
  description: string;
  /** Ascending display order on the app's Leaders screen. */
  priority: number;
}

export interface ExpenseEntry {
  id: string;
  project: string;
  category: string;
  amount: number;
  date: Date;
  notes?: string;
}
