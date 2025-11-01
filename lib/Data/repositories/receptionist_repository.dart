import 'dart:convert';
import 'dart:io';
import '../../Domain/models/receptionist.dart';
import '../../Domain/enums/user.dart';
import '../../Domain/enums/staff.dart';

class ReceptionistRepository {
  final String filePath = 'lib/Data/storage/receptionists.json';

  List<Receptionist> loadAll() {
    List<Receptionist> receptionists = [];
    File file = File(filePath);
    if (!file.existsSync()) {
      return receptionists;
    }
    String content = file.readAsStringSync();
    if (content.isEmpty) {
      return receptionists;
    }
    List<dynamic> jsonList = jsonDecode(content);
    for (int i = 0; i < jsonList.length; i++) {
      receptionists.add(_fromJson(jsonList[i]));
    }
    return receptionists;
  }

  void saveAll(List<Receptionist> receptionists) {
    List<Map<String, dynamic>> jsonList = [];
    for (int i = 0; i < receptionists.length; i++) {
      jsonList.add(_toJson(receptionists[i]));
    }
    File file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  Receptionist _fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> _toJson(Receptionist receptionist) {
    return {
      'id': receptionist.getId(),
      'password': receptionist.getPassword(),
      'name': receptionist.getName(),
      'email': receptionist.getEmail(),
      'phoneNumber': receptionist.getPhoneNumber(),
      'dateOfBirth': receptionist.getDateOfBirth().toIso8601String(),
      'gender': receptionist.getGender().toString().split('.').last,
      'employeeId': receptionist.getEmployeeId(),
      'department': receptionist.getDepartment().toString().split('.').last,
      'shift': receptionist.getShift().toString().split('.').last,
      'deskNumber': receptionist.getDeskNumber(),
    };
  }
}
