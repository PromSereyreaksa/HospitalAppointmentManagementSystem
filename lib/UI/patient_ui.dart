import 'dart:io';
import '../Service/patient_service.dart';
import '../Service/appointment_service.dart';
import '../Service/user_service.dart';
import '../Domain/models/patient.dart';
import '../Domain/models/doctor.dart';
import '../Domain/enums/user.dart';
import '../Domain/enums/appointment.dart';

class PatientUI {
  final PatientService patientService;
  final AppointmentService appointmentService;
  final UserService userService;

  PatientUI({
    required this.patientService,
    required this.appointmentService,
    required this.userService,
  });

  void showPatientMenu(Patient patient) {
    while (true) {
      print('\nPatient Menu');
      print('1) View My Details');
      print('2) View My Appointments');
      print('3) View Upcoming Appointments');
      print('4) View Appointment Details by ID');
      print('5) Request New Appointment');
      print('6) Logout');
      stdout.write('Select option: ');
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        viewPatientDetails(patient);
      } else if (choice == '2') {
        viewPatientAppointments(patient);
      } else if (choice == '3') {
        viewUpcomingAppointments(patient);
      } else if (choice == '4') {
        viewAppointmentById(patient);
      } else if (choice == '5') {
        requestAppointment(patient);
      } else if (choice == '6') {
        try {
          userService.logout();
          print('\n✓ Logged out successfully!');
        } catch (e) {
          print('\n✗ Logout failed: $e');
        }
        return;
      } else {
        print('\n✗ Invalid option! Please try again.');
      }
    }
  }

  void viewPatientDetails(Patient patient) {
    Patient? patientDetails = patientService.viewOwnDetails();
    if (patientDetails == null) {
      print('\nNo patient details found!');
      return;
    }
    print('\nPatient Details');
    print('Name: ${patientDetails.getName()}');
    print('Email: ${patientDetails.getEmail()}');
    print('Phone: ${patientDetails.getPhoneNumber()}');
    print('DOB: ${patientDetails.getDateOfBirth().toString().split(' ')[0]}');
    print('Gender: ${patientDetails.getGender().toString().split('.')[1]}');
    print('Blood Type: ${patientDetails.getBloodType().toString().split('.')[1]}');
    print('Address: ${patientDetails.getAddress()}');
  }

  void viewPatientAppointments(Patient patient) {
    try {
      var appointments = patientService.viewOwnAppointments();
      if (appointments.isEmpty) {
        print('\nNo appointments found!');
        return;
      }
    print('\nMy Appointments');
    for (int i = 0; i < appointments.length; i++) {
      String status = appointments[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : status == 'DENIED' ? '✗' : '○';
      
      print('\n[$statusIcon] #${i + 1}  ID: ${appointments[i].getAppointmentId()}');
      print('    Date: ${appointments[i].getDateTime().toString().split('.')[0]}');
      print('    Slot: ${appointments[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
      print('    Type: ${appointments[i].getType().toString().split('.')[1]}  Status: $status');
      print('    Reason: ${appointments[i].getReason()}');
      if (appointments[i].getNotes().isNotEmpty) {
        print('    Notes: ${appointments[i].getNotes()}');
      }
    }
    print('${"="*60}');
    } catch (e) {
      print('\n✗ Error viewing appointments: $e');
    }
  }

  void viewUpcomingAppointments(Patient patient) {
    var upcomingAppointments = appointmentService.checkUpcomingAppointments(patient.getId());
    if (upcomingAppointments.isEmpty) {
      print('\n✗ No upcoming appointments found!');
      return;
    }
    if (upcomingAppointments.isEmpty) {
      print('\nNo upcoming appointments found!');
      return;
    }
    print('\nUpcoming Appointments');
    for (int i = 0; i < upcomingAppointments.length; i++) {
      String status = upcomingAppointments[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : '○';
      
  print('\n[$statusIcon] #${i + 1}  ID: ${upcomingAppointments[i].getAppointmentId()}');
  print('    Date: ${upcomingAppointments[i].getDateTime().toString().split('.')[0]}');
  print('    Slot: ${upcomingAppointments[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
  print('    Type: ${upcomingAppointments[i].getType().toString().split('.')[1]}  Status: $status');
    }
    print('${"="*60}');
  }

  void viewAppointmentById(Patient patient) {
  stdout.write('\nAppointment ID: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }

    var appointment = appointmentService.checkAppointment(appointmentId);
    if (appointment == null) {
      print('\nAppointment not found!');
      return;
    }

    // Check if this appointment belongs to the patient
    if (appointment.getPatientId() != patient.getId()) {
      print('\n✗ You do not have permission to view this appointment!');
      return;
    }

    String status = appointment.getStatus().toString().split('.')[1];
    String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : status == 'DENIED' ? '✗' : '○';
    
    print('\nAppointment Details');
    print('Status: [$statusIcon] $status');
    print('ID: ${appointment.getAppointmentId()}');
    print('Patient: ${patient.getName()}');
    print('Doctor ID: ${appointment.getDoctorId()}');
    print('Date: ${appointment.getDateTime().toString().split('.')[0]}');
    print('Time Slot: ${appointment.getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
    print('Type: ${appointment.getType().toString().split('.')[1]}');
    print('Reason: ${appointment.getReason()}');
    if (appointment.getNotes().isNotEmpty) {
      print('Notes: ${appointment.getNotes()}');
    }
  }

  void requestAppointment(Patient patient) {
  print('\nRequest New Appointment');
    
    var allDoctors = userService.users.where((u) => u.getRole() == UserRole.DOCTOR).toList();
    if (allDoctors.isEmpty) {
      print('\n✗ No doctors available!');
      return;
    }
    
  print('\nAvailable Doctors:');
    for (int i = 0; i < allDoctors.length; i++) {
      Doctor doctor = allDoctors[i] as Doctor;
      String specialty = doctor.getSpecialty().toString().split('.')[1].replaceAll('_', ' ');
      String available = doctor.getAvailability() ? '✓ Available' : '✗ Unavailable';
      print('  ${i + 1}. Dr. ${doctor.getName()} - $specialty ($available)');
    }
    
    stdout.write('\nSelect doctor number: ');
    String? doctorChoice = stdin.readLineSync();
    if (doctorChoice == null) return;
    int doctorIndex = int.tryParse(doctorChoice) ?? 0;
    if (doctorIndex < 1 || doctorIndex > allDoctors.length) {
      print('✗ Invalid doctor selection!');
      return;
    }
    Doctor selectedDoctor = allDoctors[doctorIndex - 1] as Doctor;

    stdout.write('\nEnter date (YYYY-MM-DD): ');
    String? dateStr = stdin.readLineSync();
    if (dateStr == null) return;
    DateTime? date = DateTime.tryParse(dateStr);
    if (date == null) {
      print('✗ Invalid date format!');
      return;
    }

    print('\nAvailable Time Slots:');
    print('  1. 8:00 AM - 9:00 AM');
    print('  2. 9:00 AM - 10:00 AM');
    print('  3. 10:00 AM - 11:00 AM');
    print('  4. 1:00 PM - 2:00 PM');
    print('  5. 2:00 PM - 3:00 PM');
    print('  6. 3:00 PM - 4:00 PM');
    print('  7. 4:00 PM - 5:00 PM');
    stdout.write('\nSelect time slot: ');
    String? slotChoice = stdin.readLineSync();
    if (slotChoice == null) return;
    int slotIndex = int.tryParse(slotChoice) ?? 0;
    if (slotIndex < 1 || slotIndex > 7) {
      print('✗ Invalid slot selection!');
      return;
    }
    AppointmentTimeSlot timeSlot = AppointmentTimeSlot.values[slotIndex - 1];

    print('\nAppointment Types:');
    print('  1. Consultation');
    print('  2. Follow-up');
    print('  3. Emergency');
    print('  4. Routine Checkup');
    print('  5. Vaccination');
    stdout.write('\nSelect type: ');
    String? typeChoice = stdin.readLineSync();
    if (typeChoice == null) return;
    int typeIndex = int.tryParse(typeChoice) ?? 0;
    if (typeIndex < 1 || typeIndex > 5) {
      print('✗ Invalid type selection!');
      return;
    }
    AppointmentType type = AppointmentType.values[typeIndex - 1];

    stdout.write('\nEnter reason for visit: ');
    String? reason = stdin.readLineSync();
    if (reason == null || reason.isEmpty) {
      print('✗ Reason is required!');
      return;
    }

    try {
      patientService.requestAppointment(
        selectedDoctor.getId(),
        date,
        timeSlot,
        type,
        reason,
      );

      print('\n${"="*60}');
      print('  ✓ Appointment requested successfully!');
      print('  Status: PENDING (waiting for receptionist approval)');
      print('${"="*60}');
    } catch (e) {
      print('\n✗ Failed to request appointment: $e');
    }
  }
}
