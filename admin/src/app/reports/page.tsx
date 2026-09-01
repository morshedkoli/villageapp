"use client";

import { useMemo, useState } from "react";
import { FileBarChart, FolderKanban, Receipt } from "lucide-react";
import {
  useDonations,
  useExpenses,
  useProjects,
  useVillageOverview,
} from "@/lib/hooks";
import { LoadingSkeleton } from "@/components/LoadingSkeleton";
import { csvBlob, downloadBlob } from "@/lib/csv";
import { buildPdf } from "@/lib/pdf";
import { formatBDT } from "@/lib/utils";
import { DateRangeFilter } from "./DateRangeFilter";
import { FundSummary } from "./FundSummary";
import { ReportCard } from "./ReportCard";
import {
  availableMonths,
  dateSuffix,
  emptyRange,
  filterByDate,
  periodLine,
  sumBy,
  type DateRange,
} from "./report-data";

export default function ReportsPage() {
  const { data: overview, loading: overviewLoading } = useVillageOverview();
  const { data: donations, loading: donationsLoading } = useDonations();
  const { data: projects, loading: projectsLoading } = useProjects();
  const { data: expenses, loading: expensesLoading } = useExpenses();

  const [range, setRange] = useState<DateRange>(emptyRange);

  const months = useMemo(
    () => availableMonths(donations, projects, expenses),
    [donations, projects, expenses]
  );

  const loading =
    overviewLoading || donationsLoading || projectsLoading || expensesLoading;

  // Expenses store their timestamp as `date`; the shared filter works on
  // `createdAt`, so they are adapted once here.
  const datedExpenses = useMemo(
    () => expenses.map((expense) => ({ ...expense, createdAt: expense.date })),
    [expenses]
  );

  const filteredDonations = filterByDate(
    donations.filter((donation) => donation.status === "Approved"),
    range
  );
  const filteredProjects = filterByDate(projects, range);
  const filteredExpenses = filterByDate(datedExpenses, range);

  if (loading) return <LoadingSkeleton />;

  const totalDonations = sumBy(filteredDonations, (d) => d.amount);
  const totalExpenses = sumBy(filteredExpenses, (e) => e.amount);
  const totalProjectCost = sumBy(filteredProjects, (p) => p.estimatedCost);
  const totalAllocated = sumBy(filteredProjects, (p) => p.allocatedFunds);

  const suffix = dateSuffix(range);

  const downloadDonationCsv = () =>
    downloadBlob(
      csvBlob(
        ["Donor Name", "Amount", "Payment Method", "Date"],
        filteredDonations.map((donation) => [
          donation.donorName,
          donation.amount,
          donation.paymentMethod,
          donation.createdAt.toLocaleDateString(),
        ])
      ),
      `village-donations-report${suffix}.csv`
    );

  const downloadExpenseCsv = () =>
    downloadBlob(
      csvBlob(
        ["Project / Title", "Category", "Amount", "Notes", "Date"],
        filteredExpenses.map((expense) => [
          expense.project,
          expense.category,
          expense.amount,
          expense.notes ?? "",
          expense.date.toLocaleDateString(),
        ])
      ),
      `village-expenses-report${suffix}.csv`
    );

  const downloadProjectCsv = () =>
    downloadBlob(
      csvBlob(
        ["Project", "Status", "Estimated Cost", "Allocated Funds"],
        filteredProjects.map((project) => [
          project.title,
          project.status,
          project.estimatedCost,
          project.allocatedFunds,
        ])
      ),
      `village-projects-report${suffix}.csv`
    );

  const downloadDonationPdf = () =>
    downloadBlob(
      buildPdf([
        "Village Donation Report",
        "",
        periodLine(range),
        `Total Donations: ${filteredDonations.length}`,
        `Total Amount: ${formatBDT(totalDonations)}`,
        "",
        "Donations",
        ...filteredDonations.map(
          (donation, index) =>
            `${index + 1}. ${donation.donorName} | ${formatBDT(
              donation.amount
            )} | ${donation.paymentMethod} | ${donation.createdAt.toLocaleDateString()}`
        ),
      ]),
      `village-donations-report${suffix}.pdf`
    );

  const downloadExpensePdf = () =>
    downloadBlob(
      buildPdf([
        "Village Expense Report",
        "",
        periodLine(range),
        `Total Entries: ${filteredExpenses.length}`,
        `Total Expenses: ${formatBDT(totalExpenses)}`,
        "",
        "Expenses",
        ...filteredExpenses.map(
          (expense, index) =>
            `${index + 1}. ${expense.project} | ${expense.category} | ${formatBDT(
              expense.amount
            )} | ${expense.date.toLocaleDateString()}`
        ),
      ]),
      `village-expenses-report${suffix}.pdf`
    );

  const downloadProjectPdf = () =>
    downloadBlob(
      buildPdf([
        "Village Project Report",
        "",
        periodLine(range),
        `Total Projects: ${filteredProjects.length}`,
        `Total Estimated Cost: ${formatBDT(totalProjectCost)}`,
        `Total Allocated Funds: ${formatBDT(totalAllocated)}`,
        "",
        "Projects",
        ...filteredProjects.map(
          (project, index) =>
            `${index + 1}. ${project.title} | ${project.status} | Estimated ${formatBDT(
              project.estimatedCost
            )} | Allocated ${formatBDT(project.allocatedFunds)}`
        ),
      ]),
      `village-projects-report${suffix}.pdf`
    );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text-primary">Reports</h1>
        <p className="text-sm text-text-secondary mt-1">
          Generate and download transparency reports
        </p>
      </div>

      <FundSummary overview={overview} projectCount={projects.length} />

      <DateRangeFilter range={range} months={months} onChange={setRange} />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <ReportCard
          icon={FileBarChart}
          iconClass="bg-success-light text-success"
          title="Donation Report"
          subtitle={`${filteredDonations.length} donations · ${formatBDT(
            totalDonations
          )}`}
          description="Download a detailed list of donations with donor names, amounts, payment methods, and dates."
          onDownloadCsv={downloadDonationCsv}
          onDownloadPdf={downloadDonationPdf}
        />
        <ReportCard
          icon={Receipt}
          iconClass="bg-danger-light text-danger"
          title="Expense Report"
          subtitle={`${filteredExpenses.length} expenses · ${formatBDT(
            totalExpenses
          )}`}
          description="Download a summary of all village expenses with projects, categories, notes, and timestamps."
          onDownloadCsv={downloadExpenseCsv}
          onDownloadPdf={downloadExpensePdf}
        />
        <ReportCard
          icon={FolderKanban}
          iconClass="bg-secondary-light text-secondary"
          title="Project Report"
          subtitle={`${filteredProjects.length} projects · ${formatBDT(
            totalAllocated
          )} allocated`}
          description="Download a summary of all projects with current statuses, estimated costs, and allocated funds."
          onDownloadCsv={downloadProjectCsv}
          onDownloadPdf={downloadProjectPdf}
        />
      </div>
    </div>
  );
}
