import 'dart:convert';
import 'dart:io';
import '../../Domain/models/user.dart';
import '../../Domain/models/patient.dart';
import '../../Domain/models/doctor.dart';
import '../../Domain/models/receptionist.dart';
import '../../Domain/enums/user.dart';
import '../../Domain/enums/blood_type.dart';
import '../../Domain/enums/staff.dart';
import '../../Domain/enums/sepcialty.dart';

class UserRepository {
  final String filePath = 'lib/Data/storage/users.json';

  List<User> loadAll() {
    List<User> users = [];
    File file = File(filePath);
    if (!file.existsSync()) {
      return users;
    }
    String content = file.readAsStringSync();
    if (content.isEmpty) {
      return users;
    }
    
    List<dynamic> jsonList = jsonDecode(content);
    for (int i = 0; i < jsonList.length; i++) {
      Map<String, dynamic> json = jsonList[i];
      String role = json['role'];
      if (role == 'PATIENT') {
        users.add(_patientFromJson(json));
      } else if (role == 'DOCTOR') {
        users.add(_doctorFromJson(json));
      } else if (role == 'RECEPTIONIST') {
        users.add(_receptionistFromJson(json));
      }
    }
    return users;
  }

  void saveAll(List<User> users) {
    List<Map<String, dynamic>> jsonList = [];
    for (int i = 0; i < users.length; i++) {
      if (users[i].getRole() == UserRole.PATIENT) {
        jsonList.add(_patientToJson(users[i] as Patient));
      } else if (users[i].getRole() == UserRole.DOCTOR) {
        jsonList.add(_doctorToJson(users[i] as Doctor));
      } else if (users[i].getRole() == UserRole.RECEPTIONIST) {
        jsonList.add(_receptionistToJson(users[i] as Receptionist));
      }
    }
    File file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  Patient _patientFromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      password: json['password'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: Gender.values.firstWhere((e) => e.toString() == 'Gender.${json['gender']}'),
      bloodType: BloodType.values.firstWhere((e) => e.toString() == 'BloodType.${json['bloodType']}'),
      address: json['address'],
    );
  }

  Map<String, dynamic> _patientToJson(Patient patient) {
    return {
      'id': patient.getId(),
      'password': patient.getPassword(),
      'name': patient.getName(),
      'email': patient.getEmail(),
      'phoneNumber': patient.getPhoneNumber(),
      'dateOfBirth': patient.getDateOfBirth().toIso8601String(),
      'gender': patient.getGender().toString().split('.').last,
      'role': patient.getRole().toString().split('.').last,
      'bloodType': patient.getBloodType().toString().split('.').last,
      'address': patient.getAddress(),
    };
  }

  Doctor _doctorFromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> _doctorToJson(Doctor doctor) {
    return {
      'id': doctor.getId(),
      'password': doctor.getPassword(),
      'name': doctor.getName(),
      'email': doctor.getEmail(),
      'phoneNumber': doctor.getPhoneNumber(),
      'dateOfBirth': doctor.getDateOfBirth().toIso8601String(),
      'gender': doctor.getGender().toString().split('.').last,
      'role': doctor.getRole().toString().split('.').last,
      'employeeId': doctor.getEmployeeId(),
      'department': doctor.getDepartment().toString().split('.').last,
      'shift': doctor.getShift().toString().split('.').last,
      'specialty': doctor.getSpecialty().toString().split('.').last,
      'availability': doctor.getAvailability(),
    };
  }

  Receptionist _receptionistFromJson(Map<String, dynamic> json) {
    return Receptionist(
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
      deskNumber: json['deskNumber'],
    );
  }

  Map<String, dynamic> _receptionistToJson(Receptionist receptionist) {
    return {
      'id': receptionist.getId(),
      'password': receptionist.getPassword(),
      'name': receptionist.getName(),
      'email': receptionist.getEmail(),
      'phoneNumber': receptionist.getPhoneNumber(),
      'dateOfBirth': receptionist.getDateOfBirth().toIso8601String(),
      'gender': receptionist.getGender().toString().split('.').last,
      'role': receptionist.getRole().toString().split('.').last,
      'employeeId': receptionist.getEmployeeId(),
      'department': receptionist.getDepartment().toString().split('.').last,
      'shift': receptionist.getShift().toString().split('.').last,
      'deskNumber': receptionist.getDeskNumber(),
    };
  }
}
