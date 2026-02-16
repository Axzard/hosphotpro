import '../../domain/models/subscription_package_model.dart';

// Data Model with JSON serialization
class SubscriptionPackageApiModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int maxRouters;
  final int maxVouchers;

  SubscriptionPackageApiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.maxRouters,
    required this.maxVouchers,
  });

  factory SubscriptionPackageApiModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageApiModel(
      id: json['id_paket_langganan']?.toString() ?? '',
      name: json['nama_paket'] ?? '',
      description: '', // Backend doesn't provide description
      price: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      durationDays: json['durasi_hari'] ?? 0,
      maxRouters: json['batas_router'] ?? 0,
      maxVouchers: json['batas_voucher'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'max_routers': maxRouters,
      'max_vouchers': maxVouchers,
    };
  }

  // Convert to Domain Model
  SubscriptionPackageModel toDomain() {
    return SubscriptionPackageModel(
      id: id,
      name: name,
      description: description,
      price: price,
      durationDays: durationDays,
      maxRouters: maxRouters,
      maxVouchers: maxVouchers,
    );
  }
}
