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

  static String sanitizeServerMessage(String rawMessage) {
    if (rawMessage.isEmpty) return rawMessage;

    final lower = rawMessage.toLowerCase();

    // Detect raw database / PHP exception leak indicators
    final bool hasDbLeak = lower.contains('sqlstate') ||
        lower.contains('pdoexception') ||
        lower.contains('illuminate\\') ||
        lower.contains('stack trace') ||
        lower.contains('exception in') ||
        lower.contains('syntax error');

    // Foreign-key / integrity constraint errors
    final bool hasIntegrityError = lower.contains('1451') ||
        lower.contains('integrity constraint violation') ||
        lower.contains('foreign key constraint fails') ||
        lower.contains('cannot delete or update a parent row') ||
        lower.contains('a foreign key constraint fails');

    if (hasDbLeak || hasIntegrityError) {
      // Specifically for deletion that involves vouchers / packages
      if (lower.contains('voucher') ||
          lower.contains('paket') ||
          lower.contains('paket_voucher')) {
        return 'Paket tidak dapat dihapus karena masih terdapat voucher aktif yang terhubung.';
      }
      return 'Data sedang digunakan dan tidak dapat dihapus atau diubah saat ini.';
    }

    if (lower.contains('fatal error') || lower.contains('parse error')) {
      return 'Terjadi kesalahan sistem, silakan coba lagi nanti.';
    }

    // Fallback: if message looks like a raw server dump (very long or contains
    // newlines / HTML), replace with generic message
    if (rawMessage.length > 300 ||
        rawMessage.contains('\n') ||
        rawMessage.contains('<br') ||
        rawMessage.contains('<!DOCTYPE')) {
      return 'Terjadi kesalahan pada sistem server. Silakan coba lagi nanti.';
    }

    return rawMessage;
  }
}
