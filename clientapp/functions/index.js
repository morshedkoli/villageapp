const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const BROADCAST_TOPIC = 'village_broadcast';

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
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload,
    android: {
      priority: 'high',
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
        },
      },
    },
  });
}

/**
 * Writes a notification doc that will be picked up by the push fanout trigger.
 */
async function broadcastNotification({ title, body, type = 'general', data = {} }) {
  const payload = {
    type: String(type),
    title: String(title),
    body: String(body),
    ...Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v ?? '')])
    ),
  };

  await admin.firestore().collection('notifications').add({
    type: payload.type,
    title: payload.title,
    body: payload.body,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return payload;
}

/**
 * Sends an FCM notification to every app instance subscribed to the
 * shared village topic.
 */
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const user = await admin.auth().getUser(context.auth.uid);
  if (!user.customClaims || !user.customClaims.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin privileges required.');
  }

  const { title, body, type = 'general' } = data;

  if (!title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Title and body are required.');
  }

  try {
    const notification = await broadcastNotification({
      title,
      body,
      type,
    });

    console.log('Firebase push queued:', notification);
    return {
      success: true,
      queued: true,
      topic: BROADCAST_TOPIC,
    };
  } catch (error) {
    console.error('Firebase push failed:', error);
    throw new functions.https.HttpsError('internal', `Failed to send push notification: ${error.message}`);
  }
});

/**
 * Notify all users when a donation is approved by admin.
 * Triggers on status change from any state to 'Approved'.
 */
exports.onDonationApprovedNotifyAll = functions.firestore
  .document('donations/{donationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    // Only fire when status changes to 'Approved'
    if (before.status === after.status || after.status !== 'Approved') {
      return;
    }

    const donorName = (after.donorName || 'A citizen').toString();
    const amount = Number(after.amount || 0);
    const amountText = Number.isFinite(amount) ? amount.toFixed(0) : '0';

    const title = 'নতুন অনুদান';
    const body = `${donorName} ৳${amountText} অনুদান দিয়েছেন`;

    try {
      const notification = await broadcastNotification({
        title,
        body,
        type: 'donation',
        data: {
          donationId: context.params.donationId,
        },
      });
      console.log('Donation approved notification queued:', notification);
    } catch (error) {
      console.error('Failed to notify donation approval:', error);
    }
  });

/**
 * Notify all users when a problem report is approved by admin.
 * Triggers on status change from any state to 'Approved'.
 */
exports.onProblemApprovedNotifyAll = functions.firestore
  .document('problems/{problemId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};

    // Only fire when status changes to 'Approved'
    if (before.status === after.status || after.status !== 'Approved') {
      return;
    }

    const titleText = (after.title || 'New issue reported').toString();
    const reporterName = (after.reportedByName || 'A citizen').toString();

    const title = 'নতুন সমস্যা রিপোর্ট';
    const body = `${reporterName} "${titleText}" সমস্যা রিপোর্ট করেছেন`;

    try {
      const notification = await broadcastNotification({
        title,
        body,
        type: 'problem',
        data: {
          problemId: context.params.problemId,
        },
      });
      console.log('Problem approved notification queued:', notification);
    } catch (error) {
      console.error('Failed to notify problem approval:', error);
    }
  });

/**
 * Notify all users when a new development project is created.
 */
exports.onProjectCreatedNotifyAll = functions.firestore
  .document('projects/{projectId}')
  .onCreate(async (snap, context) => {
    const project = snap.data() || {};
    const titleText = (project.title || 'New project').toString();

    const title = 'নতুন প্রকল্প';
    const body = `"${titleText}" প্রকল্প যোগ করা হয়েছে`;

    try {
      const notification = await broadcastNotification({
        title,
        body,
        type: 'project',
        data: {
          projectId: context.params.projectId,
        },
      });
      console.log('Project notification queued:', notification);
    } catch (error) {
      console.error('Failed to notify project creation:', error);
    }
  });

/**
 * Notify all users when a new citizen registers.
 */
exports.onCitizenRegisteredNotifyAll = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const user = snap.data() || {};
    const isCitizen = user.isCitizen !== false;

    if (!isCitizen) {
      return;
    }

    const name = (user.name || user.displayName || 'A new citizen').toString();
    const title = 'নতুন নাগরিক যোগ হয়েছে';
    const body = `${name} গ্রামে যোগদান করেছেন`;

    try {
      const notification = await broadcastNotification({
        title,
        body,
        type: 'registration',
        data: {
          userId: context.params.userId,
        },
      });
      console.log('Citizen registration notification queued:', notification);
    } catch (error) {
      console.error('Failed to notify citizen registration:', error);
    }
  });

/**
 * Fan out every notification document as a push notification.
 * This keeps Firestore-created notifications and push delivery in sync.
 */
exports.onNotificationCreatedSendPush = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap) => {
    const notification = snap.data() || {};
    const title = (notification.title || '').toString();
    const body = (notification.body || '').toString();
    const type = (notification.type || 'general').toString();

    if (!title && !body) {
      return;
    }

    try {
      const messageId = await sendBroadcastPush({
        title,
        body,
        type,
        data: {
          notificationId: snap.id,
        },
      });
      console.log('Notification push sent:', messageId);
    } catch (error) {
      console.error('Failed to send notification push:', error);
    }
  });
