import 'package:dio/dio.dart';

class ErrorUtils {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Koneksi ke server lambat. Silakan coba beberapa saat lagi.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 500 ||
              statusCode == 502 ||
              statusCode == 503 ||
              statusCode == 504) {
            return 'Server sedang dalam pemeliharaan atau perbaikan.';
          }
          if (statusCode == 404) {
            return 'Layanan tidak ditemukan (404).';
          }
          if (statusCode == 401 || statusCode == 403) {
            return 'Sesi Anda telah berakhir. Silakan login kembali.';
          }
          return 'Terjadi gangguan pada server. Silakan hubungi admin.';
        case DioExceptionType.connectionError:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        default:
          return 'Terjadi kesalahan sistem. Silakan coba lagi nanti.';
      }
    }

    final message = error.toString().toLowerCase();
    if (message.contains('500') || message.contains('internal server error')) {
      return 'Server sedang dalam pemeliharaan atau perbaikan.';
    }
    if (message.contains('timeout')) {
      return 'Waktu koneksi habis. Silakan coba lagi.';
    }
    if (message.contains('connection refused') ||
        message.contains('socketexception')) {
      return 'Koneksi terputus atau server sedang sibuk.';
    }

    return 'Terjadi kesalahan saat memproses data. Silakan coba lagi.';
  }
}
