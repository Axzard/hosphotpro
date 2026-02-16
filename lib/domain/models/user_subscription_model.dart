// Domain Model - User subscription status
enum SubscriptionStatus {
  active,
  pending,
  expired,
  none;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.none:
        return 'No Subscription';
    }
  }
}

class UserSubscriptionModel {
  final String? id;
  final String userId;
  final String? packageId;
  final String? packageName;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;

  UserSubscriptionModel({
    this.id,
    required this.userId,
    this.packageId,
    this.packageName,
    required this.status,
    this.startDate,
    this.endDate,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => status == SubscriptionStatus.expired;
  
  int get daysRemaining {
    if (endDate == null) return 0;
    final diff = endDate!.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }
}
