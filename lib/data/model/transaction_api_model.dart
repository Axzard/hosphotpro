import '../../domain/models/transaction_model.dart';

// Data Model with JSON serialization
class TransactionApiModel {
  final String id;
  final String packageId;
  final String packageName;
  final String userId;
  final double amount;
  final String status;
  final String createdAt;
  final String? paidAt;
  final String? snapToken;
  final String? redirectUrl;

  TransactionApiModel({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.snapToken,
    this.redirectUrl,
  });

  factory TransactionApiModel.fromJson(Map<String, dynamic> json) {
    return TransactionApiModel(
      id: json['id'] ?? '',
      packageId: json['package_id'] ?? '',
      packageName: json['package_name'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      paidAt: json['paid_at'],
      snapToken: json['snap_token'],
      redirectUrl: json['redirect_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_id': packageId,
      'package_name': packageName,
      'user_id': userId,
      'amount': amount,
      'status': status,
      'created_at': createdAt,
      'paid_at': paidAt,
      'snap_token': snapToken,
      'redirect_url': redirectUrl,
    };
  }

  // Convert to Domain Model
  TransactionModel toDomain() {
    return TransactionModel(
      id: id,
      packageId: packageId,
      packageName: packageName,
      userId: userId,
      amount: amount,
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
      paidAt: paidAt != null ? DateTime.parse(paidAt!) : null,
      snapToken: snapToken,
      redirectUrl: redirectUrl,
    );
  }

  TransactionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'expired':
        return TransactionStatus.expired;
      default:
        return TransactionStatus.pending;
    }
  }
}
