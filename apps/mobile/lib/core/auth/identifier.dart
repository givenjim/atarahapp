/// "Email or phone number" input, parsed the same way the API parses it (`apps/backend/src/common/contact.ts`),
/// so the form can show the right error before a request is made. The server stays the authority.
enum IdentifierKind { email, phone, invalid }

class ParsedIdentifier {
  const ParsedIdentifier(this.kind, this.value);

  final IdentifierKind kind;

  /// Lower-cased email, or the phone in E.164 (`+254712345678`). The raw text when invalid.
  final String value;

  bool get isValid => kind != IdentifierKind.invalid;
}

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _e164 = RegExp(r'^\+[1-9]\d{6,14}$');

/// E.164 from a Kenyan local format (0712…, 712…, 254712…) or an international one (+…, 00…).
String? normalisePhone(String raw, {String defaultCallingCode = '+254'}) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[\s().-]'), '');
  final String candidate;
  if (cleaned.startsWith('+')) {
    candidate = cleaned;
  } else if (cleaned.startsWith('00')) {
    candidate = '+${cleaned.substring(2)}';
  } else if (cleaned.startsWith(defaultCallingCode.substring(1))) {
    candidate = '+$cleaned';
  } else if (cleaned.startsWith('0')) {
    candidate = '$defaultCallingCode${cleaned.substring(1)}';
  } else if (RegExp(r'^[17][0-9]{8}$').hasMatch(cleaned)) {
    candidate = '$defaultCallingCode$cleaned';
  } else {
    return null;
  }
  return _e164.hasMatch(candidate) ? candidate : null;
}

ParsedIdentifier parseIdentifier(String raw) {
  final value = raw.trim();
  if (value.contains('@')) {
    return _email.hasMatch(value)
        ? ParsedIdentifier(IdentifierKind.email, value.toLowerCase())
        : ParsedIdentifier(IdentifierKind.invalid, value);
  }
  final phone = normalisePhone(value);
  return phone == null
      ? ParsedIdentifier(IdentifierKind.invalid, value)
      : ParsedIdentifier(IdentifierKind.phone, phone);
}
