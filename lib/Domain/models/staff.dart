import '../enums/user.dart';
import '../enums/staff.dart';
import 'user.dart';

abstract class Staff extends User {
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

  /// Checks if this staff member has the specified employee ID
  bool hasEmployeeId(String employeeId) {
    return _employeeId == employeeId;
  }

  /// Checks if this staff member works in the specified department
  bool worksInDepartment(Department department) {
    return _department == department;
  }

  /// Checks if this staff member is on the specified shift
  bool isOnShift(Shift shift) {
    return _shift == shift;
  }

  /// Checks if this staff member is currently working (based on shift and current time)
  bool isCurrentlyWorking() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    switch (_shift) {
      case Shift.MORNING:
        return hour >= 8 && hour < 16; // 8 AM - 4 PM
      case Shift.AFTERNOON:
        return hour >= 16 && hour < 24; // 4 PM - 12 AM
      case Shift.NIGHT:
        return hour >= 0 && hour < 8; // 12 AM - 8 AM
      default:
        return false;
    }
  }
}
