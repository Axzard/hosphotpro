import '../../domain/models/hotspot_model.dart';

class HotspotApiModel {
  final int idHotspot;
  final String namaServer;
  final String interface;
  final String statusHotspot;
  final String dibuatPada;

  HotspotApiModel({
    required this.idHotspot,
    required this.namaServer,
    required this.interface,
    required this.statusHotspot,
    required this.dibuatPada,
  });

  factory HotspotApiModel.fromJson(Map<String, dynamic> json) {
    return HotspotApiModel(
      idHotspot: json['id_hotspot'] ?? 0,
      namaServer: json['nama_server'] ?? '',
      interface: json['interface'] ?? '',
      statusHotspot: json['status_hotspot'] ?? '',
      dibuatPada: json['dibuat_pada'] ?? '',
    );
  }

  HotspotModel toDomain() {
    return HotspotModel(
      idHotspot: idHotspot,
      namaServer: namaServer,
      interface: interface,
      statusHotspot: statusHotspot,
      dibuatPada: DateTime.parse(dibuatPada),
    );
  }
}
