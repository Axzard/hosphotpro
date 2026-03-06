class ApiConfig {
  static const String baseUrl = 'https://api.siodev.sbs';
  // static const String baseUrl = 'http://76.13.197.9:3000';

  // Auth endpoints
  static const String register = '$baseUrl/api/daftar-admin';
  static const String login = '$baseUrl/api/login';
  static const String sendOtp = '$baseUrl/api/kirim-otp';
  static const String resetPassword = '$baseUrl/api/reset-password';

  // Langganan endpoints
  static const String packages = '$baseUrl/api/langganan/paket';
  static String packageDetail(int id) => '$baseUrl/api/langganan/paket/$id';
  static const String createSubscription = '$baseUrl/api/langganan';
  static const String mySubscriptions = '$baseUrl/api/langganan/saya';
  static String updateSubscriptionStatus(int id) => '$baseUrl/api/langganan/$id/status';

  // Transaksi endpoints
  static const String checkout = '$baseUrl/api/transaksi/checkout';
  static const String perpanjang = '$baseUrl/api/transaksi/perpanjang';
  static const String callback = '$baseUrl/api/transaksi/callback';

  // Router endpoints
  static const String routers = '$baseUrl/api/router';
  static String routerPing(int id) => '$baseUrl/api/router/$id/ping';
  static String hotspots(int idRouter) => '$baseUrl/api/hotspot?id_router=$idRouter';
  static const String hotspotAll = '$baseUrl/api/hotspot/all';
  static String hotspotDetail(int id) => '$baseUrl/api/hotspot/$id';
  static String updateHotspot(int id) => '$baseUrl/api/hotspot/$id';
  static String deleteHotspot(int id) => '$baseUrl/api/hotspot/$id';
  static const String syncHotspots = '$baseUrl/api/hotspot/sync';

  // Voucher endpoints
  static const String createVoucher = '$baseUrl/api/voucher';
  static const String createVoucherBulk = '$baseUrl/api/voucher/bulk';
  static const String voucherPackages = '$baseUrl/api/paket-voucher';
  static String packagesByHotspot(int idHotspot) => '$baseUrl/api/paket-voucher?id_hotspot=$idHotspot';
  static const String paketVoucherUser = '$baseUrl/api/paket-voucher/user';
  static String voucherPackageDetail(int id) => '$baseUrl/api/paket-voucher/$id';
  static String updateVoucherPackage(int id) => '$baseUrl/api/paket-voucher/$id';
  static String deleteVoucherPackage(int id) => '$baseUrl/api/paket-voucher/$id';
  static String vouchersByPackage(int idPaket) => '$baseUrl/api/voucher/paket/$idPaket';
  static String vouchersByHotspot(int idHotspot) => '$baseUrl/api/voucher/hotspot/$idHotspot';
  static String voucherDetail(int id) => '$baseUrl/api/voucher/$id';
  static String deleteVoucher(int id) => '$baseUrl/api/voucher/$id';
  static const String vouchersAktif = '$baseUrl/api/voucher/aktif';
  static String sellVoucher(int id) => '$baseUrl/api/voucher/jual/$id';

  // Report (Laporan) endpoints
  static const String reportDashboard = '$baseUrl/api/laporan/dashboard';
  static const String reportDaily = '$baseUrl/api/laporan/per-hari';
  static const String reportMonthly = '$baseUrl/api/laporan/per-bulan';
  static const String reportYearly = '$baseUrl/api/laporan/per-tahun';
  static const String reportHarian = '$baseUrl/api/laporan/harian';
  static const String reportGrouped = '$baseUrl/api/laporan/grouped';
  static const String reportRange = '$baseUrl/api/laporan/range';
  static const String reportSummary = '$baseUrl/api/laporan/summary';
  static const String reportRefresh = '$baseUrl/api/laporan/refresh';

  // Headers
  static Map<String, String> headers({String? token}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
