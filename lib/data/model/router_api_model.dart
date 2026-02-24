import '../../domain/models/router_model.dart';

class RouterApiModel {
  final int? id;
  final String namaRouter;
  final String alamatIp;
  final int portApi;
  final String usernameApi;
  final String passwordApi;
  final String keterangan;
  final String statusRouter;

  RouterApiModel({
    this.id,
    required this.namaRouter,
    required this.alamatIp,
    required this.portApi,
    required this.usernameApi,
    required this.passwordApi,
    required this.keterangan,
    this.statusRouter = 'aktif',
  });

  factory RouterApiModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['id_router'] ?? json['id_langganan'];
    int? parsedId;
    if (rawId != null) {
      if (rawId is int) {
        parsedId = rawId;
      } else {
        parsedId = int.tryParse(rawId.toString());
      }
    }

    return RouterApiModel(
      id: parsedId,
      namaRouter: json['nama_router'] ?? '',
      alamatIp: json['alamat_ip'] ?? '',
      portApi: json['port_api'] is int
          ? json['port_api']
          : (int.tryParse(json['port_api']?.toString() ?? '0') ?? 0),
      usernameApi: json['username_api'] ?? '',
      passwordApi: json['password_api'] ?? '',
      keterangan: json['keterangan'] ?? '',
      statusRouter: json['status_router'] ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama_router': namaRouter,
      'alamat_ip': alamatIp,
      'port_api': portApi,
      'username_api': usernameApi,
      'password_api': passwordApi,
      'keterangan': keterangan,
      'status_router': statusRouter,
    };
  }

  RouterModel toDomain() {
    return RouterModel(
      id: id?.toString() ?? '',
      namaRouter: namaRouter,
      alamatIp: alamatIp,
      portApi: portApi,
      usernameApi: usernameApi,
      passwordApi: passwordApi,
      keterangan: keterangan,
      statusRouter: statusRouter,
    );
  }

  factory RouterApiModel.fromDomain(RouterModel domain) {
    return RouterApiModel(
      id: int.tryParse(domain.id),
      namaRouter: domain.namaRouter,
      alamatIp: domain.alamatIp,
      portApi: domain.portApi,
      usernameApi: domain.usernameApi,
      passwordApi: domain.passwordApi,
      keterangan: domain.keterangan,
      statusRouter: domain.statusRouter,
    );
  }
}
