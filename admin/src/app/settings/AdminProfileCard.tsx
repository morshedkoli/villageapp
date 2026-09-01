import { Mail, Shield, User as UserIcon } from "lucide-react";
import type { User } from "firebase/auth";
import { SectionCard } from "@/components/SectionCard";

function DetailRow({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof Mail;
  label: string;
  value: string | null;
}) {
  return (
    <div className="flex items-center gap-3 text-sm">
      <Icon className="w-4 h-4 text-text-muted" />
      <div>
        <p className="text-xs text-text-muted">{label}</p>
        <p className="text-text-primary font-medium">{value}</p>
      </div>
    </div>
  );
}

export function AdminProfileCard({ user }: { user: User }) {
  return (
    <SectionCard
      icon={Shield}
      iconClass="bg-secondary-light text-secondary"
      title="Admin Profile"
      description="Your account details"
      className="h-fit"
    >
      <div className="flex flex-col items-center text-center mb-6">
        {user.photoURL ? (
          <img
            src={user.photoURL}
            alt=""
            className="w-20 h-20 rounded-2xl mb-3 ring-4 ring-background"
            referrerPolicy="no-referrer"
          />
        ) : (
          <div className="w-20 h-20 rounded-2xl bg-primary text-white flex items-center justify-center text-2xl font-bold mb-3">
            {user.displayName?.charAt(0) || "A"}
          </div>
        )}
        <h3 className="text-lg font-semibold text-text-primary">
          {user.displayName}
        </h3>
        <span className="text-xs font-medium text-primary bg-primary-light px-2.5 py-1 rounded-lg mt-1">
          Administrator
        </span>
      </div>

      <div className="space-y-3 p-4 bg-background rounded-xl">
        <DetailRow
          icon={UserIcon}
          label="Display Name"
          value={user.displayName}
        />
        <DetailRow icon={Mail} label="Email" value={user.email} />
      </div>
    </SectionCard>
  );
}
