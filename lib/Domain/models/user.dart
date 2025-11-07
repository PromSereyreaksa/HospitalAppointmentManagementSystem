import '../enums/user.dart';

abstract class User {
  final String _id;
  final String _password;
  final String _name;
  final String _email;
  final String _phoneNumber;
  final DateTime _dateOfBirth;
  final Gender _gender;
  final UserRole _role;

  User({
    required String id,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required UserRole role,
  })  : _id = id,
        _password = password,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _dateOfBirth = dateOfBirth,
        _gender = gender,
        _role = role;

  String getId() {
    return _id;
  }

  String getPassword() {
    return _password;
  }

  String getName() {
    return _name;
  }

  String getEmail() {
    return _email;
  }

  String getPhoneNumber() {
    return _phoneNumber;
  }

  DateTime getDateOfBirth() {
    return _dateOfBirth;
  }

  Gender getGender() {
    return _gender;
  }

  UserRole getRole() {
    return _role;
  }

  // Validates email format using regex pattern
  // Returns true if email matches standard email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
