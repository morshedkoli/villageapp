import { NextRequest, NextResponse } from "next/server";
import { ZodError, ZodType } from "zod";
import { ApiError } from "./api-error";
import { verifyAdmin } from "./verify-admin";

export type RouteHandler = (req: NextRequest) => Promise<NextResponse>;

/** Context handed to admin-only handlers after the caller has been verified. */
export interface AdminContext {
  /** Normalized email of the verified admin, for `addedBy` style audit fields. */
  email: string;
}

export type AdminRouteHandler = (
  req: NextRequest,
  ctx: AdminContext
) => Promise<NextResponse>;

function firstZodMessage(error: ZodError): string {
  const issue = error.issues[0];
  if (!issue) return "Invalid request body";
  const path = issue.path.join(".");
  return path ? `${path}: ${issue.message}` : issue.message;
}

/**
 * Wraps a route handler so uncaught errors (Firestore failures, bad JSON,
 * etc.) return a consistent `{ error }` JSON response instead of Next's
 * default opaque 500, and get logged server-side for debugging.
 *
 * `ApiError` and `ZodError` map to their own status codes; anything else is a
 * 500 and is logged.
 */
export function withApiErrorHandling(handler: RouteHandler): RouteHandler {
  return async (req: NextRequest): Promise<NextResponse> => {
    try {
      return await handler(req);
    } catch (error: unknown) {
      if (error instanceof ApiError) {
        return NextResponse.json(
          { error: error.message },
          { status: error.status }
        );
      }

      if (error instanceof ZodError) {
        return NextResponse.json(
          { error: firstZodMessage(error) },
          { status: 400 }
        );
      }

      const message =
        error instanceof Error ? error.message : "Unexpected server error";
      console.error(`[${req.method} ${req.nextUrl.pathname}]`, error);
      return NextResponse.json({ error: message }, { status: 500 });
    }
  };
}

/**
 * Admin-only route wrapper: verifies the bearer token, short-circuits with the
 * verifier's own status on failure, and passes the admin email to the handler.
 * Composes `withApiErrorHandling`, so handlers may just throw `ApiError`.
 */
export function withAdminRoute(handler: AdminRouteHandler): RouteHandler {
  return withApiErrorHandling(async (req) => {
    const verified = await verifyAdmin(req);
    if (!verified.ok) {
      return NextResponse.json(
        { error: verified.error },
        { status: verified.status }
      );
    }
    return handler(req, { email: verified.email });
  });
}

/**
 * Parses and validates a JSON request body. A missing or malformed body is
 * validated as `{}` so schemas produce field-level messages instead of a
 * generic parse error.
 */
export async function parseJsonBody<T>(
  req: NextRequest,
  schema: ZodType<T>
): Promise<T> {
  const raw = await req.json().catch(() => ({}));
  return schema.parse(raw ?? {});
}

/** Validates search params against a schema, using the same error mapping. */
export function parseQuery<T>(req: NextRequest, schema: ZodType<T>): T {
  const { searchParams } = new URL(req.url);
  return schema.parse(Object.fromEntries(searchParams.entries()));
}
