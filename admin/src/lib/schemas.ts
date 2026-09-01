import { z } from "zod";

/**
 * Request schemas for every API route. Keeping them together makes it obvious
 * when two routes describe the same field differently, which is how the old
 * hand-rolled `String(x ?? "").trim()` validation drifted.
 */

const trimmed = z.string().trim();

const requiredId = trimmed.min(1, "is required");

/** Positive whole currency amount, accepting the numeric strings forms send. */
const positiveAmount = z.coerce
  .number()
  .refine(Number.isFinite, "must be a number")
  .transform((n) => Math.round(n))
  .refine((n) => n > 0, "must be greater than zero");

const nonNegativeAmount = z.coerce
  .number()
  .refine(Number.isFinite, "must be a number")
  .transform((n) => Math.max(0, Math.round(n)));

const email = trimmed
  .min(1, "Email is required")
  .toLowerCase()
  .regex(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Invalid email address");

const stringList = z
  .array(z.coerce.string())
  .default([])
  .transform((items) => items.map((item) => item.trim()).filter(Boolean));

export const notificationTypeSchema = z.enum([
  "donation",
  "problem",
  "citizen",
  "project",
  "general",
  "registration",
]);

// --- Shared query shapes ---

export const idQuerySchema = z.object({ id: requiredId });

// --- Donations ---

export const createDonationSchema = z.object({
  userId: requiredId,
  amount: positiveAmount,
  paymentTarget: trimmed.min(1, "Select a receiving account or cash"),
  senderNumber: trimmed.default(""),
  transactionId: trimmed.default(""),
  status: z.enum(["Pending", "Approved"]).default("Approved"),
});
export type CreateDonationInput = z.infer<typeof createDonationSchema>;

export const donationActionSchema = z.object({
  id: requiredId,
  action: z.enum(["approve", "reject"]),
});

// --- Expenses ---

export const createExpenseSchema = z.object({
  project: trimmed.min(1, "Project or expense title is required"),
  category: trimmed.default(""),
  amount: positiveAmount,
  notes: trimmed.default(""),
});

// --- Users / Citizens ---

export const createUserSchema = z.object({
  name: trimmed.min(1, "Citizen name is required"),
  phone: trimmed.min(1, "Phone number is required"),
  village: trimmed.min(1, "Village name is required"),
  profession: trimmed.default(""),
  email: z.union([z.literal(""), email]).default(""),
  address: trimmed.default(""),
  nidNumber: trimmed.default(""),
  bloodGroup: trimmed.default(""),
  dateOfBirth: trimmed.default(""),
  photoUrl: trimmed.default(""),
});

// --- Admins ---

export const createAdminSchema = z.object({ email });
export const adminEmailQuerySchema = z.object({ email });

// --- Problems ---

export const createProblemSchema = z.object({
  title: trimmed.min(1, "Problem title is required"),
  description: trimmed.min(1, "Problem description is required"),
  location: trimmed.default(""),
  photoUrl: trimmed.default(""),
  status: z.enum(["Pending", "Approved", "Completed"]).default("Pending"),
});

// --- Projects ---

const projectFields = {
  title: trimmed.min(1, "Project title is required"),
  description: trimmed.default(""),
  estimatedCost: nonNegativeAmount.default(0),
  allocatedFunds: nonNegativeAmount.default(0),
  status: z.enum(["Planning", "In Progress", "Completed"]).default("Planning"),
  photos: stringList,
  updates: stringList,
  spendingReport: stringList,
};

export const createProjectSchema = z.object(projectFields);
export const updateProjectSchema = z.object({ ...projectFields, id: requiredId });

// --- Notifications ---

export const createNotificationSchema = z.object({
  title: trimmed.min(1, "Notification title is required").max(200, "is too long"),
  body: trimmed.min(1, "Notification message is required").max(1000, "is too long"),
  type: notificationTypeSchema.default("donation"),
});

// --- Push ---

export const pushNotificationSchema = z.object({
  title: trimmed.min(1, "Invalid title").max(200, "Invalid title"),
  body: trimmed.min(1, "Invalid body").max(1000, "Invalid body"),
  type: notificationTypeSchema,
});

// --- Settings ---

export const paymentAccountSchema = z.object({
  id: trimmed.default(""),
  type: trimmed.default(""),
  number: trimmed.default(""),
  name: trimmed.default(""),
});

export const updateSettingsSchema = z
  .object({
    name: trimmed.min(1, "Village name is required").optional(),
    paymentAccounts: z.array(paymentAccountSchema).optional(),
  })
  .refine(
    (value) => value.name !== undefined || value.paymentAccounts !== undefined,
    { message: "No settings changes provided" }
  );
