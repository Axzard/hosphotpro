// Domain Model - Pure business entity for subscription package
class SubscriptionPackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final int maxRouters;
  final int maxVouchers;

  SubscriptionPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.maxRouters,
    required this.maxVouchers,
  });
}
