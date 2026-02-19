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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotspotModel &&
          runtimeType == other.runtimeType &&
          idHotspot == other.idHotspot;

  @override
  int get hashCode => idHotspot.hashCode;
}
