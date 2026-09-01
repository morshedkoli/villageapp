/**
 * Fallback admin used before any admin exists in Firestore.
 *
 * Firestore security rules cannot read environment variables, so the same
 * address is hard-coded in `firestore.rules` (`isBootstrapAdmin`). Rules deploy
 * separately from this app — change both, or an account will be an admin in one
 * layer and not the other.
 */
const DEFAULT_BOOTSTRAP_ADMIN_EMAILS = ["murshedkoli@gmail.com"];

export function normalizeAdminEmail(email: string | null | undefined): string {
  return (email ?? "").trim().toLowerCase();
}

export function getBootstrapAdminEmails(): string[] {
  const envEmails = process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS;
  if (!envEmails) {
    return [...DEFAULT_BOOTSTRAP_ADMIN_EMAILS];
  }

  const parsed = envEmails
    .split(",")
    .map((e) => normalizeAdminEmail(e))
    .filter(Boolean);

  return parsed.length > 0 ? parsed : [...DEFAULT_BOOTSTRAP_ADMIN_EMAILS];
}

export function isBootstrapAdminEmail(email: string | null | undefined): boolean {
  const normalized = normalizeAdminEmail(email);
  if (!normalized) return false;
  return getBootstrapAdminEmails().includes(normalized);
}
