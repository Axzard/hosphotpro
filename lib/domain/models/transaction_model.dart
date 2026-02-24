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
  final String? redirectUrl;
  final String? vaNumber;
  final String? bankName;

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
    this.redirectUrl,
    this.vaNumber,
    this.bankName,
  });

  TransactionModel copyWith({
    String? id,
    String? packageId,
    String? packageName,
    String? userId,
    double? amount,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? paidAt,
    String? snapToken,
    String? redirectUrl,
    String? vaNumber,
    String? bankName,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      snapToken: snapToken ?? this.snapToken,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      vaNumber: vaNumber ?? this.vaNumber,
      bankName: bankName ?? this.bankName,
    );
  }
}
