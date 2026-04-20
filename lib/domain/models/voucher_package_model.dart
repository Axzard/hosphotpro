class VoucherPackageModel {
  final int id;
  final int? idRouter;
  final int idHotspot;
  final String namaPaket;
  final String durasi;
  final double harga;
  final String prefix;
  final int panjangUsername;
  final String formatKarakter;
  final String? rateLimit;
  final bool gunakanSsl;

  VoucherPackageModel({
    required this.id,
    this.idRouter,
    required this.idHotspot,
    required this.namaPaket,
    required this.durasi,
    required this.harga,
    required this.prefix,
    required this.panjangUsername,
    required this.formatKarakter,
    this.rateLimit,
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
      prefix: json['prefix'] ?? '',
      panjangUsername: json['panjang_username'] ?? 4,
      formatKarakter: json['format_karakter'] ?? 'mix',
      rateLimit: json['rate_limit'],
      gunakanSsl: json['gunakan_ssl'] is bool
          ? json['gunakan_ssl']
          : (json['gunakan_ssl'] == 1 || json['gunakan_ssl'] == '1'),
    );
  }

  VoucherPackageModel copyWith({
    int? id,
    int? idRouter,
    int? idHotspot,
    String? namaPaket,
    String? durasi,
    double? harga,
    String? prefix,
    int? panjangUsername,
    String? formatKarakter,
    String? rateLimit,
    bool? gunakanSsl,
  }) {
    return VoucherPackageModel(
      id: id ?? this.id,
      idRouter: idRouter ?? this.idRouter,
      idHotspot: idHotspot ?? this.idHotspot,
      namaPaket: namaPaket ?? this.namaPaket,
      durasi: durasi ?? this.durasi,
      harga: harga ?? this.harga,
      prefix: prefix ?? this.prefix,
      panjangUsername: panjangUsername ?? this.panjangUsername,
      formatKarakter: formatKarakter ?? this.formatKarakter,
      rateLimit: rateLimit ?? this.rateLimit,
      gunakanSsl: gunakanSsl ?? this.gunakanSsl,
    );
  }
}
