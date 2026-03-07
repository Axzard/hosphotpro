import '../../core/utils/error_utils.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required String message,
    this.data,
  }) : message = !success ? ErrorUtils.sanitizeServerMessage(message) : message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) create,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? create(json['data']) : null,
    );
  }
}

