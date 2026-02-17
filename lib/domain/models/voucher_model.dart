class VoucherModel {
  final String id;
  final String code;
  final String status;
  final String speed;
  final String duration;
  final String quota;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    this.status = 'Belum Digunakan',
    this.speed = '5 Mbps',
    this.duration = '24 Jam',
    this.quota = '2 GB',
    required this.createdAt,
  });
}
