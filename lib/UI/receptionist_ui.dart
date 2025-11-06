import 'dart:io';
import '../Service/receptionist_service.dart';
import '../Service/appointment_service.dart';
import '../Domain/enums/user.dart';
import '../Domain/enums/blood_type.dart';
import '../Domain/enums/appointment.dart';

class ReceptionistUI {
  final ReceptionistService receptionistService;
  final AppointmentService appointmentService;

  ReceptionistUI({
    required this.receptionistService,
    required this.appointmentService,
  });

  void showReceptionistMenu() {
    while (true) {
      print('\nReceptionist Menu');
      print('1) Register New Patient');
      print('2) View All Patients');
      print('3) Search Patients');
      print('4) View All Appointments');
      print('5) View Pending Appointments');
      print('6) View Appointments by User/Doctor ID');
      print('7) Approve Appointment');
      print('8) Deny Appointment');
      print('9) Logout');
      stdout.write('Select option: ');
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        registerPatient();
      } else if (choice == '2') {
        viewAllPatients();
      } else if (choice == '3') {
        searchPatients();
      } else if (choice == '4') {
        viewAllAppointments();
      } else if (choice == '5') {
        viewPendingAppointments();
      } else if (choice == '6') {
        viewAppointmentsByUserId();
      } else if (choice == '7') {
        approveAppointment();
      } else if (choice == '8') {
        denyAppointment();
      } else if (choice == '9') {
        print('\n✓ Logged out successfully!');
        return;
      } else {
        print('\n✗ Invalid option! Please try again.');
      }
    }
  }

  void registerPatient() {
  print('\nRegister New Patient');
    
    stdout.write('\nEnter name: ');
    String? name = stdin.readLineSync();
    stdout.write('Enter email: ');
    String? email = stdin.readLineSync();
    stdout.write('Enter password: ');
    String? password = stdin.readLineSync();
    stdout.write('Enter phone number: ');
    String? phoneNumber = stdin.readLineSync();
    stdout.write('Enter date of birth (YYYY-MM-DD): ');
    String? dobStr = stdin.readLineSync();
    DateTime? dateOfBirth = DateTime.tryParse(dobStr ?? '');

    print('\nGender Options:');
    print('  1. Male');
    print('  2. Female');
    print('  3. Other');
    print('  4. Prefer Not to Say');
    stdout.write('Select gender: ');
    String? genderChoice = stdin.readLineSync();
    int genderIndex = int.tryParse(genderChoice ?? '') ?? 0;
    if (genderIndex < 1 || genderIndex > 4) {
      print('✗ Invalid gender selection!');
      return;
    }
    Gender gender = Gender.values[genderIndex - 1];

    print('\nBlood Type Options:');
    print('  1. A');
    print('  2. B');
    print('  3. AB');
    print('  4. O');
    print('  5. Unknown');
    stdout.write('Select blood type: ');
    String? bloodChoice = stdin.readLineSync();
    int bloodIndex = int.tryParse(bloodChoice ?? '') ?? 0;
    if (bloodIndex < 1 || bloodIndex > 5) {
      print('✗ Invalid blood type selection!');
      return;
    }
    BloodType bloodType = BloodType.values[bloodIndex - 1];

    stdout.write('\nEnter address: ');
    String? address = stdin.readLineSync();

    if (name == null || email == null || password == null || phoneNumber == null ||
        dateOfBirth == null || address == null) {
      print('\n✗ All fields are required!');
      return;
    }

    try {
      receptionistService.registerPatient(
        name,
        email,
        password,
        phoneNumber,
        dateOfBirth,
        gender,
        bloodType,
        address,
      );

      print('\nPatient registered successfully!');
      print('Email: $email');
      print('Password: $password');
    } catch (e) {
      print('\nFailed to register patient: $e');
    }
  }

  void viewAllPatients() {
    var patients = receptionistService.viewAllPatients();
    if (patients.isEmpty) {
      print('\nNo patients registered.');
      return;
    }

    print('\nAll Registered Patients');
    print('${"="*60}');
    for (int i = 0; i < patients.length; i++) {
      print('\n[${i + 1}] Patient ID: ${patients[i].getId()}');
      print('    Name: ${patients[i].getName()}');
      print('    Email: ${patients[i].getEmail()}');
      print('    Phone: ${patients[i].getPhoneNumber()}');
      print('    DOB: ${patients[i].getDateOfBirth().toString().split(' ')[0]}');
      print('    Gender: ${patients[i].getGender().toString().split('.')[1]}');
      print('    Blood Type: ${patients[i].getBloodType().toString().split('.')[1]}');
      print('    Address: ${patients[i].getAddress()}');
      print('    ${"-"*58}');
    }
    print('${"="*60}');
    print('Total Patients: ${patients.length}');
  }

  void searchPatients() {
    stdout.write('\nEnter search term (name, email, ID, or phone): ');
    String? searchTerm = stdin.readLineSync();
    if (searchTerm == null || searchTerm.isEmpty) {
      print('✗ Search term is required!');
      return;
    }

    var results = receptionistService.searchPatients(searchTerm);
    if (results.isEmpty) {
      print('\nNo patients found matching "$searchTerm"');
      return;
    }

    print('\nSearch Results for "$searchTerm"');
    print('${"="*60}');
    for (int i = 0; i < results.length; i++) {
      print('\n[${i + 1}] Patient ID: ${results[i].getId()}');
      print('    Name: ${results[i].getName()}');
      print('    Email: ${results[i].getEmail()}');
      print('    Phone: ${results[i].getPhoneNumber()}');
      print('    DOB: ${results[i].getDateOfBirth().toString().split(' ')[0]}');
      print('    Gender: ${results[i].getGender().toString().split('.')[1]}');
      print('    Blood Type: ${results[i].getBloodType().toString().split('.')[1]}');
      print('    Address: ${results[i].getAddress()}');
      print('    ${"-"*58}');
    }
    print('${"="*60}');
    print('Found ${results.length} patient(s)');
  }

  void viewAllAppointments() {
    var appointments = appointmentService.checkAllAppointments();
    if (appointments.isEmpty) {
      print('\nNo appointments found.');
      return;
    }
    print('\nAll Appointments');
    for (int i = 0; i < appointments.length; i++) {
      String status = appointments[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : status == 'DENIED' ? '✗' : '○';
      
  print('\n[$statusIcon] #${i + 1}  ID: ${appointments[i].getAppointmentId()}');
  print('    Patient: ${appointments[i].getPatientId()}  Doctor: ${appointments[i].getDoctorId()}');
  print('    Date: ${appointments[i].getDateTime().toString().split('.')[0]}  Slot: ${appointments[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
  print('    Type: ${appointments[i].getType().toString().split('.')[1]}  Status: $status');
    }
    print('${"="*60}');
  }

  void viewPendingAppointments() {
    var pending = appointmentService.getPendingAppointments();
    if (pending.isEmpty) {
      print('\nNo pending appointments.');
      return;
    }
    print('\nPending Appointments');
    for (int i = 0; i < pending.length; i++) {
      print('\n[⋯] Appointment #${i + 1}');
      print('  ID:        ${pending[i].getAppointmentId()}');
      print('  Patient:   ${pending[i].getPatientId()}');
      print('  Doctor:    ${pending[i].getDoctorId()}');
      print('  Date:      ${pending[i].getDateTime().toString().split('.')[0]}');
      print('  Time Slot: ${pending[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
      print('  Type:      ${pending[i].getType().toString().split('.')[1]}');
      print('  Reason:    ${pending[i].getReason()}');
      print('  ${"-"*58}');
    }
    print('${"="*60}');
  }

  void viewAppointmentsByUserId() {
  stdout.write('\nPatient or Doctor ID: ');
    String? userId = stdin.readLineSync();
    if (userId == null || userId.isEmpty) {
      print('✗ User ID is required!');
      return;
    }

    var upcomingAppointments = appointmentService.checkUpcomingAppointments(userId);
    if (upcomingAppointments.isEmpty) {
      print('\n✗ No upcoming appointments found for this user!');
      return;
    }
    
  print('\nUpcoming appointments for: $userId');
    for (int i = 0; i < upcomingAppointments.length; i++) {
      String status = upcomingAppointments[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : '○';
      
      print('\n[$statusIcon] Appointment #${i + 1}');
      print('  ID:        ${upcomingAppointments[i].getAppointmentId()}');
      print('  Patient:   ${upcomingAppointments[i].getPatientId()}');
      print('  Doctor:    ${upcomingAppointments[i].getDoctorId()}');
      print('  Date:      ${upcomingAppointments[i].getDateTime().toString().split('.')[0]}');
      print('  Time Slot: ${upcomingAppointments[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
      print('  Type:      ${upcomingAppointments[i].getType().toString().split('.')[1]}');
      print('  Status:    $status');
      print('  ${"-"*58}');
    }
    print('${"="*60}');
  }

  void approveAppointment() {
  stdout.write('\nAppointment ID to approve: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }
    try {
      appointmentService.updateStatus(appointmentId, AppointmentStatus.APPROVED);
      print('\n✓ Appointment approved successfully!');
    } catch (e) {
      print('\n✗ Failed to approve appointment: $e');
    }
  }

  void denyAppointment() {
  stdout.write('\nAppointment ID to deny: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }
    try {
      appointmentService.updateStatus(appointmentId, AppointmentStatus.DENIED);
      print('\n✓ Appointment denied!');
    } catch (e) {
      print('\n✗ Failed to deny appointment: $e');
    }
  }
}