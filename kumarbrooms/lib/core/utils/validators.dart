abstract final class Validators {
  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;

  static String? email(String? value) {
    final requiredMessage = required(value, 'Email');
    if (requiredMessage != null) return requiredMessage;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address';
  }

  static String? password(String? value, {bool enforceLength = false}) {
    final requiredMessage = required(value, 'Password');
    if (requiredMessage != null) return requiredMessage;
    if (enforceLength && value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}
