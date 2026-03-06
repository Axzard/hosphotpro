import '../../domain/models/hotspot_model.dart';

class HotspotApiModel {
  final int idHotspot;
  final int idRouter;
  final String namaServer;
  final String interface;
  final String statusHotspot;
  final String dibuatPada;

  HotspotApiModel({
    required this.idHotspot,
    required this.idRouter,
    required this.namaServer,
    required this.interface,
    required this.statusHotspot,
    required this.dibuatPada,
  });

  factory HotspotApiModel.fromJson(Map<String, dynamic> json) {
    return HotspotApiModel(
      idHotspot: json['id_hotspot'] ?? 0,
      idRouter: json['id_router'] ?? 0,
      namaServer: json['nama_server'] ?? '',
      interface: json['interface'] ?? '',
      statusHotspot: json['status_hotspot'] ?? '',
      dibuatPada: json['dibuat_pada'] ?? '',
    );
  }

  HotspotModel toDomain({int? idRouterOverride}) {
    return HotspotModel(
      idHotspot: idHotspot,
      idRouter: idRouterOverride ?? idRouter,
      namaServer: namaServer,
      interface: interface,
      statusHotspot: statusHotspot,
      dibuatPada: DateTime.parse(dibuatPada),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_hotspot': idHotspot,
      'id_router': idRouter,
      'nama_server': namaServer,
      'interface': interface,
      'status_hotspot': statusHotspot,
      'dibuat_pada': dibuatPada,
    };
  }
}
