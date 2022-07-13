// Created quote object
import 'class.dart';

class QuoteActionResponse{
  final String? id;
  final int statusCode;

  QuoteActionResponse(this.id, this.statusCode);
}

class UserStateResponse{
  final String token;
  final String role; // TODO: Change to UserRole
  final String id;
  final String email;
  final String username;
  //final Class clas; // TODO: Implement

  UserStateResponse({required this.token, required this.role, required this.id, required this.email, required this.username, /* required this.clas */});
}

enum UserRole{
  admin,
  moderator,
  user
}
