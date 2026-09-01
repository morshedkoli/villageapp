import { Bell } from "lucide-react";
import { SectionCard } from "@/components/SectionCard";

/** Explains where push delivery happens; no configuration lives in the UI. */
export function PushNotificationsCard() {
  return (
    <SectionCard
      icon={Bell}
      iconClass="bg-[#E8F5FF] text-[#0073E6]"
      title="Push Notifications (Firebase)"
      description="Firebase Cloud Messaging is handled server-side with the Firebase Admin SDK"
    >
      <div className="bg-background rounded-xl p-4 text-sm text-text-secondary space-y-2">
        <p>
          Admin broadcasts use Firebase Cloud Messaging (FCM) via the Firebase
          Admin SDK.
        </p>
        <p className="text-xs text-text-muted">
          Client apps subscribe to the{" "}
          <code className="font-mono bg-white px-1.5 py-0.5 rounded border border-border text-primary font-semibold">
            village_broadcast
          </code>{" "}
          topic to receive real-time admin notifications.
        </p>
      </div>
    </SectionCard>
  );
}
