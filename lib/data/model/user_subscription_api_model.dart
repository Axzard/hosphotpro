import '../../domain/models/user_subscription_model.dart';

class UserSubscriptionApiModel {
  final int idLangganan;
  final int idPengguna;
  final int idPaketLangganan;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;
  final DateTime dibuatPada;
  final String statusLangganan;
  final int jumlahBulan;
  final String namaPaket;
  final double harga;
  final double totalBayar;
  final String? paymentUrl;

  UserSubscriptionApiModel({
    required this.idLangganan,
    required this.idPengguna,
    required this.idPaketLangganan,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
    required this.dibuatPada,
    required this.statusLangganan,
    required this.jumlahBulan,
    required this.namaPaket,
    required this.harga,
    required this.totalBayar,
    this.paymentUrl,
  });

  factory UserSubscriptionApiModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionApiModel(
      idLangganan: json['id_langganan'] ?? 0,
      idPengguna: json['id_pengguna'] ?? 0,
      idPaketLangganan: json['id_paket_langganan'] ?? 0,
      tanggalMulai: DateTime.parse(
        json['tanggal_mulai'] ?? DateTime.now().toIso8601String(),
      ),
      tanggalBerakhir: DateTime.parse(
        json['tanggal_berakhir'] ?? DateTime.now().toIso8601String(),
      ),
      dibuatPada: DateTime.parse(
        json['dibuat_pada'] ?? DateTime.now().toIso8601String(),
      ),
      statusLangganan: json['status_langganan'] ?? 'none',
      jumlahBulan: json['jumlah_bulan'] ?? 1,
      namaPaket: json['nama_paket'] ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      totalBayar: double.tryParse(json['total_bayar']?.toString() ?? '0') ?? 0,
      paymentUrl: json['payment_url'] ?? json['redirect_url'],
    );
  }

  UserSubscriptionModel toDomain() {
    return UserSubscriptionModel(
      idLangganan: idLangganan,
      idPengguna: idPengguna,
      idPaketLangganan: idPaketLangganan,
      tanggalMulai: tanggalMulai,
      tanggalBerakhir: tanggalBerakhir,
      dibuatPada: dibuatPada,
      status: SubscriptionStatus.fromString(statusLangganan),
      jumlahBulan: jumlahBulan,
      namaPaket: namaPaket,
      harga: harga,
      totalBayar: totalBayar,
      paymentUrl: paymentUrl,
    );
  }
}
