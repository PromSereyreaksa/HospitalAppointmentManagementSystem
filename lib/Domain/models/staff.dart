import '../enums/user.dart';
import '../enums/staff.dart';
import 'user.dart';

class Staff extends User {
  final String _employeeId;
  final Department _department;
  final Shift _shift;

  Staff({
    required String id,
    required String password,
    required String name,
    required String email,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required Gender gender,
    required UserRole role,
    required String employeeId,
    required Department department,
    required Shift shift,
  })  : _employeeId = employeeId,
        _department = department,
        _shift = shift,
        super(
          id: id,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          gender: gender,
          role: role,
        );

  String getEmployeeId() {
    return _employeeId;
  }

  Department getDepartment() {
    return _department;
  }

  Shift getShift() {
    return _shift;
  }
}
