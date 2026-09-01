import { describe, it, expect } from "vitest";
import type { ExpenseEntry } from "@/lib/models";
import {
  categoryIcon,
  emptyExpenseForm,
  matchesExpenseSearch,
  totalsByCategory,
  validateExpenseForm,
} from "./expense-ui";

function expense(overrides: Partial<ExpenseEntry> = {}): ExpenseEntry {
  return {
    id: "e1",
    project: "Road Repair",
    category: "Materials",
    amount: 100,
    date: new Date("2026-01-01"),
    notes: "",
    ...overrides,
  };
}

describe("validateExpenseForm", () => {
  it("requires a project title", () => {
    expect(
      validateExpenseForm({ ...emptyExpenseForm, amount: "100" })
    ).toBe("Project or expense title is required.");
  });

  it("rejects a zero, negative or non-numeric amount", () => {
    const base = { ...emptyExpenseForm, project: "Road" };
    const message = "Enter a valid amount greater than zero.";
    expect(validateExpenseForm({ ...base, amount: "0" })).toBe(message);
    expect(validateExpenseForm({ ...base, amount: "-5" })).toBe(message);
    expect(validateExpenseForm({ ...base, amount: "lots" })).toBe(message);
    expect(validateExpenseForm({ ...base, amount: "" })).toBe(message);
  });

  it("passes a complete form", () => {
    expect(
      validateExpenseForm({
        ...emptyExpenseForm,
        project: "Road",
        amount: "500",
      })
    ).toBeNull();
  });
});

describe("matchesExpenseSearch", () => {
  it("matches everything on an empty query", () => {
    expect(matchesExpenseSearch(expense(), "")).toBe(true);
  });

  it("matches project, category and notes case-insensitively", () => {
    const entry = expense({ notes: "Bought cement" });
    expect(matchesExpenseSearch(entry, "ROAD")).toBe(true);
    expect(matchesExpenseSearch(entry, "materials")).toBe(true);
    expect(matchesExpenseSearch(entry, "cement")).toBe(true);
  });

  it("rejects a non-match", () => {
    expect(matchesExpenseSearch(expense(), "bridge")).toBe(false);
  });

  it("handles a missing notes field", () => {
    expect(matchesExpenseSearch(expense({ notes: undefined }), "road")).toBe(
      true
    );
  });
});

describe("totalsByCategory", () => {
  it("sums amounts per category", () => {
    const totals = totalsByCategory([
      expense({ id: "1", category: "Materials", amount: 100 }),
      expense({ id: "2", category: "Labor", amount: 50 }),
      expense({ id: "3", category: "Materials", amount: 25 }),
    ]);

    expect(totals).toEqual([
      { category: "Materials", amount: 125 },
      { category: "Labor", amount: 50 },
    ]);
  });

  it("returns nothing for no expenses", () => {
    expect(totalsByCategory([])).toEqual([]);
  });
});

describe("categoryIcon", () => {
  it("falls back to a generic icon for an unknown category", () => {
    expect(categoryIcon("Wildcard")).toBe(categoryIcon("AlsoUnknown"));
    expect(categoryIcon("Materials")).not.toBe(categoryIcon("Labor"));
  });
});
