This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Firebase backend

This directory owns the whole Firebase side of the project — the native Android
client and this panel talk to the same database, Storage bucket and functions:

| File | What it covers |
| --- | --- |
| `firestore.rules` | Firestore security rules |
| `firestore.indexes.json` | Composite indexes |
| `storage.rules` | Cloud Storage rules |
| `functions/` | Push-notification fanout (Firestore triggers + a callable) |

Deploy all of it, or one piece at a time:

```bash
firebase deploy
firebase deploy --only firestore
firebase deploy --only storage
firebase deploy --only functions
```

Nothing else in the repo should carry a second copy of these. They used to live
partly under `clientapp/`, which was removed when the Flutter client was retired
in favour of `android-native/`.

Note that `isBootstrapAdmin()` in `firestore.rules` hardcodes the bootstrap
admin address, because rules cannot read environment variables. It must be kept
in sync by hand with `DEFAULT_BOOTSTRAP_ADMIN_EMAILS` in
`src/lib/admin-access.ts`.
