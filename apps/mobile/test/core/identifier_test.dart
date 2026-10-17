import 'package:atarah/core/auth/identifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone numbers become E.164 with +254 by default', () {
    for (final (input, expected) in [
      ('0712345678', '+254712345678'),
      ('0712 345 678', '+254712345678'),
      ('712345678', '+254712345678'),
      ('112345678', '+254112345678'),
      ('254712345678', '+254712345678'),
      ('+254 712 345 678', '+254712345678'),
      ('+254-712-345-678', '+254712345678'),
      ('00254712345678', '+254712345678'),
      ('+447911123456', '+447911123456'),
      ('(0712) 345-678', '+254712345678'),
    ]) {
      test(input, () => expect(normalisePhone(input), expected));
    }

    for (final bad in [
      '',
      'abc',
      '0712',
      '+0712345678',
      '999999999999999999',
    ]) {
      test('rejects "$bad"', () => expect(normalisePhone(bad), isNull));
    }
  });

  group('the identifier field tells email from phone', () {
    test('email is lower-cased', () {
      final p = parseIdentifier('  Nia@Example.COM ');
      expect(p.kind, IdentifierKind.email);
      expect(p.value, 'nia@example.com');
    });

    test('phone is normalised', () {
      final p = parseIdentifier('0712 345 678');
      expect(p.kind, IdentifierKind.phone);
      expect(p.value, '+254712345678');
    });

    test('anything else is invalid', () {
      for (final bad in ['nia@', '@example.com', 'nia example', 'hello', '']) {
        expect(parseIdentifier(bad).isValid, isFalse, reason: bad);
      }
    });
  });
}
