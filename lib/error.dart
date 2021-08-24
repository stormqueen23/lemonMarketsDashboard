class LemonMarketsError extends Error {

  final Object? message;

  LemonMarketsError([this.message]);

  String toString() {
    if (message != null) {
      return "LemonMarketsError: ${Error.safeToString(message)}";
    }
    return "LemonMarketsError";
  }
}