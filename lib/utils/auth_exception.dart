class AuthException implements Exception {
  final String message;
  final String? errorCode; // Adiciona o código de erro

  AuthException(this.message, {this.errorCode});

  @override
  String toString() {
    if (errorCode != null) {
      return 'AuthException: $message (Code: $errorCode)';
    }
    return 'AuthException: $message';
  }
}
