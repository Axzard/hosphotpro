// Domain Model - Transaction status enum
enum TransactionStatus {
  pending,
  success,
  failed,
  cancelled,
  expired;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.success:
        return 'Success';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.expired:
        return 'Expired';
    }
  }
}

// Domain Model - Pure business entity for transaction
class TransactionModel {
  final String id;
  final String packageId;
  final String packageName;
  final String userId;
  final double amount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? snapToken;

  TransactionModel({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.userId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.snapToken,
  });
}
