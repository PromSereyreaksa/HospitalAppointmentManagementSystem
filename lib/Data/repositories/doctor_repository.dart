import 'dart:convert';
import 'dart:io';
import '../../Domain/models/doctor.dart';
import '../../Domain/enums/user.dart';
import '../../Domain/enums/staff.dart';
import '../../Domain/enums/specialty.dart';

class DoctorRepository {
  final String filePath = 'lib/Data/storage/doctors.json';

  List<Doctor> loadAll() {
    List<Doctor> doctors = [];
    File file = File(filePath);
    if (!file.existsSync()) {
      return doctors;
    }
    String content = file.readAsStringSync();
    if (content.isEmpty) {
      return doctors;
    }
    List<dynamic> jsonList = jsonDecode(content);
    for (int i = 0; i < jsonList.length; i++) {
      doctors.add(_fromJson(jsonList[i]));
    }
    return doctors;
  }

  void saveAll(List<Doctor> doctors) {
    List<Map<String, dynamic>> jsonList = [];
    for (int i = 0; i < doctors.length; i++) {
      jsonList.add(_toJson(doctors[i]));
    }
    File file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  Doctor _fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      password: json['password'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: Gender.values.firstWhere((e) => e.toString() == 'Gender.${json['gender']}'),
      employeeId: json['employeeId'],
      department: Department.values.firstWhere((e) => e.toString() == 'Department.${json['department']}'),
      shift: Shift.values.firstWhere((e) => e.toString() == 'Shift.${json['shift']}'),
      specialty: Specialty.values.firstWhere((e) => e.toString() == 'Specialty.${json['specialty']}'),
      availability: json['availability'],
    );
  }

  Map<String, dynamic> _toJson(Doctor doctor) {
    return {
      'id': doctor.getId(),
      'password': doctor.getPassword(),
      'name': doctor.getName(),
      'email': doctor.getEmail(),
      'phoneNumber': doctor.getPhoneNumber(),
      'dateOfBirth': doctor.getDateOfBirth().toIso8601String(),
      'gender': doctor.getGender().toString().split('.').last,
      'employeeId': doctor.getEmployeeId(),
      'department': doctor.getDepartment().toString().split('.').last,
      'shift': doctor.getShift().toString().split('.').last,
      'specialty': doctor.getSpecialty().toString().split('.').last,
      'availability': doctor.getAvailability(),
    };
  }
}
