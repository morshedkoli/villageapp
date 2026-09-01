/// Quick-pick amounts offered on the checkout screen, written in Bengali
/// numerals because that is what the rest of the UI shows.
const List<String> kQuickAmounts = ['৫০০', '১,০০০', '২,০০০', '৫,০০০', '১০,০০০'];

const String _bengaliDigits = '০১২৩৪৫৬৭৮৯';

/// Rewrites Bengali digits as ASCII so the result can be parsed as a number.
String toAsciiDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final index = _bengaliDigits.runes.toList().indexOf(rune);
    buffer.write(index >= 0 ? '$index' : String.fromCharCode(rune));
  }
  return buffer.toString();
}

/// Parses an amount typed or picked on the checkout screen.
///
/// Returns `null` when nothing usable was entered. The quick-pick values are
/// Bengali numerals, which `double.tryParse` cannot read — selecting one and
/// submitting used to fail with "enter a valid amount" even though an amount
/// was clearly chosen.
double? parseDonationAmount(String input) {
  final normalized = toAsciiDigits(input)
      .replaceAll(',', '')
      .replaceAll('٫', '.')
      .trim();
  if (normalized.isEmpty) return null;

  final amount = double.tryParse(normalized);
  if (amount == null || amount <= 0) return null;
  return amount;
}
