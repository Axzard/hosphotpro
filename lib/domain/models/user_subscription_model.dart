// Domain Model - User subscription status
enum SubscriptionStatus {
  active,
  pending,
  expired,
  none;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Aktif';
      case SubscriptionStatus.pending:
        return 'Menunggu Pembayaran';
      case SubscriptionStatus.expired:
        return 'Kadaluarsa';
      case SubscriptionStatus.none:
        return 'Tidak Ada Langganan';
    }
  }

  static SubscriptionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'active':
        return SubscriptionStatus.active;
      case 'pending':
        return SubscriptionStatus.pending;
      case 'expired':
      case 'kadaluarsa':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.none;
    }
  }
}

class UserSubscriptionModel {
  final int idLangganan;
  final int idPengguna;
  final int idPaketLangganan;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final DateTime dibuatPada;
  final SubscriptionStatus status;
  final int jumlahBulan;
  final String namaPaket;
  final double harga;
  final double totalBayar;
  final String? paymentUrl;

  UserSubscriptionModel({
    required this.idLangganan,
    required this.idPengguna,
    required this.idPaketLangganan,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.dibuatPada,
    required this.status,
    required this.jumlahBulan,
    required this.namaPaket,
    required this.harga,
    required this.totalBayar,
    this.paymentUrl,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPending => status == SubscriptionStatus.pending;
  bool get isExpired => status == SubscriptionStatus.expired;

  int get daysRemaining {
    final diff = tanggalBerakhir.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  int get hoursRemaining {
    final diff = tanggalBerakhir.difference(DateTime.now());
    return diff.inHours % 24 > 0 ? diff.inHours % 24 : 0;
  }
}
