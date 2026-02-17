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
}
