import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/auth_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';

class AuthService extends GetxService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  // Login - Real API Integration
  Future<ApiResponse<AuthApiModel>> login(String username, String password) async {
    try {
      print('=== LOGIN DEBUG ===');
      print('URL: ${ApiConfig.login}');
      print('Username: $username');
      print('Password length: ${password.length}');
      
      final requestData = {
        'username': username,
        'password': password,
      };
      print('Request data: $requestData');

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
        print('✅ Login SUCCESS');
        
        final responseData = response.data['data'];
        
        // Parse response to AuthApiModel
        // Note: ID and Email are not in the login response, using placeholders or extracted from token if needed later.
        // The response structure is: { "pesan": "...", "data": { "token": "...", "peran": "...", "username": "..." } }
        final authData = AuthApiModel(
          id: '0', // Not provided in login response
          username: responseData['username'] ?? username,
          email: '', // Not provided in login response
          token: responseData['token'] ?? '',
          subscriptionActive: false, // Default to false, will be updated by profile/subscription check
        );

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Login Successful',
          data: authData,
        );
      } else {
        print('❌ Login FAILED - Status: ${response.statusCode}');
        final errorMessage = response.data['pesan'] ?? response.data['message'] ?? 'Invalid credentials';
        print('Error message from API: $errorMessage');
        return ApiResponse(
          success: false,
          message: errorMessage,
          data: null,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');

      String errorMessage = 'Login Failed';

      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server not responding';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  // Register - Real API Integration
  Future<ApiResponse<bool>> register(
      String username, String email, String password) async {
    try {
      print('=== REGISTRATION DEBUG ===');
      print('URL: ${ApiConfig.register}');
      print('Username: $username');
      print('Email: $email');
      print('Password length: ${password.length}');
      
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
      };
      print('Request data: $requestData');
      
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
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registration SUCCESS');
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Registration Successful',
          data: true,
        );
      } else {
        print('❌ Registration FAILED - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Registration Failed',
          data: false,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      
      String errorMessage = 'Registration Failed';
      
      if (e.response != null) {
        print('Error response data: ${e.response?.data}');
        errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server not responding';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        data: false,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: false,
      );
    }
  }

  // Get Profile (still mock for now)
  Future<ApiResponse<AuthApiModel>> getProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return ApiResponse(
      success: true,
      message: 'Profile Fetched',
      data: AuthApiModel(
        id: '1',
        username: 'admin',
        email: 'admin@hosphotpro.com',
        token: 'dummy_token_12345',
        subscriptionActive: true,
      ),
    );
  }
}
