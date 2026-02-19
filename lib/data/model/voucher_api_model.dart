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
  final String durasi;
  final String namaRouter;
  final String? alamatIp;
  final int? portApi;

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
    required this.durasi,
    required this.namaRouter,
    this.alamatIp,
    this.portApi,
  });

  factory VoucherApiModel.fromJson(Map<String, dynamic> json) {
    return VoucherApiModel(
      idVoucher: int.tryParse(json['id_voucher']?.toString() ?? '') ?? 0,
      kodeVoucher: json['kode_voucher']?.toString() ?? '',
      passwordVoucher: json['password_voucher']?.toString() ?? '',
      idPaket: int.tryParse(json['id_paket']?.toString() ?? '') ?? 0,
      idRouter: int.tryParse(json['id_router']?.toString() ?? '') ?? 0,
      statusVoucher: json['status_voucher']?.toString() ?? 'stok',
      tanggalAktif: (json['tanggal_aktif'] != null &&
              json['tanggal_aktif'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_aktif'].toString())
          : null,
      tanggalExpired: (json['tanggal_expired'] != null &&
              json['tanggal_expired'].toString().isNotEmpty)
          ? DateTime.tryParse(json['tanggal_expired'].toString())
          : null,
      dibuatPada: DateTime.tryParse(json['dibuat_pada']?.toString() ?? '') ??
          DateTime.now(),
      namaPaket: json['nama_paket']?.toString() ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      namaProfileMikrotik: json['nama_profile_mikrotik']?.toString() ?? '',
      idHotspot: int.tryParse(json['id_hotspot']?.toString() ?? '') ?? 0,
      namaServer: json['nama_server']?.toString() ?? '',
      durasi: json['durasi']?.toString() ?? '',
      namaRouter: json['nama_router']?.toString() ?? '',
      alamatIp: json['alamat_ip']?.toString(),
      portApi: int.tryParse(json['port_api']?.toString() ?? ''),
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
      durasi: durasi,
      namaRouter: namaRouter,
      alamatIp: alamatIp,
      portApi: portApi,
    );
  }
}
