class VoucherPackageModel {
  final int id;
  final int idRouter;
  final int idHotspot;
  final String namaPaket;
  final String durasi;
  final double harga;
  final String namaProfileMikrotik;
  final String prefix;
  final int panjangUsername;
  final String formatKarakter;
  final int dataLimitMb;

  VoucherPackageModel({
    required this.id,
    required this.idRouter,
    required this.idHotspot,
    required this.namaPaket,
    required this.durasi,
    required this.harga,
    required this.namaProfileMikrotik,
    required this.prefix,
    required this.panjangUsername,
    required this.formatKarakter,
    required this.dataLimitMb,
  });

  factory VoucherPackageModel.fromJson(Map<String, dynamic> json) {
    return VoucherPackageModel(
      id: json['id_paket'] ?? json['id'] ?? 0,
      idRouter: json['id_router'] ?? 0,
      idHotspot: json['id_hotspot'] ?? 0,
      namaPaket: json['nama_paket'] ?? '',
      durasi: json['durasi'] ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      namaProfileMikrotik: json['nama_profile_mikrotik'] ?? '',
      prefix: json['prefix'] ?? '',
      panjangUsername: json['panjang_username'] ?? 4,
      formatKarakter: json['format_karakter'] ?? 'mix',
      dataLimitMb: json['data_limit_mb'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_router': idRouter,
      'id_hotspot': idHotspot,
      'nama_paket': namaPaket,
      'prefix': prefix,
      'panjang_username': panjangUsername,
      'format_karakter': formatKarakter,
      'durasi': durasi,
      'data_limit_mb': dataLimitMb,
      'harga': harga,
      'nama_profile_mikrotik': namaProfileMikrotik,
    };
  }
}
