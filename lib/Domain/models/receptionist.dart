import '../enums/user.dart';
import '../enums/staff.dart';
import 'staff.dart';

class Receptionist extends Staff {
  final String _deskNumber;

  Receptionist({
    required String id,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required String employeeId,
    required Department department,
    required Shift shift,
    required String deskNumber,
  })  : _deskNumber = deskNumber,
        super(
          id: id,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          gender: gender,
          role: UserRole.RECEPTIONIST,
          employeeId: employeeId,
          department: department,
          shift: shift,
        );

  String getDeskNumber() {
    return _deskNumber;
  }
}
