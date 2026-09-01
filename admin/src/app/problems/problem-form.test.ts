import { describe, it, expect } from "vitest";
import {
  emptyProblemForm,
  nextProblemStep,
  validateProblemForm,
} from "./problem-form";

describe("validateProblemForm", () => {
  it("requires a title", () => {
    expect(
      validateProblemForm({ ...emptyProblemForm, description: "d" })
    ).toBe("Problem title is required.");
  });

  it("requires a description", () => {
    expect(validateProblemForm({ ...emptyProblemForm, title: "t" })).toBe(
      "Problem description is required."
    );
  });

  it("treats whitespace-only values as missing", () => {
    expect(
      validateProblemForm({
        ...emptyProblemForm,
        title: "   ",
        description: "d",
      })
    ).toBe("Problem title is required.");
  });

  it("passes a complete form", () => {
    expect(
      validateProblemForm({
        ...emptyProblemForm,
        title: "Road damage",
        description: "Near the school",
      })
    ).toBeNull();
  });
});

describe("nextProblemStep", () => {
  it("advances Pending to Approved", () => {
    expect(nextProblemStep("Pending")).toEqual({
      status: "Approved",
      label: "Approve",
    });
  });

  it("advances Approved to Completed", () => {
    expect(nextProblemStep("Approved")).toEqual({
      status: "Completed",
      label: "Mark Complete",
    });
  });

  it("offers nothing once completed", () => {
    expect(nextProblemStep("Completed")).toBeNull();
  });
});
