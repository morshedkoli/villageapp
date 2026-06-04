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
 * Send an FCM push to the shared broadcast topic (all subscribed devices).
 */
async function sendBroadcastPush({ title, body, type = 'general', data = {} }) {
  const payload = {
    type: String(type),
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
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default' } } },
  });
}

/**
 * Write a notification doc to Firestore (picked up by onNotificationCreatedSendPush)
 * AND send push immediately in parallel.
 */
async function broadcastNotification({ title, body, type = 'general', data = {} }) {
  const trimTitle = String(title).trim();
  const trimBody  = String(body).trim();
  if (!trimTitle && !trimBody) return;

  const firestoreData = {
    type: String(type),
    title: trimTitle,
    body:  trimBody,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Extra data fields stored on the doc for deep-linking
  Object.entries(data).forEach(([k, v]) => {
    if (v !== undefined && v !== null) firestoreData[k] = String(v);
  });

  // Write Firestore doc (triggers onNotificationCreatedSendPush for reliability)
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
      type:  'donation_pending',
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
        type:  'donation_approved',
        data:  { donationId: context.params.donationId },
      });
    } else if (after.status === 'Rejected') {
      await broadcastNotification({
        title: '❌ অনুদান বাতিল হয়েছে',
        body:  `${donorName}-এর ৳${amountText} অনুদান বাতিল করা হয়েছে`,
        type:  'donation_rejected',
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
      type:  'problem_submitted',
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

    const statusMap = {
      'In Progress':  { emoji: '🔧', label: 'কাজ চলছে' },
      'Resolved':     { emoji: '✅', label: 'সমাধান হয়েছে' },
      'Rejected':     { emoji: '❌', label: 'বাতিল করা হয়েছে' },
      'Approved':     { emoji: '📋', label: 'অনুমোদিত হয়েছে' },
    };

    const info = statusMap[status];
    if (!info) return; // ignore unknown status changes

    await broadcastNotification({
      title: `${info.emoji} সমস্যার আপডেট`,
      body:  `"${titleText}" — ${info.label}`,
      type:  'problem_status',
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
      type:  'project_created',
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

    const statusMap = {
      'Planning':     { emoji: '📝', label: 'পরিকল্পনা পর্যায়ে' },
      'In Progress':  { emoji: '🔨', label: 'নির্মাণ কাজ চলছে' },
      'Completed':    { emoji: '🎉', label: 'সম্পন্ন হয়েছে' },
      'On Hold':      { emoji: '⏸️', label: 'স্থগিত রাখা হয়েছে' },
      'Cancelled':    { emoji: '🚫', label: 'বাতিল করা হয়েছে' },
    };

    const info = statusMap[status];
    if (!info) return;

    await broadcastNotification({
      title: `${info.emoji} প্রকল্পের আপডেট`,
      body:  `"${titleText}" — ${info.label}`,
      type:  'project_status',
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
      type:  'project_update',
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

    await broadcastNotification({
      title: '👤 নতুন নাগরিক যোগ হয়েছে',
      body:  `${name} গ্রামের অ্যাপে যোগ দিয়েছেন`,
      type:  'registration',
      data:  { userId: context.params.userId },
    });
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
      type:  'fund_transaction',
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

  const user = await admin.auth().getUser(context.auth.uid);
  if (!user.customClaims || !user.customClaims.admin) {
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
