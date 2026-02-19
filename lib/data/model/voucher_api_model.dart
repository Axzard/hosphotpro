import '../../domain/models/voucher_model.dart';

class VoucherApiModel {
  final int idVoucher;
  final String kodeVoucher;
  final String passwordVoucher;
  final int idPaket;
  final int idRouter;
  final String statusVoucher;
  final DateTime? tanggalAktif;
  final DateTime? tanggalExpired;
  final DateTime dibuatPada;
  final String namaPaket;
  final double harga;
  final String namaProfileMikrotik;
  final int idHotspot;
  final String namaServer;

  VoucherApiModel({
    required this.idVoucher,
    required this.kodeVoucher,
    required this.passwordVoucher,
    required this.idPaket,
    required this.idRouter,
    required this.statusVoucher,
    this.tanggalAktif,
    this.tanggalExpired,
    required this.dibuatPada,
    required this.namaPaket,
    required this.harga,
    required this.namaProfileMikrotik,
    required this.idHotspot,
    required this.namaServer,
  });

  factory VoucherApiModel.fromJson(Map<String, dynamic> json) {
    return VoucherApiModel(
      idVoucher: json['id_voucher'] ?? 0,
      kodeVoucher: json['kode_voucher'] ?? '',
      passwordVoucher: json['password_voucher'] ?? '',
      idPaket: json['id_paket'] ?? 0,
      idRouter: json['id_router'] ?? 0,
      statusVoucher: json['status_voucher'] ?? 'stok',
      tanggalAktif: json['tanggal_aktif'] != null
          ? DateTime.parse(json['tanggal_aktif'])
          : null,
      tanggalExpired: json['tanggal_expired'] != null
          ? DateTime.parse(json['tanggal_expired'])
          : null,
      dibuatPada: DateTime.parse(
        json['dibuat_pada'] ?? DateTime.now().toIso8601String(),
      ),
      namaPaket: json['nama_paket'] ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      namaProfileMikrotik: json['nama_profile_mikrotik'] ?? '',
      idHotspot: json['id_hotspot'] ?? 0,
      namaServer: json['nama_server'] ?? '',
    );
  }

  VoucherModel toDomain() {
    return VoucherModel(
      idVoucher: idVoucher,
      kodeVoucher: kodeVoucher,
      passwordVoucher: passwordVoucher,
      idPaket: idPaket,
      idRouter: idRouter,
      statusVoucher: VoucherStatus.fromString(statusVoucher),
      tanggalAktif: tanggalAktif,
      tanggalExpired: tanggalExpired,
      dibuatPada: dibuatPada,
      namaPaket: namaPaket,
      harga: harga,
      namaProfileMikrotik: namaProfileMikrotik,
      idHotspot: idHotspot,
      namaServer: namaServer,
    );
  }
}
