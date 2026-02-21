enum VoucherStatus {
  stok,
  terjual,
  aktif,
  expired;

  static VoucherStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'stok':
      case 'stock':
        return VoucherStatus.stok;
      case 'terjual':
      case 'sold':
        return VoucherStatus.terjual;
      case 'aktif':
      case 'active':
      case 'activated':
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
  final String durasi;
  final String namaRouter;
  final String? alamatIp;
  final int? portApi;
  final String? dnsLogin;
  final bool gunakanSsl;

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
    required this.durasi,
    required this.namaRouter,
    this.alamatIp,
    this.portApi,
    this.dnsLogin,
    this.gunakanSsl = false,
  });

  VoucherModel copyWith({
    int? idVoucher,
    String? kodeVoucher,
    String? passwordVoucher,
    int? idPaket,
    int? idRouter,
    VoucherStatus? statusVoucher,
    DateTime? tanggalAktif,
    DateTime? tanggalExpired,
    DateTime? dibuatPada,
    String? namaPaket,
    double? harga,
    String? namaProfileMikrotik,
    int? idHotspot,
    String? namaServer,
    String? durasi,
    String? namaRouter,
    String? alamatIp,
    int? portApi,
    String? dnsLogin,
    bool? gunakanSsl,
  }) {
    return VoucherModel(
      idVoucher: idVoucher ?? this.idVoucher,
      kodeVoucher: kodeVoucher ?? this.kodeVoucher,
      passwordVoucher: passwordVoucher ?? this.passwordVoucher,
      idPaket: idPaket ?? this.idPaket,
      idRouter: idRouter ?? this.idRouter,
      statusVoucher: statusVoucher ?? this.statusVoucher,
      tanggalAktif: tanggalAktif ?? this.tanggalAktif,
      tanggalExpired: tanggalExpired ?? this.tanggalExpired,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      namaPaket: namaPaket ?? this.namaPaket,
      harga: harga ?? this.harga,
      namaProfileMikrotik: namaProfileMikrotik ?? this.namaProfileMikrotik,
      idHotspot: idHotspot ?? this.idHotspot,
      namaServer: namaServer ?? this.namaServer,
      durasi: durasi ?? this.durasi,
      namaRouter: namaRouter ?? this.namaRouter,
      alamatIp: alamatIp ?? this.alamatIp,
      portApi: portApi ?? this.portApi,
      dnsLogin: dnsLogin ?? this.dnsLogin,
      gunakanSsl: gunakanSsl ?? this.gunakanSsl,
    );
  }

  bool get isStok => statusVoucher == VoucherStatus.stok;
  bool get isAktif => statusVoucher == VoucherStatus.aktif;
  bool get isExpired => statusVoucher == VoucherStatus.expired;
  bool get isTerjual => statusVoucher == VoucherStatus.terjual;
}
