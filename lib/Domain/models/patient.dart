import '../enums/user.dart';
import '../enums/blood_type.dart';
import 'user.dart';

class Patient extends User {
  final BloodType _bloodType;
  final String _address;

  Patient({
    required String id,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required BloodType bloodType,
    required String address,
  })  : _bloodType = bloodType,
        _address = address,
        super(
          id: id,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          gender: gender,
          role: UserRole.PATIENT,
        );

  BloodType getBloodType() {
    return _bloodType;
  }

  String getAddress() {
    return _address;
  }
}
