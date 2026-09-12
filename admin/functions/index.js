const functions = require('firebase-functions');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const BROADCAST_TOPIC = 'village_broadcast';

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * The only `type` values a notification doc may carry. Shared vocabulary with
 * `notificationTypeSchema` in src/lib/schemas.ts and the Android client — a
 * value outside this set renders as an unknown category in both.
 *
 * The finer-grained kind of event ('donation_approved', 'problem_status', …)
 * travels in the `event` field instead, where nothing has to understand it.
 */
const CATEGORIES = [
  'donation',
  'problem',
  'citizen',
  'project',
  'general',
  'registration',
];

/**
 * Notification channels created by the Android client
 * (PushNotificationManager). An id the device does not have silently drops the
 * notification on API 26+, so every category must map to a real channel.
 */
const CHANNEL_BY_CATEGORY = {
  donation: 'village_donations',
  problem: 'village_problems',
  project: 'village_projects',
  citizen: 'village_broadcast',
  registration: 'village_broadcast',
  general: 'village_broadcast',
};

/**
 * Bootstrap admin address. Kept in sync by hand with
 * DEFAULT_BOOTSTRAP_ADMIN_EMAILS in src/lib/admin-access.ts and
 * `isBootstrapAdmin()` in firestore.rules — all three deploy separately.
 */
const BOOTSTRAP_ADMIN_EMAILS = ['murshedkoli@gmail.com'];

/**
 * Same three-way check the admin panel's `verifyAdmin` performs: custom claim,
 * bootstrap address, then the `admins` collection. Checking only the custom
 * claim locked out every admin who was added through the panel.
 */
async function isAdminUser(uid) {
  const user = await admin.auth().getUser(uid);
  if (user.customClaims && user.customClaims.admin === true) return true;

  const email = (user.email || '').trim().toLowerCase();
  if (!email) return false;
  if (BOOTSTRAP_ADMIN_EMAILS.includes(email)) return true;

  const adminDoc = await admin.firestore().collection('admins').doc(email).get();
  return adminDoc.exists;
}

function normalizeCategory(category) {
  const value = String(category || 'general');
  return CATEGORIES.includes(value) ? value : 'general';
}

/**
 * Send an FCM push to the shared broadcast topic (all subscribed devices).
 */
async function sendBroadcastPush({ title, body, type = 'general', data = {} }) {
  const category = normalizeCategory(type);
  const payload = {
    type: category,
    title: String(title),
    body: String(body),
    ...Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v ?? '')])
    ),
  };

  return admin.messaging().send({
    topic: BROADCAST_TOPIC,
    notification: { title: payload.title, body: payload.body },
    data: payload,
    android: {
      priority: 'high',
      notification: { channelId: CHANNEL_BY_CATEGORY[category] },
    },
    apns: { payload: { aps: { sound: 'default' } } },
  });
}

/**
 * Write a notification doc to Firestore. `onNotificationCreatedSendPush` picks
 * it up and is the single place a push is sent — nothing here sends one
 * directly, or every event would reach devices twice.
 */
async function broadcastNotification({
  title,
  body,
  type = 'general',
  event = '',
  data = {},
}) {
  const trimTitle = String(title).trim();
  const trimBody  = String(body).trim();
  if (!trimTitle && !trimBody) return;

  const firestoreData = {
    type: normalizeCategory(type),
    event: String(event || type || 'general'),
    title: trimTitle,
    body:  trimBody,
    source: 'admin',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Extra data fields stored on the doc for deep-linking
  Object.entries(data).forEach(([k, v]) => {
    if (v !== undefined && v !== null) firestoreData[k] = String(v);
  });

  await admin.firestore().collection('notifications').add(firestoreData);
}

// ─────────────────────────────────────────────────────────────────────────────
// FAN-OUT: every notification doc → push to all devices
// ─────────────────────────────────────────────────────────────────────────────

exports.onNotificationCreatedSendPush = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap) => {
    const n     = snap.data() || {};
    const title = (n.title || '').toString();
    const body  = (n.body  || '').toString();
    const type  = (n.type  || 'general').toString();

    if (!title && !body) return;

    try {
      const msgId = await sendBroadcastPush({
        title, body, type,
        data: { notificationId: snap.id },
      });
      console.log('[push] sent:', msgId, '|', title);
    } catch (err) {
      console.error('[push] failed:', err.message);
    }
  });

// ─────────────────────────────────────────────────────────────────────────────
// DONATIONS
// ─────────────────────────────────────────────────────────────────────────────

/** User submits a new donation (Pending) */
exports.onDonationSubmittedNotifyAll = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snap, context) => {
    const d = snap.data() || {};
    const donorName  = (d.donorName  || 'একজন নাগরিক').toString();
    const amount     = Number(d.amount || 0);
    const amountText = Number.isFinite(amount) ? amount.toFixed(0) : '0';

    await broadcastNotification({
      title: '💰 নতুন অনুদান জমা পড়েছে',
      body:  `${donorName} ৳${amountText} অনুদান দিতে চান — অনুমোদনের অপেক্ষায়`,
      type:  'donation',
      event: 'donation_pending',
      data:  { donationId: context.params.donationId },
    });
  });

/** Admin approves a donation */
exports.onDonationApprovedNotifyAll = functions.firestore
  .document('donations/{donationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after  = change.after.data()  || {};

    if (before.status === after.status) return;

    const donorName  = (after.donorName || 'একজন নাগরিক').toString();
    const amount     = Number(after.amount || 0);
    const amountText = Number.isFinite(amount) ? amount.toFixed(0) : '0';

    if (after.status === 'Approved') {
      await broadcastNotification({
        title: '✅ অনুদান অনুমোদিত হয়েছে',
        body:  `${donorName}-এর ৳${amountText} অনুদান অনুমোদন করা হয়েছে`,
        type:  'donation',
        event: 'donation_approved',
        data:  { donationId: context.params.donationId },
      });
    } else if (after.status === 'Rejected') {
      await broadcastNotification({
        title: '❌ অনুদান বাতিল হয়েছে',
        body:  `${donorName}-এর ৳${amountText} অনুদান বাতিল করা হয়েছে`,
        type:  'donation',
        event: 'donation_rejected',
        data:  { donationId: context.params.donationId },
      });
    }
  });

// ─────────────────────────────────────────────────────────────────────────────
// PROBLEM REPORTS
// ─────────────────────────────────────────────────────────────────────────────

/** User submits a new problem report */
exports.onProblemSubmittedNotifyAll = functions.firestore
  .document('problems/{problemId}')
  .onCreate(async (snap, context) => {
    const p           = snap.data() || {};
    const titleText   = (p.title          || 'নতুন সমস্যা').toString();
    const reporter    = (p.reportedByName || 'একজন নাগরিক').toString();
    const location    = (p.location       || '').toString();
    const locationPart = location ? ` (${location})` : '';

    await broadcastNotification({
      title: '🚨 নতুন সমস্যা রিপোর্ট',
      body:  `${reporter} "${titleText}"${locationPart} সমস্যা রিপোর্ট করেছেন`,
      type:  'problem',
      event: 'problem_submitted',
      data:  { problemId: context.params.problemId },
    });
  });

/** Admin changes problem status */
exports.onProblemStatusChangedNotifyAll = functions.firestore
  .document('problems/{problemId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after  = change.after.data()  || {};

    if (before.status === after.status) return;

    const titleText = (after.title || 'সমস্যা').toString();
    const status    = (after.status || '').toString();

    // The only statuses a problem can hold — see `problemStatusSchema` in
    // src/lib/schemas.ts and firestore.rules. 'Resolved'/'In Progress' used to
    // be listed here and never fired; 'Completed', which does happen, was
    // missing, so finishing a problem announced nothing.
    const statusMap = {
      'Pending':   { emoji: '🕒', label: 'অপেক্ষমাণ' },
      'Approved':  { emoji: '📋', label: 'অনুমোদিত হয়েছে' },
      'Completed': { emoji: '✅', label: 'সমাধান হয়েছে' },
    };

    const info = statusMap[status];
    if (!info) return; // ignore unknown status changes

    await broadcastNotification({
      title: `${info.emoji} সমস্যার আপডেট`,
      body:  `"${titleText}" — ${info.label}`,
      type:  'problem',
      event: 'problem_status',
      data:  { problemId: context.params.problemId, status },
    });
  });

// ─────────────────────────────────────────────────────────────────────────────
// DEVELOPMENT PROJECTS
// ─────────────────────────────────────────────────────────────────────────────

/** Admin creates a new project */
exports.onProjectCreatedNotifyAll = functions.firestore
  .document('projects/{projectId}')
  .onCreate(async (snap, context) => {
    const p         = snap.data() || {};
    const titleText = (p.title || 'নতুন প্রকল্প').toString();
    const cost      = Number(p.estimatedCost || 0);
    const costText  = Number.isFinite(cost) && cost > 0 ? ` (অনুমানিত ৳${cost.toFixed(0)})` : '';

    await broadcastNotification({
      title: '🏗️ নতুন উন্নয়ন প্রকল্প',
      body:  `"${titleText}"${costText} প্রকল্প যোগ করা হয়েছে`,
      type:  'project',
      event: 'project_created',
      data:  { projectId: context.params.projectId },
    });
  });

/** Admin updates project status */
exports.onProjectStatusChangedNotifyAll = functions.firestore
  .document('projects/{projectId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after  = change.after.data()  || {};

    if (before.status === after.status) return;

    const titleText = (after.title  || 'প্রকল্প').toString();
    const status    = (after.status || '').toString();

    // Matches `createProjectSchema.status` in src/lib/schemas.ts. 'On Hold'
    // and 'Cancelled' are not statuses this system can produce.
    const statusMap = {
      'Planning':     { emoji: '📝', label: 'পরিকল্পনা পর্যায়ে' },
      'In Progress':  { emoji: '🔨', label: 'নির্মাণ কাজ চলছে' },
      'Completed':    { emoji: '🎉', label: 'সম্পন্ন হয়েছে' },
    };

    const info = statusMap[status];
    if (!info) return;

    await broadcastNotification({
      title: `${info.emoji} প্রকল্পের আপডেট`,
      body:  `"${titleText}" — ${info.label}`,
      type:  'project',
      event: 'project_status',
      data:  { projectId: context.params.projectId, status },
    });
  });

/** Admin adds a project update/progress note */
exports.onProjectUpdatedNotifyAll = functions.firestore
  .document('projects/{projectId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after  = change.after.data()  || {};

    // Only fire when a new update string is appended to the updates array
    const beforeUpdates = (before.updates || []).length;
    const afterUpdates  = (after.updates  || []).length;
    if (afterUpdates <= beforeUpdates) return;

    const titleText  = (after.title || 'প্রকল্প').toString();
    const latestNote = (after.updates[afterUpdates - 1] || '').toString();
    const noteSnippet = latestNote.length > 60
      ? latestNote.substring(0, 57) + '...'
      : latestNote;

    await broadcastNotification({
      title: '📢 প্রকল্পের নতুন আপডেট',
      body:  `"${titleText}": ${noteSnippet}`,
      type:  'project',
      event: 'project_update',
      data:  { projectId: context.params.projectId },
    });
  });

// ─────────────────────────────────────────────────────────────────────────────
// CITIZEN / USER REGISTRATION
// ─────────────────────────────────────────────────────────────────────────────

/** New user registers (Google sign-in or email) */
exports.onCitizenRegisteredNotifyAll = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data() || {};
    const name = (user.name || user.displayName || 'নতুন নাগরিক').toString();
    const isCitizen = user.isCitizen !== false;

    // Auto-increment totalCitizens count on main village doc if citizen
    if (isCitizen) {
      try {
        await admin
          .firestore()
          .collection('villages')
          .doc('main_village')
          .set(
            { totalCitizens: admin.firestore.FieldValue.increment(1) },
            { merge: true }
          );
      } catch (err) {
        console.error('[counter] failed to increment totalCitizens:', err.message);
      }
    }

    await broadcastNotification({
      title: '👤 নতুন নাগরিক যোগ হয়েছে',
      body:  `${name} গ্রামের অ্যাপে যোগ দিয়েছেন`,
      type:  'registration',
      data:  { userId: context.params.userId },
    });
  });

/** User deleted - adjust totalCitizens count */
exports.onCitizenDeletedAdjustCount = functions.firestore
  .document('users/{userId}')
  .onDelete(async (snap) => {
    const user = snap.data() || {};
    const isCitizen = user.isCitizen !== false;

    if (isCitizen) {
      try {
        await admin
          .firestore()
          .collection('villages')
          .doc('main_village')
          .set(
            { totalCitizens: admin.firestore.FieldValue.increment(-1) },
            { merge: true }
          );
      } catch (err) {
        console.error('[counter] failed to decrement totalCitizens:', err.message);
      }
    }
  });

/** Citizen status updated (isCitizen toggle) */
exports.onCitizenStatusUpdatedAdjustCount = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    const wasCitizen = before.isCitizen === true;
    const isNowCitizen = after.isCitizen === true;

    if (wasCitizen === isNowCitizen) return;

    const delta = isNowCitizen ? 1 : -1;
    try {
      await admin
        .firestore()
        .collection('villages')
        .doc('main_village')
        .set(
          { totalCitizens: admin.firestore.FieldValue.increment(delta) },
          { merge: true }
        );
    } catch (err) {
      console.error('[counter] failed to adjust totalCitizens on update:', err.message);
    }
  });

// ─────────────────────────────────────────────────────────────────────────────
// FUND TRANSACTIONS (spending)
// ─────────────────────────────────────────────────────────────────────────────

/** Admin records a fund expenditure */
exports.onFundTransactionCreatedNotifyAll = functions.firestore
  .document('fund_transactions/{txId}')
  .onCreate(async (snap, context) => {
    const tx        = snap.data() || {};
    const type      = (tx.type      || 'expense').toString();
    const amount    = Number(tx.amount || 0);
    const ref       = (tx.reference || '').toString();
    const amountText = Number.isFinite(amount) ? amount.toFixed(0) : '0';

    if (type === 'donation') return; // already notified via donation trigger

    const refPart = ref ? ` — ${ref}` : '';

    await broadcastNotification({
      title: '💸 তহবিল ব্যয়',
      body:  `৳${amountText} ব্যয় রেকর্ড করা হয়েছে${refPart}`,
      type:  'general',
      event: 'fund_transaction',
      data:  { txId: context.params.txId },
    });
  });

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN: MANUAL BROADCAST (callable)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Admin can send a custom push from the admin panel.
 * Requires auth + admin custom claim.
 */
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'লগইন করুন।');
  }

  if (!(await isAdminUser(context.auth.uid))) {
    throw new functions.https.HttpsError('permission-denied', 'শুধুমাত্র অ্যাডমিনরা নোটিফিকেশন পাঠাতে পারবেন।');
  }

  const { title, body, type = 'general' } = data;
  if (!title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Title এবং body আবশ্যিক।');
  }

  try {
    await broadcastNotification({ title, body, type });
    return { success: true, topic: BROADCAST_TOPIC };
  } catch (err) {
    console.error('[manual push] failed:', err);
    throw new functions.https.HttpsError('internal', `পাঠানো ব্যর্থ: ${err.message}`);
  }
});
