import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_split/core/helpers/amount_parser.dart';

void main() {
  test('parses western digits', () => expect(parseAmount('100'), 100));
  test('parses Arabic-Indic digits', () => expect(parseAmount('١٠٠'), 100));
  test('parses Persian digits', () => expect(parseAmount('۸۱۰'), 810));
  test('parses Arabic decimal separator', () {
    expect(parseAmount('١٢٫٥'), 12.5);
  });
  test('ignores thousands commas', () => expect(parseAmount('1,000'), 1000));
  test('ignores Arabic thousands separator', () {
    expect(parseAmount('١٬٠٠٠'), 1000);
  });
  test('ignores surrounding spaces', () => expect(parseAmount(' 20 '), 20));
  test('rejects text', () => expect(parseAmount('abc'), isNull));
  test('rejects empty', () => expect(parseAmount(''), isNull));
}
