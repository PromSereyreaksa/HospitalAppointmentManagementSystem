import 'dart:convert';
import 'dart:io';
import '../../Domain/models/patient.dart';
import '../../Domain/enums/user.dart';
import '../../Domain/enums/blood_type.dart';

class PatientRepository {
  final String filePath = 'lib/Data/storage/patients.json';

  List<Patient> loadAll() {
    List<Patient> patients = [];
    File file = File(filePath);
    if (!file.existsSync()) {
      return patients;
    }
    String content = file.readAsStringSync();
    if (content.isEmpty) {
      return patients;
    }
    List<dynamic> jsonList = jsonDecode(content);
    for (int i = 0; i < jsonList.length; i++) {
      patients.add(_fromJson(jsonList[i]));
    }
    return patients;
  }

  void saveAll(List<Patient> patients) {
    List<Map<String, dynamic>> jsonList = [];
    for (int i = 0; i < patients.length; i++) {
      jsonList.add(_toJson(patients[i]));
    }
    File file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  Patient _fromJson(Map<String, dynamic> json) {
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

  Map<String, dynamic> _toJson(Patient patient) {
    return {
      'id': patient.getId(),
      'password': patient.getPassword(),
      'name': patient.getName(),
      'email': patient.getEmail(),
      'phoneNumber': patient.getPhoneNumber(),
      'dateOfBirth': patient.getDateOfBirth().toIso8601String(),
      'gender': patient.getGender().toString().split('.').last,
      'bloodType': patient.getBloodType().toString().split('.').last,
      'address': patient.getAddress(),
    };
  }
}
