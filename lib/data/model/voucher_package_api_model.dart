import '../../domain/models/voucher_package_model.dart';

class VoucherPackageApiModel {
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

  VoucherPackageApiModel({
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

  factory VoucherPackageApiModel.fromJson(Map<String, dynamic> json) {
    return VoucherPackageApiModel(
      id: int.tryParse(json['id_paket']?.toString() ?? json['id']?.toString() ?? '') ?? 0,
      idRouter: int.tryParse(json['id_router']?.toString() ?? ''),
      idHotspot: int.tryParse(json['id_hotspot']?.toString() ?? '') ?? 0,
      namaPaket: json['nama_paket']?.toString() ?? '',
      durasi: json['durasi']?.toString() ?? '',
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      namaProfileMikrotik: json['nama_profile_mikrotik']?.toString() ?? '',
      prefix: json['prefix']?.toString() ?? '',
      panjangUsername: int.tryParse(json['panjang_username']?.toString() ?? '') ?? 4,
      formatKarakter: json['format_karakter']?.toString() ?? 'mix',
      dataLimitMb: int.tryParse(json['data_limit_mb']?.toString() ?? '') ?? 0,
      rateLimit: json['rate_limit']?.toString(),
      dnsLogin: json['dns_login']?.toString(),
      gunakanSsl: json['gunakan_ssl'] == true || json['gunakan_ssl'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_hotspot': idHotspot,
      'nama_paket': namaPaket,
      'prefix': prefix,
      'panjang_username': panjangUsername,
      'format_karakter': formatKarakter,
      'durasi': durasi,
      'data_limit_mb': dataLimitMb,
      'harga': harga.toInt() == harga ? harga.toInt() : harga,
      'nama_profile_mikrotik': namaProfileMikrotik,
      'rate_limit': rateLimit,
      'dns_login': dnsLogin,
      'gunakan_ssl': gunakanSsl,
    };
  }

  VoucherPackageModel toDomain() {
    return VoucherPackageModel(
      id: id,
      idRouter: idRouter,
      idHotspot: idHotspot,
      namaPaket: namaPaket,
      durasi: durasi,
      harga: harga,
      namaProfileMikrotik: namaProfileMikrotik,
      prefix: prefix,
      panjangUsername: panjangUsername,
      formatKarakter: formatKarakter,
      dataLimitMb: dataLimitMb,
      rateLimit: rateLimit,
      dnsLogin: dnsLogin,
      gunakanSsl: gunakanSsl,
    );
  }

  factory VoucherPackageApiModel.fromDomain(VoucherPackageModel domain) {
    return VoucherPackageApiModel(
      id: domain.id,
      idRouter: domain.idRouter,
      idHotspot: domain.idHotspot,
      namaPaket: domain.namaPaket,
      durasi: domain.durasi,
      harga: domain.harga,
      namaProfileMikrotik: domain.namaProfileMikrotik,
      prefix: domain.prefix,
      panjangUsername: domain.panjangUsername,
      formatKarakter: domain.formatKarakter,
      dataLimitMb: domain.dataLimitMb,
      rateLimit: domain.rateLimit,
      dnsLogin: domain.dnsLogin,
      gunakanSsl: domain.gunakanSsl,
    );
  }
}
