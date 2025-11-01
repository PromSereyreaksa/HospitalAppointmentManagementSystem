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

  bool registerPatient(
    String name,
    String email,
    String password,
    String phoneNumber,
    DateTime dateOfBirth,
    Gender gender,
    BloodType bloodType,
    String address,
  ) {
    for (int i = 0; i < patients.length; i++) {
      if (patients[i].getEmail() == email) {
        return false;
      }
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
    return true;
  }
}
