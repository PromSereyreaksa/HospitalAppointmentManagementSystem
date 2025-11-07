import '../enums/user.dart';
import '../enums/staff.dart';
import '../enums/specialty.dart';
import 'staff.dart';

class Doctor extends Staff {
  final Specialty _specialty;
  bool _availability;

  Doctor({
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
    required Specialty specialty,
    required bool availability,
  })  : _specialty = specialty,
        _availability = availability,
        super(
          id: id,
          password: password,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          dateOfBirth: dateOfBirth,
          gender: gender,
          role: UserRole.DOCTOR,
          employeeId: employeeId,
          department: department,
          shift: shift,
        );

  Specialty getSpecialty() {
    return _specialty;
  }

  bool getAvailability() {
    return _availability;
  }

  void setAvailability(bool availability) {
    _availability = availability;
  }

  // Checks if doctor is working at the given date/time based on their shift
  // Returns true if the time falls within the doctor's assigned shift hours
  bool isWorkingAt(DateTime dateTime) {
    final hour = dateTime.hour;
    switch (getShift()) {
      case Shift.MORNING:
        return hour >= 8 && hour < 16;
      case Shift.AFTERNOON:
        return hour >= 16 && hour < 24;
      case Shift.NIGHT:
        return hour >= 0 && hour < 8;
      default:
        return false;
    }
  }
}
