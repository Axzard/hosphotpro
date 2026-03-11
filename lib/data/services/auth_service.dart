import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/auth_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';

class AuthService extends GetxService {
  final Dio _dio = ApiConfig.createDio();

  Future<ApiResponse<AuthApiModel>> login(
    String username,
    String password,
  ) async {
    try {
      final requestData = {'username': username, 'password': password};

      final response = await _dio.post(
        ApiConfig.login,
        data: requestData,
        options: Options(
          headers: ApiConfig.headers(),
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login SUCCESS');

        final responseData = response.data['data'];

        final authData = AuthApiModel(
          id: '0',
          username: responseData['username'] ?? username,
          email: '',
          token: responseData['token'] ?? '',
          subscriptionActive: false,
        );

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Login Successful',
          data: authData,
        );
      } else {
        print('Login FAILED - Status: ${response.statusCode}');
        final errorMessage =
            response.data['pesan'] ??
            response.data['message'] ??
            'Invalid credentials';
        print('Error message from API: $errorMessage');
        return ApiResponse(success: false, message: errorMessage, data: null);
      }
    } on DioException catch (e) {
      print('DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');

      String errorMessage = 'Login Failed';

      if (e.response != null) {
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server not responding';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return ApiResponse(success: false, message: errorMessage, data: null);
    } catch (e) {
      print('Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse<bool>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
      };
      final response = await _dio.post(
        ApiConfig.register,
        data: requestData,
        options: Options(
          headers: ApiConfig.headers(),
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Registration SUCCESS');
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Registration Successful',
          data: true,
        );
      } else {
        print('Registration FAILED - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Registration Failed',
          data: false,
        );
      }
    } on DioException catch (e) {
      print('DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');

      String errorMessage = 'Registration Failed';

      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        errorMessage =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server not responding';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return ApiResponse(success: false, message: errorMessage, data: false);
    } catch (e) {
      print('Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: false,
      );
    }
  }

  Future<ApiResponse<AuthApiModel>> getProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse(
      success: true,
      message: 'Profile Fetched',
      data: AuthApiModel(
        id: '1',
        username: 'admin',
        email: 'admin@hotspotsio.com',
        token: 'dummy_token_12345',
        subscriptionActive: true,
      ),
    );
  }

  Future<ApiResponse<bool>> sendOtp(String email) async {
    try {
      final requestData = {'email': email};
      final response = await _dio.post(
        ApiConfig.sendOtp,
        data: requestData,
        options: Options(
          headers: ApiConfig.headers(),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'OTP berhasil dikirim',
          data: true,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Email tidak ditemukan',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Gagal mengirim OTP: $e', data: false);
    }
  }

  Future<ApiResponse<bool>> resetPassword(
    String email,
    String kodeOtp,
    String passwordBaru,
  ) async {
    try {
      final requestData = {
        'email': email,
        'kodeOtp': kodeOtp,
        'passwordBaru': passwordBaru,
      };
      final response = await _dio.post(
        ApiConfig.resetPassword,
        data: requestData,
        options: Options(
          headers: ApiConfig.headers(),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Password berhasil diubah',
          data: true,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'OTP tidak valid atau expired',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Gagal reset password: $e',
        data: false,
      );
    }
  }
}
