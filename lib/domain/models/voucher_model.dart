enum VoucherStatus {
  stok,
  terjual,
  aktif,
  expired;

  static VoucherStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'stok':
        return VoucherStatus.stok;
      case 'terjual':
        return VoucherStatus.terjual;
      case 'aktif':
        return VoucherStatus.aktif;
      case 'expired':
        return VoucherStatus.expired;
      default:
        return VoucherStatus.stok;
    }
  }
}

class VoucherModel {
  final int idVoucher;
  final String kodeVoucher;
  final String passwordVoucher;
  final int idPaket;
  final int idRouter;
  final VoucherStatus statusVoucher;
  final DateTime? tanggalAktif;
  final DateTime? tanggalExpired;
  final DateTime dibuatPada;
  final String namaPaket;
  final double harga;
  final String namaProfileMikrotik;
  final int idHotspot;
  final String namaServer;

  VoucherModel({
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

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      idVoucher: json['id_voucher'] ?? 0,
      kodeVoucher: json['kode_voucher'] ?? '',
      passwordVoucher: json['password_voucher'] ?? '',
      idPaket: json['id_paket'] ?? 0,
      idRouter: json['id_router'] ?? 0,
      statusVoucher: VoucherStatus.fromString(json['status_voucher'] ?? 'stok'),
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

  bool get isStok => statusVoucher == VoucherStatus.stok;
  bool get isAktif => statusVoucher == VoucherStatus.aktif;
  bool get isExpired => statusVoucher == VoucherStatus.expired;
  bool get isTerjual => statusVoucher == VoucherStatus.terjual;
}
