import { db } from "./firebase";
import {
  collection,
  doc,
  onSnapshot,
  query,
  orderBy,
  limit,
  addDoc,
  deleteDoc,
  serverTimestamp,
  updateDoc,
  setDoc,
  getDocs,
  where,
  Unsubscribe,
  DocumentData,
} from "firebase/firestore";
import { toDate, toNumber } from "./converters";
import type {
  VillageOverview,
  Donation,
  ProblemReport,
  DevelopmentProject,
  Citizen,
  AppNotification,
  Leader,
  PaymentAccounts,
  ExpenseEntry,
} from "./models";

const VILLAGE_DOC_ID = "main_village";

/** Matches the `limit(200)` used by the other admin listeners. */
const CITIZEN_PAGE_SIZE = 200;

// --- Village Overview ---

export function subscribeVillageOverview(
  callback: (data: VillageOverview) => void
): Unsubscribe {
  return onSnapshot(
    doc(db, "villages", VILLAGE_DOC_ID), 
    (snap) => {
      const d = snap.data() ?? {};
      callback({
        name: (d.name as string) ?? "Our Village",
        totalCitizens: toNumber(d.totalCitizens),
        totalFundCollected: toNumber(d.totalFundCollected),
        totalSpent: toNumber(d.totalSpent),
      });
    },
    (error) => { console.warn("Village listener error:", error.message); }
  );
}

// --- Payment Accounts ---

export function subscribePaymentAccounts(
  callback: (accounts: PaymentAccounts) => void
): Unsubscribe {
  return onSnapshot(
    doc(db, "villages", VILLAGE_DOC_ID),
    (snap) => {
      const d = snap.data() ?? {};
      const raw = d.paymentAccounts;
      const accounts: PaymentAccounts = [];

      if (Array.isArray(raw)) {
        for (const val of raw) {
          if (val && typeof val === "object") {
            const v = val as Record<string, unknown>;
            accounts.push({
              id: String(v.id ?? crypto.randomUUID?.() ?? Date.now()),
              type: String(v.type ?? "bank"),
              number: String(v.number ?? ""),
              name: String(v.name ?? ""),
            });
          }
        }
      } else {
        const legacy = (raw as Record<string, unknown>) ?? {};
        for (const [key, val] of Object.entries(legacy)) {
          if (val && typeof val === "object") {
            const v = val as Record<string, unknown>;
            accounts.push({
              id: String(v.id ?? key),
              type: String(v.type ?? key).toLowerCase(),
              number: String(v.number ?? ""),
              name: String(v.name ?? ""),
            });
          }
        }
      }

      callback(accounts);
    },
    (error) => {
      console.warn("Payment accounts listener error:", error.message);
    }
  );
}

// --- Donations ---

function mapDonation(id: string, d: DocumentData): Donation {
  return {
    id,
    donorName: (d.donorName as string) ?? "",
    amount: toNumber(d.amount),
    paymentMethod: (d.paymentMethod as string) ?? "",
    receivedAccountId: (d.receivedAccountId as string) ?? "",
    receivedAccountLabel: (d.receivedAccountLabel as string) ?? "",
    createdAt: toDate(d.createdAt),
    userId: (d.userId as string) ?? "",
    status: (d.status as Donation["status"]) ?? "Pending",
    transactionId: (d.transactionId as string) ?? "",
    senderNumber: (d.senderNumber as string) ?? "",
  };
}

export function subscribeDonations(
  callback: (donations: Donation[]) => void
): Unsubscribe {
  const q = query(
    collection(db, "donations"),
    orderBy("createdAt", "desc"),
    limit(200)
  );
  return onSnapshot(
    q, 
    (snap) => { callback(snap.docs.map((doc) => mapDonation(doc.id, doc.data()))); },
    (error) => { console.warn("Donations listener error:", error.message); }
  );
}

// Donation approval, rejection and deletion live in /api/donations only.
// The client-side versions that used to sit here credited the fund without
// tagging the ledger row with `donationId`, so the API route's reversal could
// not find them and a deleted approval left the total inflated forever.

// --- Projects ---

function mapProject(id: string, d: DocumentData): DevelopmentProject {
  return {
    id,
    title: (d.title as string) ?? "",
    description: (d.description as string) ?? "",
    estimatedCost: toNumber(d.estimatedCost),
    allocatedFunds: toNumber(d.allocatedFunds),
    status: (d.status as DevelopmentProject["status"]) ?? "Planning",
    photos: Array.isArray(d.photos) ? d.photos : [],
    updates: Array.isArray(d.updates) ? d.updates : [],
    spendingReport: Array.isArray(d.spendingReport) ? d.spendingReport : [],
    createdAt: d.createdAt ? toDate(d.createdAt) : undefined,
  };
}

export function subscribeProjects(
  callback: (projects: DevelopmentProject[]) => void
): Unsubscribe {
  const q = query(
    collection(db, "projects"),
    orderBy("createdAt", "desc"),
    limit(200)
  );
  return onSnapshot(
    q, 
    (snap) => { callback(snap.docs.map((doc) => mapProject(doc.id, doc.data()))); },
    (error) => { console.warn("Projects listener error:", error.message); }
  );
}

// Project writes live in /api/projects only.

// --- Problems ---

function mapProblem(id: string, d: DocumentData): ProblemReport {
  return {
    id,
    title: (d.title as string) ?? "",
    description: (d.description as string) ?? "",
    status: (d.status as ProblemReport["status"]) ?? "Pending",
    photoUrl: (d.photoUrl as string) ?? "",
    location: (d.location as string) ?? "",
    createdAt: toDate(d.createdAt),
    reportedBy: (d.reportedBy as string) ?? "",
    reportedByName: (d.reportedByName as string) ?? "",
  };
}

export function subscribeProblems(
  callback: (problems: ProblemReport[]) => void
): Unsubscribe {
  const q = query(
    collection(db, "problems"),
    orderBy("createdAt", "desc"),
    limit(200)
  );
  return onSnapshot(
    q, 
    (snap) => { callback(snap.docs.map((doc) => mapProblem(doc.id, doc.data()))); },
    (error) => { console.warn("Problems listener error:", error.message); }
  );
}

// Problem writes live in /api/problems only.

// --- Users / Citizens ---

function mapCitizen(id: string, d: DocumentData): Citizen {
  return {
    id,
    name: (d.name as string) ?? "",
    profession: (d.profession as string) ?? "",
    phone: (d.phone as string) ?? "",
    photoUrl: (d.photoUrl as string) ?? "",
    village: (d.village as string) ?? "",
    email: (d.email as string) ?? "",
    address: (d.address as string) ?? "",
    nidNumber: (d.nidNumber as string) ?? "",
    bloodGroup: (d.bloodGroup as string) ?? "",
    dateOfBirth: (d.dateOfBirth as string) ?? "",
    isCitizen: d.isCitizen === true,
    blocked: d.blocked === true,
  };
}

function sortCitizensByName(citizens: Citizen[]): Citizen[] {
  return [...citizens].sort((a, b) => a.name.localeCompare(b.name));
}

export function subscribeUsers(
  callback: (users: Citizen[]) => void
): Unsubscribe {
  // Bounded like every other listener here: the admin tables filter client
  // side, so an unbounded stream would grow without limit as the village does.
  const indexedQuery = query(
    collection(db, "users"),
    where("isCitizen", "==", true),
    orderBy("name"),
    limit(CITIZEN_PAGE_SIZE)
  );

  let fallbackUnsubscribe: Unsubscribe | null = null;

  const primaryUnsubscribe = onSnapshot(
    indexedQuery,
    (snap) => {
      callback(
        sortCitizensByName(
          snap.docs.map((doc) => mapCitizen(doc.id, doc.data()))
        )
      );
    },
    (error) => {
      if (error.code !== "failed-precondition" || fallbackUnsubscribe) {
        console.error("Failed to subscribe to indexed users", error);
        return;
      }

      const fallbackQuery = query(
        collection(db, "users"),
        where("isCitizen", "==", true),
        limit(CITIZEN_PAGE_SIZE)
      );

      fallbackUnsubscribe = onSnapshot(
        fallbackQuery,
        (snap) => {
          callback(
            sortCitizensByName(
              snap.docs.map((doc) => mapCitizen(doc.id, doc.data()))
            )
          );
        },
        (fallbackError) => {
          console.error("Failed to subscribe to fallback users", fallbackError);
        }
      );
    }
  );

  return () => {
    primaryUnsubscribe();
    fallbackUnsubscribe?.();
  };
}

export async function blockUser(id: string, blocked: boolean): Promise<void> {
  await updateDoc(doc(db, "users", id), { blocked });
}

export async function syncCitizenCount(): Promise<void> {
  const q = query(collection(db, "users"), where("isCitizen", "==", true));
  const snap = await getDocs(q);
  await setDoc(
    doc(db, "villages", VILLAGE_DOC_ID),
    { totalCitizens: snap.size },
    { merge: true }
  );
}

// --- Expenses ---

function mapExpense(id: string, d: DocumentData): ExpenseEntry {
  return {
    id,
    project: (d.project as string) ?? (d.reference as string) ?? "General",
    category: (d.category as string) ?? "Other",
    amount: toNumber(d.amount),
    date: d.createdAt ? toDate(d.createdAt) : new Date(),
    notes: (d.notes as string) ?? "",
  };
}

function sortExpensesByDate(expenses: ExpenseEntry[]): ExpenseEntry[] {
  return [...expenses].sort((a, b) => b.date.getTime() - a.date.getTime());
}

export function subscribeExpenses(
  callback: (expenses: ExpenseEntry[]) => void
): Unsubscribe {
  // Filter server side: with a client-side filter a burst of donation rows
  // could fill the whole 200-document page and empty the expenses table.
  const q = query(
    collection(db, "fund_transactions"),
    where("type", "==", "expense"),
    orderBy("createdAt", "desc"),
    limit(200)
  );

  return onSnapshot(
    q,
    (snap) => {
      callback(
        sortExpensesByDate(
          snap.docs.map((expenseDoc) =>
            mapExpense(expenseDoc.id, expenseDoc.data())
          )
        )
      );
    },
    (error) => {
      console.warn("Expenses listener error:", error.message);
    }
  );
}

// Expense writes live in /api/expenses only.

// --- Leaders (village committee) ---

function mapLeader(id: string, d: DocumentData): Leader {
  return {
    id,
    name: (d.name as string) ?? "",
    designation: (d.designation as string) ?? (d.role as string) ?? "",
    phone: (d.phone as string) ?? "",
    email: (d.email as string) ?? "",
    photoUrl: (d.photoUrl as string) ?? "",
    description: (d.description as string) ?? "",
    priority: toNumber(d.priority),
  };
}

export function subscribeLeaders(
  callback: (leaders: Leader[]) => void
): Unsubscribe {
  // Ordered client side: `priority` is missing on older rows, and an
  // orderBy would drop those documents from the result entirely.
  const q = query(collection(db, "leaders"), limit(50));

  return onSnapshot(
    q,
    (snap) => {
      callback(
        snap.docs
          .map((leaderDoc) => mapLeader(leaderDoc.id, leaderDoc.data()))
          .sort(
            (a, b) => a.priority - b.priority || a.name.localeCompare(b.name)
          )
      );
    },
    (error) => {
      console.warn("Leaders listener error:", error.message);
    }
  );
}

// --- Notifications ---

function mapNotification(id: string, d: DocumentData): AppNotification {
  return {
    id,
    title: (d.title as string) ?? "",
    body: (d.body as string) ?? "",
    type: (d.type as AppNotification["type"]) ?? "donation",
    source: (d.source as AppNotification["source"]) ?? "user",
    createdAt: toDate(d.createdAt),
  };
}

function sortNotificationsByCreatedAt(
  notifications: AppNotification[]
): AppNotification[] {
  const seen = new Set<string>();
  return [...notifications]
    .filter((n) => {
      if (seen.has(n.id)) return false;
      seen.add(n.id);
      return true;
    })
    .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
}

export function subscribeNotifications(
  callback: (notifications: AppNotification[]) => void
): Unsubscribe {
  const q = query(
    collection(db, "notifications"),
    orderBy("createdAt", "desc"),
    limit(200)
  );
  return onSnapshot(
    q,
    (snap) => {
      callback(
        sortNotificationsByCreatedAt(
          snap.docs.map((doc) => mapNotification(doc.id, doc.data()))
        )
      );
    },
    (error) => {
      console.warn("Notifications listener error:", error.message);
    }
  );
}

export function subscribeUserNotifications(
  callback: (notifications: AppNotification[]) => void
): Unsubscribe {
  const q = query(
    collection(db, "notifications"),
    where("source", "==", "user"),
    limit(100)
  );

  return onSnapshot(
    q,
    (snap) => {
      callback(
        sortNotificationsByCreatedAt(
          snap.docs.map((doc) => mapNotification(doc.id, doc.data()))
        )
      );
    },
    (error) => {
      console.error("Failed to subscribe to user notifications", error);
    }
  );
}

export async function createNotification(data: {
  title: string;
  body: string;
  type: AppNotification["type"];
}): Promise<void> {
  await addDoc(collection(db, "notifications"), {
    ...data,
    source: "admin",
    createdAt: serverTimestamp(),
  });
}

export async function deleteNotification(id: string): Promise<void> {
  await deleteDoc(doc(db, "notifications", id));
}
