import type { Firestore } from "firebase-admin/firestore";

/**
 * Single village document every aggregate counter lives on
 * (`totalFundCollected`, `totalSpent`, `totalCitizens`, `paymentAccounts`).
 */
export const VILLAGE_DOC_ID = "main_village";

export function villageRef(db: Firestore) {
  return db.collection("villages").doc(VILLAGE_DOC_ID);
}
