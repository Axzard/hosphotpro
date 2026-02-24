
import 'package:hosphotpro/data/model/api_response.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthModel>> login(String username, String password);
  Future<ApiResponse<bool>> register(String username, String email, String password);
  Future<void> logout();
  Future<AuthModel?> getProfile();
  Future<bool> updateProfile(String email, String password);
}
