/**
 * Quotes a CSV field when it contains a comma, quote or newline, doubling any
 * embedded quotes. Donor names and free-text notes routinely contain commas,
 * which would otherwise shift every later column in the exported row.
 */
export function csvField(value: string | number): string {
  const text = String(value ?? "");
  if (!/[",\r\n]/.test(text)) return text;
  return `"${text.replace(/"/g, '""')}"`;
}

export function toCsv(headers: string[], rows: Array<Array<string | number>>): string {
  return [headers, ...rows]
    .map((row) => row.map(csvField).join(","))
    .join("\n");
}

export function csvBlob(
  headers: string[],
  rows: Array<Array<string | number>>
): Blob {
  return new Blob([toCsv(headers, rows)], { type: "text/csv" });
}

/** Triggers a browser download for an in-memory blob. */
export function downloadBlob(blob: Blob, filename: string): void {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}
