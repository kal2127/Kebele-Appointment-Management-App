class Validators {
  static String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? ethiopianPhone(String? value, String requiredMessage,
      String invalidMessage) {
    final requiredError = requiredField(value, requiredMessage);
    if (requiredError != null) return requiredError;

    final normalized = value!.replaceAll(' ', '');
    final isValid = RegExp(r'^(09|07|\+2519|\+2517)\d{8}$')
        .hasMatch(normalized);
    return isValid ? null : invalidMessage;
  }
}
