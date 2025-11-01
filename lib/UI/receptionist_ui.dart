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
      print('2) View All Appointments');
      print('3) View Pending Appointments');
      print('4) View Appointments by User/Doctor ID');
      print('5) Approve Appointment');
      print('6) Deny Appointment');
      print('7) Logout');
      stdout.write('Select option: ');
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        registerPatient();
      } else if (choice == '2') {
        viewAllAppointments();
      } else if (choice == '3') {
        viewPendingAppointments();
      } else if (choice == '4') {
        viewAppointmentsByUserId();
      } else if (choice == '5') {
        approveAppointment();
      } else if (choice == '6') {
        denyAppointment();
      } else if (choice == '7') {
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

    bool success = receptionistService.registerPatient(
      name,
      email,
      password,
      phoneNumber,
      dateOfBirth,
      gender,
      bloodType,
      address,
    );
    
    if (success) {
      print('\nPatient registered successfully!');
      print('Email: $email');
      print('Password: $password');
    } else {
      print('\nFailed to register patient — email may already exist.');
    }
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
    bool success = appointmentService.updateStatus(appointmentId, AppointmentStatus.APPROVED);
    if (success) {
      print('\n✓ Appointment approved successfully!');
    } else {
      print('\n✗ Failed to approve appointment!');
    }
  }

  void denyAppointment() {
  stdout.write('\nAppointment ID to deny: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }
    bool success = appointmentService.updateStatus(appointmentId, AppointmentStatus.DENIED);
    if (success) {
      print('\n✓ Appointment denied!');
    } else {
      print('\n✗ Failed to deny appointment!');
    }
  }
}
