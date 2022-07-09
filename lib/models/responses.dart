// Created quote object
import 'class.dart';

class QuoteResponse{
  final String? id;
  final int statusCode;

  QuoteResponse(this.id, this.statusCode);
}

class LoginResponse{
  final String token;
  final UserRole role;
  final String id;
  final String email;
  final String username;
  final Class clas;

  LoginResponse({required this.token, required this.role, required this.id, required this.email, required this.username, required this.clas});
}

enum UserRole{
  admin,
  moderator,
  user
}
