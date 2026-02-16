import 'package:get/get.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/models/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../model/api_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = Get.find<AuthService>();
  final TokenService _tokenService = Get.find<TokenService>();

  @override
  Future<AuthModel?> getProfile() async {
    try {
      final response = await _authService.getProfile();
      // Convert AuthApiModel to AuthModel (domain)
      return response.data?.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse<AuthModel>> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      
      if (response.success && response.data != null) {
        // Save token to local storage
        final token = response.data!.token;
        if (token != null && token.isNotEmpty) {
          await _tokenService.saveToken(token);
        }
        
        return ApiResponse<AuthModel>(
          success: true,
          message: response.message,
          data: response.data!.toDomain(),
        );
      }
      
      return ApiResponse<AuthModel>(
        success: false,
        message: response.message,
        data: null,
      );
    } catch (e) {
      return ApiResponse<AuthModel>(
        success: false,
        message: 'Something went wrong: $e',
        data: null,
      );
    }
  }

  @override
  Future<void> logout() async {
    // TODO: Clear storage, etc.
  }

  @override
  Future<ApiResponse<bool>> register(String username, String email, String password) async {
    try {
      final response = await _authService.register(username, email, password);
      return response;
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Something went wrong: $e',
        data: false,
      );
    }
  }

  @override
  Future<bool> updateProfile(String email, String password) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
}
