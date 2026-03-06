class VoucherPackageModel {
  final int id;
  final int? idRouter;
  final int idHotspot;
  final String namaPaket;
  final String durasi;
  final double harga;
  final String namaProfileMikrotik;
  final String prefix;
  final int panjangUsername;
  final String formatKarakter;
  final int dataLimitMb;
  final String? rateLimit;
  final String? dnsLogin;
  final bool gunakanSsl;

  VoucherPackageModel({
    required this.id,
    this.idRouter,
    required this.idHotspot,
    required this.namaPaket,
    required this.durasi,
    required this.harga,
    required this.namaProfileMikrotik,
    required this.prefix,
    required this.panjangUsername,
    required this.formatKarakter,
    required this.dataLimitMb,
    this.rateLimit,
    this.dnsLogin,
    this.gunakanSsl = false,
  });
  factory VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    return VoucherPackageModel(
      id: json['id_paket'] ?? json['id'] ?? 0,
      idRouter: json['id_router'],
      idHotspot: json['id_hotspot'] ?? 0,
      namaPaket: json['nama_paket'] ?? '',
      durasi: json['durasi'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
      namaProfileMikrotik: json['nama_profile_mikrotik'] ?? '',
      prefix: json['prefix'] ?? '',
      panjangUsername: json['panjang_username'] ?? 4,
      formatKarakter: json['format_karakter'] ?? 'mix',
      dataLimitMb: json['data_limit_mb'] ?? 0,
      rateLimit: json['rate_limit'],
      dnsLogin: json['dns_login'],
      gunakanSsl: json['gunakan_ssl'] is bool ? json['gunakan_ssl'] : (json['gunakan_ssl'] == 1 || json['gunakan_ssl'] == '1'),
    );
  }

  VoucherPackageModel copyWith({
    int? id,
    int? idRouter,
    int? idHotspot,
    String? namaPaket,
    String? durasi,
    double? harga,
    String? namaProfileMikrotik,
    String? prefix,
    int? panjangUsername,
    String? formatKarakter,
    int? dataLimitMb,
    String? rateLimit,
    String? dnsLogin,
    bool? gunakanSsl,
  }) {
    return VoucherPackageModel(
      id: id ?? this.id,
      idRouter: idRouter ?? this.idRouter,
      idHotspot: idHotspot ?? this.idHotspot,
      namaPaket: namaPaket ?? this.namaPaket,
      durasi: durasi ?? this.durasi,
      harga: harga ?? this.harga,
      namaProfileMikrotik: namaProfileMikrotik ?? this.namaProfileMikrotik,
      prefix: prefix ?? this.prefix,
      panjangUsername: panjangUsername ?? this.panjangUsername,
      formatKarakter: formatKarakter ?? this.formatKarakter,
      dataLimitMb: dataLimitMb ?? this.dataLimitMb,
      rateLimit: rateLimit ?? this.rateLimit,
      dnsLogin: dnsLogin ?? this.dnsLogin,
      gunakanSsl: gunakanSsl ?? this.gunakanSsl,
    );
  }
}
