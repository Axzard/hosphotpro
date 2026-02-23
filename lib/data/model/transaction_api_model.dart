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
  final String? vaNumber;
  final String? bankName;

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
    this.vaNumber,
    this.bankName,
  });

  factory TransactionApiModel.fromJson(Map<String, dynamic> json) {
    // Higher-level heuristic to find the "real" data object
    final Map<String, dynamic> dataObj =
        (json['data'] is Map ? json['data'] : null) ??
        (json['transaction'] is Map ? json['transaction'] : null) ??
        (json['midtrans'] is Map ? json['midtrans'] : null) ??
        json;

    String? va;
    String? bank;

    // 1. Array check (Midtrans standard)
    if (dataObj['va_numbers'] is List &&
        (dataObj['va_numbers'] as List).isNotEmpty) {
      va = dataObj['va_numbers'][0]['va_number'];
      bank = dataObj['va_numbers'][0]['bank'];
    }

    // 2. Recursive Search for VA/Payment Code if not found
    if (va == null) {
      va = _findValueRecursive(json, [
        'va_number',
        'va_no',
        'payment_code',
        'payment_key',
        'bill_key',
        'permata_va_number',
        'permata_va_no',
        'kode_bayar',
        'kode_pembayaran',
        'id_langganan_va',
      ]);

      // Special case: Mandiri Bill Key needs Biller Code prefix
      if (va != null && (_findKeyRecursive(json, 'bill_key') != null)) {
        final billerCode = _findValueRecursive(json, ['biller_code']) ?? "";
        if (!va.startsWith(billerCode)) {
          va = '$billerCode$va';
        }
        bank = 'mandiri';
      }
    }

    // 3. Fallback for Bank Name
    if (bank == null) {
      bank = _findValueRecursive(json, [
        'bank',
        'bank_name',
        'nama_bank',
        'payment_type',
      ]);
    }

    return TransactionApiModel(
      id:
          json['id']?.toString() ??
          json['data']?['id']?.toString() ??
          json['id_langganan']?.toString() ??
          json['data']?['id_langganan']?.toString() ??
          '',
      packageId: json['package_id']?.toString() ?? '',
      packageName: json['package_name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      amount:
          (json['amount'] ??
                  json['data']?['amount'] ??
                  json['total_bayar'] ??
                  json['data']?['total_bayar'] ??
                  json['gross_amount'] ??
                  json['data']?['gross_amount'] ??
                  0)
              .toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      paidAt: json['paid_at'],
      snapToken: json['snap_token'] ?? json['data']?['snap_token'],
      redirectUrl: json['redirect_url'] ?? json['data']?['redirect_url'],
      vaNumber: va,
      bankName: bank,
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
      'va_number': vaNumber,
      'bank_name': bankName,
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
      vaNumber: vaNumber,
      bankName: bankName,
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

  TransactionApiModel copyWith({
    String? id,
    String? packageId,
    String? packageName,
    String? userId,
    double? amount,
    String? status,
    String? createdAt,
    String? paidAt,
    String? snapToken,
    String? redirectUrl,
    String? vaNumber,
    String? bankName,
  }) {
    return TransactionApiModel(
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

  static String? _findValueRecursive(dynamic data, List<String> targetKeys) {
    if (data is Map) {
      for (final key in targetKeys) {
        if (data[key] != null) return data[key].toString();
      }
      for (final value in data.values) {
        final result = _findValueRecursive(value, targetKeys);
        if (result != null) return result;
      }
    } else if (data is List) {
      for (final item in data) {
        final result = _findValueRecursive(item, targetKeys);
        if (result != null) return result;
      }
    }
    return null;
  }

  static String? _findKeyRecursive(dynamic data, String targetKey) {
    if (data is Map) {
      if (data.containsKey(targetKey)) return data[targetKey]?.toString();
      for (final value in data.values) {
        final result = _findKeyRecursive(value, targetKey);
        if (result != null) return result;
      }
    } else if (data is List) {
      for (final item in data) {
        final result = _findKeyRecursive(item, targetKey);
        if (result != null) return result;
      }
    }
    return null;
  }
}
