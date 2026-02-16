import '../../domain/models/auth_model.dart';

// Data Model - API response model with JSON serialization
class AuthApiModel {
  final String id;
  final String username;
  final String email;
  final String? token;
  final bool subscriptionActive;

  AuthApiModel({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.subscriptionActive = false,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      subscriptionActive: json['subscription_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'token': token,
      'subscription_active': subscriptionActive,
    };
  }

  // Convert to Domain Model
  AuthModel toDomain() {
    return AuthModel(
      id: id,
      username: username,
      email: email,
      token: token,
      subscriptionActive: subscriptionActive,
    );
  }

  // Create from Domain Model
  factory AuthApiModel.fromDomain(AuthModel model) {
    return AuthApiModel(
      id: model.id,
      username: model.username,
      email: model.email,
      token: model.token,
      subscriptionActive: model.subscriptionActive,
    );
  }
}
