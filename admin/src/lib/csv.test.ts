import { describe, it, expect } from "vitest";
import { csvField, toCsv } from "./csv";

describe("csvField", () => {
  it("leaves plain values untouched", () => {
    expect(csvField("Rahim")).toBe("Rahim");
    expect(csvField(500)).toBe("500");
  });

  it("quotes a value containing a comma", () => {
    expect(csvField("Rahim, Karim")).toBe('"Rahim, Karim"');
  });

  it("doubles embedded quotes", () => {
    expect(csvField('He said "hi"')).toBe('"He said ""hi"""');
  });

  it("quotes a value containing a newline", () => {
    expect(csvField("line1\nline2")).toBe('"line1\nline2"');
  });
});

describe("toCsv", () => {
  it("keeps columns aligned when a field contains a comma", () => {
    const csv = toCsv(
      ["Donor Name", "Amount"],
      [["Rahim, Karim", 500]]
    );

    expect(csv).toBe('Donor Name,Amount\n"Rahim, Karim",500');
    expect(csv.split("\n")[1].split('","')).toHaveLength(1);
  });
});
