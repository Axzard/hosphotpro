class VoucherPackageModel {
  final int id;
  final int idRouter;
  final int idHotspot;
  final String namaPaket;
  final String durasi;
  final double harga;
  final String namaProfileMikrotik;

  VoucherPackageModel({
    required this.id,
    required this.idRouter,
    required this.idHotspot,
    required this.namaPaket,
    required this.durasi,
    required this.harga,
    required this.namaProfileMikrotik,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_router': idRouter,
      'id_hotspot': idHotspot,
      'nama_paket': namaPaket,
      'durasi': durasi,
      'harga': harga,
      'nama_profile_mikrotik': namaProfileMikrotik,
    };
  }
}
