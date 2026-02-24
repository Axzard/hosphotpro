class AuthModel {
  final String id;
  final String username;
  final String email;
  final String? token;
  final bool subscriptionActive;

  AuthModel({
    required this.id,
    required this.username,
    required this.email,
    this.token,
    this.subscriptionActive = false,
  });
}
