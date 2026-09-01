import { NextResponse } from "next/server";
import { getAdminMessaging } from "@/lib/firebase-admin";
import { withAdminRoute, parseJsonBody } from "@/lib/api-handler";
import { pushNotificationSchema } from "@/lib/schemas";

export const POST = withAdminRoute(async (req) => {
  const { title, body, type } = await parseJsonBody(req, pushNotificationSchema);

  const messageId = await getAdminMessaging().send({
    topic: "village_broadcast",
    notification: { title, body },
    data: { type, title, body },
    android: {
      priority: "high",
      notification: { channelId: "default" },
    },
  });

  return NextResponse.json({ success: true, messageId });
});
