import { describe, it, expect } from "vitest";
import {
  createAdminSchema,
  createDonationSchema,
  createExpenseSchema,
  createProjectSchema,
  createUserSchema,
  donationActionSchema,
  idQuerySchema,
  pushNotificationSchema,
  updateSettingsSchema,
} from "./schemas";

describe("createDonationSchema", () => {
  it("trims strings, rounds the amount and defaults the status", () => {
    const parsed = createDonationSchema.parse({
      userId: "  user-1 ",
      amount: "500.4",
      paymentTarget: " cash ",
    });

    expect(parsed).toEqual({
      userId: "user-1",
      amount: 500,
      paymentTarget: "cash",
      senderNumber: "",
      transactionId: "",
      status: "Approved",
    });
  });

  it("rejects a zero or negative amount", () => {
    const base = { userId: "u", paymentTarget: "cash" };
    expect(createDonationSchema.safeParse({ ...base, amount: 0 }).success).toBe(
      false
    );
    expect(createDonationSchema.safeParse({ ...base, amount: -1 }).success).toBe(
      false
    );
  });

  it("rejects a non-numeric amount", () => {
    expect(
      createDonationSchema.safeParse({
        userId: "u",
        paymentTarget: "cash",
        amount: "many",
      }).success
    ).toBe(false);
  });

  it("rejects an unknown status", () => {
    expect(
      createDonationSchema.safeParse({
        userId: "u",
        paymentTarget: "cash",
        amount: 5,
        status: "Rejected",
      }).success
    ).toBe(false);
  });
});

describe("donationActionSchema", () => {
  it("accepts approve and reject only", () => {
    expect(donationActionSchema.safeParse({ id: "d1", action: "approve" }).success).toBe(true);
    expect(donationActionSchema.safeParse({ id: "d1", action: "reject" }).success).toBe(true);
    expect(donationActionSchema.safeParse({ id: "d1", action: "delete" }).success).toBe(false);
  });
});

describe("idQuerySchema", () => {
  it("requires a non-empty id", () => {
    expect(idQuerySchema.safeParse({ id: "abc" }).success).toBe(true);
    expect(idQuerySchema.safeParse({ id: "   " }).success).toBe(false);
    expect(idQuerySchema.safeParse({}).success).toBe(false);
  });
});

describe("createUserSchema", () => {
  it("requires name, phone and village", () => {
    expect(createUserSchema.safeParse({ phone: "1", village: "v" }).success).toBe(false);
    expect(createUserSchema.safeParse({ name: "n", village: "v" }).success).toBe(false);
    expect(createUserSchema.safeParse({ name: "n", phone: "1" }).success).toBe(false);
  });

  it("allows an empty email but rejects a malformed one", () => {
    const base = { name: "Rahim", phone: "0170", village: "Kola" };
    expect(createUserSchema.parse({ ...base, email: "" }).email).toBe("");
    expect(createUserSchema.parse({ ...base, email: "A@B.com" }).email).toBe("a@b.com");
    expect(createUserSchema.safeParse({ ...base, email: "nope" }).success).toBe(false);
  });
});

describe("createAdminSchema", () => {
  it("normalizes the email to lowercase", () => {
    expect(createAdminSchema.parse({ email: " Admin@Example.COM " }).email).toBe(
      "admin@example.com"
    );
  });
});

describe("createExpenseSchema", () => {
  it("requires a project and a positive amount", () => {
    expect(createExpenseSchema.safeParse({ project: "", amount: 10 }).success).toBe(false);
    expect(createExpenseSchema.safeParse({ project: "p", amount: 0 }).success).toBe(false);
    expect(createExpenseSchema.parse({ project: "p", amount: 10 }).notes).toBe("");
  });
});

describe("createProjectSchema", () => {
  it("clamps negative costs to zero and drops blank list entries", () => {
    const parsed = createProjectSchema.parse({
      title: "Bridge",
      estimatedCost: -50,
      photos: ["a.jpg", "  ", "b.jpg"],
    });

    expect(parsed.estimatedCost).toBe(0);
    expect(parsed.photos).toEqual(["a.jpg", "b.jpg"]);
    expect(parsed.status).toBe("Planning");
  });

  it("requires a title", () => {
    expect(createProjectSchema.safeParse({ description: "x" }).success).toBe(false);
  });
});

describe("pushNotificationSchema", () => {
  it("rejects an unknown notification type", () => {
    expect(
      pushNotificationSchema.safeParse({ title: "t", body: "b", type: "spam" })
        .success
    ).toBe(false);
  });

  it("rejects an over-long body", () => {
    expect(
      pushNotificationSchema.safeParse({
        title: "t",
        body: "x".repeat(1001),
        type: "general",
      }).success
    ).toBe(false);
  });
});

describe("updateSettingsSchema", () => {
  it("requires at least one field", () => {
    expect(updateSettingsSchema.safeParse({}).success).toBe(false);
  });

  it("rejects a blank village name", () => {
    expect(updateSettingsSchema.safeParse({ name: "   " }).success).toBe(false);
  });

  it("accepts a payment account list on its own", () => {
    const parsed = updateSettingsSchema.parse({
      paymentAccounts: [{ id: "a", type: "bkash", number: "017", name: "X" }],
    });
    expect(parsed.paymentAccounts).toHaveLength(1);
    expect(parsed.name).toBeUndefined();
  });
});
