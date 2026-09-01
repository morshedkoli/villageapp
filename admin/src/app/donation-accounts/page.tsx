"use client";

import { AlertCircle, CreditCard, Plus } from "lucide-react";
import { ConfirmDialog } from "@/components/ConfirmDialog";
import { AccountCard } from "./AccountCard";
import { AccountEditorModal } from "./AccountEditorModal";
import { IncompleteAccountsList } from "./IncompleteAccountsList";
import { isAccountComplete } from "./account-types";
import { usePaymentAccountEditor } from "./usePaymentAccountEditor";

function PageHeader({ children }: { children?: React.ReactNode }) {
  return (
    <div className="bg-white border-b border-border">
      <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="flex items-center justify-between gap-4 mb-3">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#FF9500] to-[#FF7A00] flex items-center justify-center shadow-lg">
              <CreditCard className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-text-primary">
                Donation Accounts
              </h1>
              <p className="text-sm text-text-muted mt-1">
                Available payment methods for donations
              </p>
            </div>
          </div>
          {children}
        </div>
      </div>
    </div>
  );
}

function LoadingState() {
  return (
    <div className="min-h-screen bg-background">
      <div className="bg-white border-b border-border">
        <div className="max-w-4xl mx-auto px-6 py-8">
          <div className="flex items-center gap-4 mb-3">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#FF9500] to-[#FF7A00] flex items-center justify-center shadow-lg">
              <CreditCard className="w-6 h-6 text-white" />
            </div>
            <div>
              <div className="animate-shimmer h-8 rounded-lg w-64 mb-2" />
              <div className="animate-shimmer h-4 rounded-lg w-48" />
            </div>
          </div>
        </div>
      </div>
      <div className="max-w-4xl mx-auto px-6 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {[...Array(4)].map((_, index) => (
            <div key={index} className="animate-shimmer h-64 rounded-2xl" />
          ))}
        </div>
      </div>
    </div>
  );
}

export default function DonationAccountsPage() {
  const editor = usePaymentAccountEditor();

  if (editor.loading) return <LoadingState />;

  const activeAccounts = editor.accounts.filter(isAccountComplete);
  const incompleteAccounts = editor.accounts.filter(
    (account) => !isAccountComplete(account)
  );

  return (
    <div className="min-h-screen bg-background">
      <PageHeader>
        <button
          onClick={editor.startAdd}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium bg-primary text-white hover:bg-primary/90 transition-all shadow-sm"
        >
          <Plus className="w-5 h-5" />
          <span className="hidden sm:inline">Add Account</span>
        </button>
      </PageHeader>

      <div className="max-w-4xl mx-auto px-6 py-8">
        {activeAccounts.length === 0 ? (
          <div className="bg-white rounded-2xl border border-border p-12 text-center">
            <div className="w-16 h-16 rounded-2xl bg-orange-50 flex items-center justify-center mx-auto mb-4">
              <AlertCircle className="w-8 h-8 text-orange-500" />
            </div>
            <h3 className="text-lg font-semibold text-text-primary mb-2">
              No Active Accounts
            </h3>
            <p className="text-sm text-text-muted max-w-md mx-auto">
              No donation accounts are currently configured. Please contact the
              administrator to add payment accounts.
            </p>
          </div>
        ) : (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {activeAccounts.map((account) => (
                <AccountCard
                  key={account.id}
                  account={account}
                  onEdit={editor.startEdit}
                  onDelete={editor.setPendingDelete}
                />
              ))}
            </div>

            <IncompleteAccountsList
              accounts={incompleteAccounts}
              onEdit={editor.startEdit}
              onDelete={editor.setPendingDelete}
            />
          </>
        )}

        <div className="mt-8 bg-blue-50 border border-blue-200 rounded-2xl p-6">
          <div className="flex gap-3">
            <div className="flex-shrink-0">
              <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                <AlertCircle className="w-5 h-5 text-blue-600" />
              </div>
            </div>
            <div>
              <h4 className="text-sm font-semibold text-blue-900 mb-1">
                How to Donate
              </h4>
              <p className="text-sm text-blue-700 leading-relaxed">
                Send your donation to any of the active accounts shown above.
                Make sure to use the correct account number and holder name.
                After sending, please submit your donation details through the
                app for verification.
              </p>
            </div>
          </div>
        </div>
      </div>

      <AccountEditorModal
        account={editor.editing}
        isNew={editor.isNewAccount}
        saving={editor.saving}
        error={editor.error}
        onChange={editor.updateEditingField}
        onSave={editor.saveEditing}
        onClose={editor.closeEditor}
      />

      <ConfirmDialog
        open={editor.pendingDelete !== null}
        title="Delete Donation Account"
        message={`Are you sure you want to delete the ${
          editor.pendingDelete?.type?.toUpperCase() ?? "Payment"
        } account "${editor.pendingDelete?.number}" (${
          editor.pendingDelete?.name
        })?`}
        variant="danger"
        confirmLabel="Delete Account"
        loadingLabel="Deleting..."
        onConfirm={editor.confirmDelete}
        onCancel={() => editor.setPendingDelete(null)}
      />
    </div>
  );
}
