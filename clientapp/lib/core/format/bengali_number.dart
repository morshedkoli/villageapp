const List<String> _bengaliDigits = [
  '০',
  '১',
  '২',
  '৩',
  '৪',
  '৫',
  '৬',
  '৭',
  '৮',
  '৯',
];

/// Rewrites the ASCII digits in [input] as Bengali numerals, leaving every
/// other character untouched.
String toBengaliDigits(String input) {
  return input.split('').map((character) {
    final code = character.codeUnitAt(0);
    if (code >= 48 && code <= 57) return _bengaliDigits[code - 48];
    return character;
  }).join();
}

/// Formats a money amount for display, abbreviating to লাখ / হাজার the way
/// Bengali readers expect rather than printing every digit.
String formatBengaliAmount(double amount) {
  final lakh = (amount / 100000).floor();
  final thousand = ((amount % 100000) / 1000).floor();

  if (lakh > 0) {
    if (thousand > 0) {
      return '${toBengaliDigits('$lakh')} লাখ ${toBengaliDigits('$thousand')} হাজার';
    }
    return '${toBengaliDigits('$lakh')} লাখ';
  }

  return toBengaliDigits(amount.toInt().toString());
}

String formatBengaliCount(int count) => toBengaliDigits(count.toString());

/// Money amount prefixed with the taka sign, or `--` when nothing is loaded.
String formatTaka(double? amount) {
  if (amount == null) return '--';
  return '৳${formatBengaliAmount(amount)}';
}
