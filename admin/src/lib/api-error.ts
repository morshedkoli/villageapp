/**
 * Error carrying an HTTP status. Thrown from route handlers and turned into a
 * `{ error }` JSON response by `withApiErrorHandling`, so handlers can bail out
 * of nested code (transactions included) without threading responses around.
 */
export class ApiError extends Error {
  readonly status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

export function badRequest(message: string): ApiError {
  return new ApiError(400, message);
}

export function notFound(message: string): ApiError {
  return new ApiError(404, message);
}

export function forbidden(message: string): ApiError {
  return new ApiError(403, message);
}
