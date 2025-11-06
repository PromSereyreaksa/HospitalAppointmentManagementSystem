import 'dart:io';
import '../Service/doctor_service.dart';
import '../Service/appointment_service.dart';
import '../Domain/models/doctor.dart';

class DoctorUI {
  final DoctorService doctorService;
  final AppointmentService appointmentService;

  DoctorUI({
    required this.doctorService,
    required this.appointmentService,
  });

  void showDoctorMenu(Doctor doctor) {
    while (true) {
      String availability = doctor.getAvailability() ? 'Available' : 'Unavailable';
      print('\nDoctor Menu  (${availability})');
      print('1) View My Schedule');
      print('2) View Upcoming Appointments');
      print('3) View Appointment Details by ID');
      print('4) Add Notes to Appointment');
      print('5) Update Appointment Notes');
      print('6) Toggle Availability');
      print('7) Logout');
      stdout.write('Select option: ');
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        viewDoctorSchedule(doctor);
      } else if (choice == '2') {
        viewUpcomingAppointments(doctor);
      } else if (choice == '3') {
        viewAppointmentById(doctor);
      } else if (choice == '4') {
        addAppointmentNotes(doctor);
      } else if (choice == '5') {
        updateAppointmentNotes(doctor);
      } else if (choice == '6') {
        toggleAvailability(doctor);
      } else if (choice == '7') {
        print('\n✓ Logged out successfully!');
        return;
      } else {
        print('\n✗ Invalid option! Please try again.');
      }
    }
  }

  void viewDoctorSchedule(Doctor doctor) {
    try {
      var schedule = doctorService.viewOwnSchedule();
      if (schedule.isEmpty) {
        print('\nNo appointments in your schedule.');
        return;
      }
      
    print('\nMy Schedule');
    for (int i = 0; i < schedule.length; i++) {
      String status = schedule[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : status == 'DENIED' ? '✗' : '○';
      
      print('\n[$statusIcon] #${i + 1}  ID: ${schedule[i].getAppointmentId()}');
      print('    Patient: ${schedule[i].getPatientId()}');
      print('    Date: ${schedule[i].getDateTime().toString().split('.')[0]}');
      print('    Slot: ${schedule[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
      print('    Type: ${schedule[i].getType().toString().split('.')[1]}  Status: $status');
      print('    Reason: ${schedule[i].getReason()}');
      if (schedule[i].getNotes().isNotEmpty) {
        print('    Notes: ${schedule[i].getNotes()}');
      }
    }
    print('${"="*60}');
    } catch (e) {
      print('\n✗ Error viewing schedule: $e');
    }
  }

  void viewUpcomingAppointments(Doctor doctor) {
    var upcomingAppointments = appointmentService.checkUpcomingAppointments(doctor.getId());
    if (upcomingAppointments.isEmpty) {
      print('\nNo upcoming appointments found.');
      return;
    }
    print('\nUpcoming Appointments');
    for (int i = 0; i < upcomingAppointments.length; i++) {
      String status = upcomingAppointments[i].getStatus().toString().split('.')[1];
      String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : '○';
      
      print('\n[$statusIcon] Appointment #${i + 1}');
      print('  ID:        ${upcomingAppointments[i].getAppointmentId()}');
      print('  Patient:   ${upcomingAppointments[i].getPatientId()}');
      print('  Date:      ${upcomingAppointments[i].getDateTime().toString().split('.')[0]}');
      print('  Time Slot: ${upcomingAppointments[i].getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
      print('  Type:      ${upcomingAppointments[i].getType().toString().split('.')[1]}');
      print('  Status:    $status');
      print('  ${"-"*58}');
    }
    print('${"="*60}');
  }

  void viewAppointmentById(Doctor doctor) {
  stdout.write('\nAppointment ID: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }

    var appointment = appointmentService.checkAppointment(appointmentId);
    if (appointment == null) {
      print('\nAppointment not found.');
      return;
    }

    // Check if this appointment belongs to the doctor
    if (appointment.getDoctorId() != doctor.getId()) {
      print('\n✗ You do not have permission to view this appointment!');
      return;
    }

    String status = appointment.getStatus().toString().split('.')[1];
    String statusIcon = status == 'APPROVED' ? '✓' : status == 'PENDING' ? '⋯' : status == 'DENIED' ? '✗' : '○';
    
    print('\nAppointment Details');
    print('Status: [$statusIcon] $status');
    print('ID: ${appointment.getAppointmentId()}');
    print('Patient: ${appointment.getPatientId()}');
    print('Doctor: ${doctor.getName()}');
    print('Date: ${appointment.getDateTime().toString().split('.')[0]}');
    print('Time Slot: ${appointment.getTimeSlot().toString().split('.')[1].replaceAll('_', ' ')}');
    print('Type: ${appointment.getType().toString().split('.')[1]}');
    print('Reason: ${appointment.getReason()}');
    if (appointment.getNotes().isNotEmpty) {
      print('Notes: ${appointment.getNotes()}');
    }
  }

  void addAppointmentNotes(Doctor doctor) {
    stdout.write('\nEnter Appointment ID: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }
    stdout.write('Enter notes to add: ');
    String? notes = stdin.readLineSync();
    if (notes == null || notes.isEmpty) {
      print('✗ Notes are required!');
      return;
    }
    try {
      doctorService.addAppointmentNotes(appointmentId, notes);
      print('\n✓ Notes added successfully!');
    } catch (e) {
      print('\n✗ Failed to add notes: $e');
    }
  }

  void updateAppointmentNotes(Doctor doctor) {
    stdout.write('\nEnter Appointment ID: ');
    String? appointmentId = stdin.readLineSync();
    if (appointmentId == null || appointmentId.isEmpty) {
      print('✗ Appointment ID is required!');
      return;
    }
    stdout.write('Enter new notes (will replace existing): ');
    String? notes = stdin.readLineSync();
    if (notes == null || notes.isEmpty) {
      print('✗ Notes are required!');
      return;
    }
    try {
      doctorService.updateAppointmentNotes(appointmentId, notes);
      print('\n✓ Notes updated successfully!');
    } catch (e) {
      print('\n✗ Failed to update notes: $e');
    }
  }

  void toggleAvailability(Doctor doctor) {
    doctor.setAvailability(!doctor.getAvailability());
    String status = doctor.getAvailability() ? 'Available' : 'Unavailable';
    print('\nAvailability: $status');
  }
}
