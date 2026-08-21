class Failure {
  final String message;
  final String code;

  const Failure({required this.message, this.code = 'UNKNOWN_ERROR'});

  @override
  String toString() => '$code: $message';
}
