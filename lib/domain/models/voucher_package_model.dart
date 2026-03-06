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
  final String rateLimit;
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
    this.rateLimit = '3M/3M',
    this.dnsLogin,
    this.gunakanSsl = false,
  });
}
