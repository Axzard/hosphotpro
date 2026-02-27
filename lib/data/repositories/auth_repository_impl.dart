import 'package:get/get.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/repositories/auth_repository.dart';
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

      final profile = response.data?.toDomain();

      if (profile != null && profile.username != 'admin') {
        await _tokenService.saveUsername(profile.username);
      }

      if (profile == null || profile.username == 'admin') {
        final localUsername = _tokenService.getUsername();
        if (localUsername != null) {
          return AuthModel(
            id: profile?.id ?? '0',
            username: localUsername,
            email: profile?.email ?? '',
            token: profile?.token,
            subscriptionActive: profile?.subscriptionActive ?? false,
          );
        }
      }

      return profile;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ApiResponse<AuthModel>> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data.token != null && data.token!.isNotEmpty) {
          await _tokenService.saveToken(data.token!);
        }

        await _tokenService.saveUsername(data.username);

        return ApiResponse<AuthModel>(
          success: true,
          message: response.message,
          data: data.toDomain(),
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
    await _tokenService.clearToken();
  }

  @override
  Future<ApiResponse<bool>> register(
    String username,
    String email,
    String password,
  ) async {
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
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<bool>> sendOtp(String email) async {
    try {
      return await _authService.sendOtp(email);
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Something went wrong: $e',
        data: false,
      );
    }
  }

  @override
  Future<ApiResponse<bool>> resetPassword(
    String email,
    String kodeOtp,
    String passwordBaru,
  ) async {
    try {
      return await _authService.resetPassword(email, kodeOtp, passwordBaru);
    } catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: 'Something went wrong: $e',
        data: false,
      );
    }
  }
}
