class HotspotModel {
  final int idHotspot;
  final int idRouter;
  final String namaServer;
  final String interface;
  final String statusHotspot;
  final DateTime dibuatPada;

  HotspotModel({
    required this.idHotspot,
    required this.idRouter,
    required this.namaServer,
    required this.interface,
    required this.statusHotspot,
    required this.dibuatPada,
  });

  static HotspotModel get semua => HotspotModel(
        idHotspot: -1,
        idRouter: 0,
        namaServer: 'Semua Hotspot',
        interface: '',
        statusHotspot: 'aktif',
        dibuatPada: DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotspotModel &&
          runtimeType == other.runtimeType &&
          idHotspot == other.idHotspot;

  @override
  int get hashCode => idHotspot.hashCode;
  factory HotspotModel.fromJson(Map<String, dynamic> json) {
    return HotspotModel(
      idHotspot: json['id_hotspot'] ?? 0,
      idRouter: json['id_router'] ?? 0,
      namaServer: json['nama_server'] ?? '',
      interface: json['interface'] ?? '',
      statusHotspot: json['status_hotspot'] ?? 'aktif',
      dibuatPada: json['dibuat_pada'] != null
          ? DateTime.tryParse(json['dibuat_pada'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  HotspotModel copyWith({
    int? idHotspot,
    int? idRouter,
    String? namaServer,
    String? interface,
    String? statusHotspot,
    DateTime? dibuatPada,
  }) {
    return HotspotModel(
      idHotspot: idHotspot ?? this.idHotspot,
      idRouter: idRouter ?? this.idRouter,
      namaServer: namaServer ?? this.namaServer,
      interface: interface ?? this.interface,
      statusHotspot: statusHotspot ?? this.statusHotspot,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}
