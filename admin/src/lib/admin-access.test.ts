import { describe, it, expect, beforeEach, afterEach } from "vitest";
import {
  normalizeAdminEmail,
  getBootstrapAdminEmails,
  isBootstrapAdminEmail,
} from "./admin-access";

describe("normalizeAdminEmail", () => {
  it("trims and lowercases", () => {
    expect(normalizeAdminEmail("  Admin@Example.com  ")).toBe("admin@example.com");
  });

  it("handles null/undefined", () => {
    expect(normalizeAdminEmail(null)).toBe("");
    expect(normalizeAdminEmail(undefined)).toBe("");
  });
});

describe("getBootstrapAdminEmails", () => {
  const originalEnv = process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS;

  afterEach(() => {
    if (originalEnv === undefined) {
      delete process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS;
    } else {
      process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS = originalEnv;
    }
  });

  it("falls back to the default bootstrap admin when env var is unset", () => {
    delete process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS;
    expect(getBootstrapAdminEmails()).toEqual(["murshedkoli@gmail.com"]);
  });

  it("parses a comma-separated env var, normalizing each entry", () => {
    process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS =
      " Alice@Example.com, bob@example.com ,, ";
    expect(getBootstrapAdminEmails()).toEqual([
      "alice@example.com",
      "bob@example.com",
    ]);
  });

  it("falls back to default if env var parses to nothing usable", () => {
    process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS = " , , ";
    expect(getBootstrapAdminEmails()).toEqual(["murshedkoli@gmail.com"]);
  });
});

describe("isBootstrapAdminEmail", () => {
  beforeEach(() => {
    delete process.env.NEXT_PUBLIC_BOOTSTRAP_ADMIN_EMAILS;
  });

  it("matches the default bootstrap admin case-insensitively", () => {
    expect(isBootstrapAdminEmail("MurshedKoli@Gmail.com")).toBe(true);
  });

  it("returns false for other emails", () => {
    expect(isBootstrapAdminEmail("someone-else@example.com")).toBe(false);
  });

  it("returns false for empty/null input", () => {
    expect(isBootstrapAdminEmail("")).toBe(false);
    expect(isBootstrapAdminEmail(null)).toBe(false);
  });
});
