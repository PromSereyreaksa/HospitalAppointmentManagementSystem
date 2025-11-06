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

  /// Authenticates user with provided password
  bool authenticate(String password) {
    return _password == password;
  }

  /// Checks if user has the given email
  bool hasEmail(String email) {
    return _email == email;
  }

  /// Checks if user has a specific role
  bool hasRole(UserRole role) {
    return _role == role;
  }

  /// Checks if user is a doctor
  bool isDoctor() {
    return _role == UserRole.DOCTOR;
  }

  /// Checks if user is a patient
  bool isPatient() {
    return _role == UserRole.PATIENT;
  }

  /// Checks if user is a receptionist
  bool isReceptionist() {
    return _role == UserRole.RECEPTIONIST;
  }
}
