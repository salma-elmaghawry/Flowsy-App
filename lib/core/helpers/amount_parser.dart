/// Parses an amount typed by the user, accepting Arabic-Indic (١٢٣) and
/// Persian (۱۲۳) digits and the Arabic decimal separator (٫). Commas, the
/// Arabic thousands separator (٬) and spaces are treated as thousands
/// separators and ignored. Returns null when the text is not a valid number.
double? parseAmount(String? input) {
  if (input == null) return null;
  final buffer = StringBuffer();
  for (final rune in input.trim().runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
    } else if (rune == 0x066B) {
      buffer.write('.');
    } else if (rune == 0x066C || rune == 0x2C || rune == 0x20) {
      // Arabic thousands separator and spaces are ignored.
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return double.tryParse(buffer.toString());
}
