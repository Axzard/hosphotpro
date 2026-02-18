class ApiConfig {
  // static const String baseUrl = 'http://76.13.197.9:3000';
  static const String baseUrl = 'https://api.siodev.sbs';

  // Auth endpoints
  static const String register = '$baseUrl/api/daftar-admin';
  static const String login = '$baseUrl/api/login';

  // Subscription endpoints
  static const String packages = '$baseUrl/api/langganan/paket';
  static String packageDetail(int id) => '$baseUrl/api/langganan/paket/$id';
  static const String createSubscription = '$baseUrl/api/langganan';
  static const String mySubscriptions = '$baseUrl/api/langganan/saya';
  static String updateSubscriptionStatus(int id) =>
      '$baseUrl/api/langganan/$id/status';
  static const String checkout = '$baseUrl/api/transaksi/checkout';
  static const String callback = '$baseUrl/api/transaksi/callback';

  // Router endpoints
  static const String routers = '$baseUrl/api/router';
  static String hotspots(int idRouter) => '$baseUrl/api/hotspot?id_router=$idRouter';
  static String hotspotDetail(int id) => '$baseUrl/api/hotspot/$id';
  static String updateHotspot(int id) => '$baseUrl/api/hotspot/$id';
  static String deleteHotspot(int id) => '$baseUrl/api/hotspot/$id';

  // Voucher endpoints
  static const String createVoucher = '$baseUrl/api/voucher';
  static const String createVoucherBulk = '$baseUrl/api/voucher/bulk';
  static const String voucherPackages = '$baseUrl/api/paket-voucher';
  static String packagesByRouter(int idRouter) =>
      '$baseUrl/api/paket-voucher?id_router=$idRouter';
  static String voucherPackageDetail(int id) =>
      '$baseUrl/api/paket-voucher/$id';
  static String updateVoucherPackage(int id) =>
      '$baseUrl/api/paket-voucher/$id';
  static String deleteVoucherPackage(int id) =>
      '$baseUrl/api/paket-voucher/$id';
  static String vouchersByRouter(int idRouter) =>
      '$baseUrl/api/voucher/router/$idRouter';
  static String voucherDetail(int id, int idRouter) =>
      '$baseUrl/api/voucher/$id?id_router=$idRouter';
  static String deleteVoucher(int id, int idRouter) =>
      '$baseUrl/api/voucher/$id?id_router=$idRouter';

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
