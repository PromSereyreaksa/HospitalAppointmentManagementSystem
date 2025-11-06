import '../Domain/models/patient.dart';
import '../Domain/models/user.dart';
import '../Domain/enums/user.dart';
import '../Domain/enums/blood_type.dart';
import '../utils/uuid_helper.dart';
import '../Data/repositories/patient_repository.dart';
import '../Data/repositories/user_repository.dart';

class ReceptionistService {
  final PatientRepository patientRepository = PatientRepository();
  final UserRepository userRepository = UserRepository();
  List<Patient> patients = [];
  List<User> users = [];

  ReceptionistService() {
    patients = patientRepository.loadAll();
    users = userRepository.loadAll();
  }

  void registerPatient(
    String name,
    String email,
    String password,
    String phoneNumber,
    DateTime dateOfBirth,
    Gender gender,
    BloodType bloodType,
    String address,
  ) {
    try {
      if (!Patient.isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (patients.any((patient) => patient.hasEmail(email))) {
        throw Exception('Email already exists');
      }
      String patientId = UuidHelper.generateUuid();
      Patient newPatient = Patient(
        id: patientId,
        password: password,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodType: bloodType,
        address: address,
      );
      patients.add(newPatient);
      users.add(newPatient);
      patientRepository.saveAll(patients);
      userRepository.saveAll(users);
    } catch (e) {
      rethrow;
    }
  }
}
