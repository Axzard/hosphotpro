class RouterModel {
  final String id;
  final String namaRouter;
  final String alamatIp;
  final int portApi;
  final String usernameApi;
  final String passwordApi;
  final String keterangan;
  final String statusRouter;

  RouterModel({
    required this.id,
    required this.namaRouter,
    required this.alamatIp,
    required this.portApi,
    required this.usernameApi,
    required this.passwordApi,
    required this.keterangan,
    this.statusRouter = 'aktif',
  });

  static RouterModel get semua => RouterModel(
        id: 'all',
        namaRouter: 'Semua Router',
        alamatIp: '',
        portApi: 0,
        usernameApi: '',
        passwordApi: '',
        keterangan: '',
        statusRouter: 'aktif',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouterModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: (json['id_router'] ?? json['id'] ?? '0').toString(),
      namaRouter: json['nama_router'] ?? '',
      alamatIp: json['alamat_ip'] ?? '',
      portApi: json['port_api'] ?? 8728,
      usernameApi: json['username_api'] ?? '',
      passwordApi: json['password_api'] ?? '',
      keterangan: json['keterangan'] ?? '',
      statusRouter: json['status_router'] ?? 'aktif',
    );
  }

  RouterModel copyWith({
    String? id,
    String? namaRouter,
    String? alamatIp,
    int? portApi,
    String? usernameApi,
    String? passwordApi,
    String? keterangan,
    String? statusRouter,
  }) {
    return RouterModel(
      id: id ?? this.id,
      namaRouter: namaRouter ?? this.namaRouter,
      alamatIp: alamatIp ?? this.alamatIp,
      portApi: portApi ?? this.portApi,
      usernameApi: usernameApi ?? this.usernameApi,
      passwordApi: passwordApi ?? this.passwordApi,
      keterangan: keterangan ?? this.keterangan,
      statusRouter: statusRouter ?? this.statusRouter,
    );
  }
}
