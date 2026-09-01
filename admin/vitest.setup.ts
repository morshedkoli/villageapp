/**
 * Placeholder Firebase config for tests. `firebase-config.ts` fails fast on
 * missing env vars, and importing anything that reaches it (route handlers,
 * the API wrappers) would otherwise throw before a single test runs. Tests mock
 * the Firebase SDKs themselves, so the values only need to exist.
 */
const TEST_FIREBASE_ENV: Record<string, string> = {
  NEXT_PUBLIC_FIREBASE_API_KEY: "test-api-key",
  NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN: "test.firebaseapp.com",
  NEXT_PUBLIC_FIREBASE_PROJECT_ID: "test-project",
  NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET: "test.appspot.com",
  NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID: "000000000000",
  NEXT_PUBLIC_FIREBASE_APP_ID: "1:000000000000:web:test",
};

for (const [name, value] of Object.entries(TEST_FIREBASE_ENV)) {
  process.env[name] ??= value;
}
