
import 'package:hotspotsio/data/model/api_response.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthModel>> login(String username, String password);
  Future<ApiResponse<bool>> register(String username, String email, String password);
  Future<void> logout();
  Future<AuthModel?> getProfile();
  Future<bool> updateProfile(String email, String password);
  Future<ApiResponse<bool>> sendOtp(String email);
  Future<ApiResponse<bool>> resetPassword(String email, String kodeOtp, String passwordBaru);
}
