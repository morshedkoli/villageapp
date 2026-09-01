import { apiClient, errorMessage } from "./api-client";

export async function sendPushNotification({
  title,
  body,
  type,
}: {
  title: string;
  body: string;
  type: string;
}): Promise<{ success: boolean; error?: string }> {
  try {
    await apiClient.post("/api/push", { title, body, type });
    return { success: true };
  } catch (err) {
    console.error("Firebase push request error:", err);
    return {
      success: false,
      error: errorMessage(err, "Push notification failed"),
    };
  }
}
