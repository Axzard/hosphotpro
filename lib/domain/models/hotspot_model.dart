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
}
