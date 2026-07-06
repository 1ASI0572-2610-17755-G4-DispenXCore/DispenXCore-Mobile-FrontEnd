class DispenseResult {
  final bool success;
  final String message;
  final int? eventId;
  final String? status;

  const DispenseResult({
    required this.success,
    required this.message,
    this.eventId,
    this.status,
  });

  factory DispenseResult.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>?;
    return DispenseResult(
      success: json['status'] == 'success',
      message: json['message'] as String? ?? '',
      eventId: event?['id'] as int?,
      status: event?['status'] as String?,
    );
  }
}
