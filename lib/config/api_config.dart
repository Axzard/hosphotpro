class ApiConfig {
  static const String baseUrl = 'http://76.13.197.9:3000';
  
  // Auth endpoints
  static const String register = '$baseUrl/api/daftar-admin';
  static const String login = '$baseUrl/api/login';
  
  // Subscription endpoints
  static const String packages = '$baseUrl/api/langganan/paket';
  static const String createSubscription = '$baseUrl/api/langganan';
  static const String checkout = '$baseUrl/api/transaksi/checkout';
  static const String callback = '$baseUrl/api/transaksi/callback';
  
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
