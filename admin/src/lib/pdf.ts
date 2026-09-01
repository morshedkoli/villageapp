/**
 * Minimal PDF writer for the downloadable reports. Emits a plain single-font
 * text document — enough for tabular report lines without pulling in a PDF
 * library.
 */

const PAGE_WIDTH = 595;
const PAGE_HEIGHT = 842;
const LEFT_MARGIN = 40;
const TOP = 800;
const LINE_HEIGHT = 16;
const BOTTOM_MARGIN = 40;

function escapePdfText(value: string): string {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/\(/g, "\\(")
    .replace(/\)/g, "\\)");
}

/** Splits report lines into pages that fit between the top and bottom margins. */
function paginate(lines: string[]): string[][] {
  const pages: string[][] = [[]];
  let y = TOP;

  for (const line of lines) {
    if (y < BOTTOM_MARGIN) {
      pages.push([]);
      y = TOP;
    }
    pages[pages.length - 1].push(
      `BT /F1 11 Tf ${LEFT_MARGIN} ${y} Td (${escapePdfText(line)}) Tj ET`
    );
    y -= LINE_HEIGHT;
  }

  return pages;
}

export function buildPdf(lines: string[]): Blob {
  const pages = paginate(lines);

  const objects: string[] = [];
  objects.push("<< /Type /Catalog /Pages 2 0 R >>");

  const pageObjectNumbers: number[] = [];
  const contentObjectNumbers: number[] = [];
  const pageKids = pages
    .map((_, index) => {
      const pageObjectNumber = 4 + index * 2;
      pageObjectNumbers.push(pageObjectNumber);
      contentObjectNumbers.push(pageObjectNumber + 1);
      return `${pageObjectNumber} 0 R`;
    })
    .join(" ");

  objects.push(`<< /Type /Pages /Kids [${pageKids}] /Count ${pages.length} >>`);
  objects.push("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>");

  pages.forEach((pageLines, index) => {
    const pageObjectNumber = pageObjectNumbers[index];
    const contentObjectNumber = contentObjectNumbers[index];

    objects[pageObjectNumber - 1] =
      `<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${PAGE_WIDTH} ${PAGE_HEIGHT}] /Resources << /Font << /F1 3 0 R >> >> /Contents ${contentObjectNumber} 0 R >>`;

    const stream = pageLines.join("\n");
    objects[contentObjectNumber - 1] =
      `<< /Length ${stream.length} >>\nstream\n${stream}\nendstream`;
  });

  let pdf = "%PDF-1.4\n";
  const offsets: number[] = [0];

  objects.forEach((object, index) => {
    offsets.push(pdf.length);
    pdf += `${index + 1} 0 obj\n${object}\nendobj\n`;
  });

  const xrefStart = pdf.length;
  pdf += `xref\n0 ${objects.length + 1}\n`;
  pdf += "0000000000 65535 f \n";
  offsets.slice(1).forEach((offset) => {
    pdf += `${offset.toString().padStart(10, "0")} 00000 n \n`;
  });
  pdf += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefStart}\n%%EOF`;

  return new Blob([pdf], { type: "application/pdf" });
}
