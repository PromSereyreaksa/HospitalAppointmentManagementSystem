import 'dart:io';
import '../Service/user_service.dart';
import '../Service/patient_service.dart';
import '../Service/doctor_service.dart';
import '../Service/receptionist_service.dart';
import '../Service/appointment_service.dart';
import '../Domain/models/user.dart';
import '../Domain/models/patient.dart';
import '../Domain/models/doctor.dart';
import '../Domain/enums/user.dart';
import 'patient_ui.dart';
import 'doctor_ui.dart';
import 'receptionist_ui.dart';

// AI generated

class CliUI {
  final UserService userService = UserService();
  final PatientService patientService = PatientService();
  final DoctorService doctorService = DoctorService();
  final ReceptionistService receptionistService = ReceptionistService();
  final AppointmentService appointmentService = AppointmentService();
  
  late final PatientUI patientUI;
  late final DoctorUI doctorUI;
  late final ReceptionistUI receptionistUI;
  
  CliUI() {
    patientUI = PatientUI(
      patientService: patientService,
      appointmentService: appointmentService,
      userService: userService,
    );
    doctorUI = DoctorUI(
      doctorService: doctorService,
      appointmentService: appointmentService,
    );
    receptionistUI = ReceptionistUI(
      receptionistService: receptionistService,
      appointmentService: appointmentService,
    );
  }

  void start() {
    print('\nHOSPITAL APPOINTMENT MANAGEMENT');
    print('===============================');
    mainMenu();
  }

  void mainMenu() {
    while (true) {
      print('\nMain Menu');
      print('1) Login');
      print('2) Exit');
      stdout.write('Select option (1-2): ');
      String? choice = stdin.readLineSync();
      
      if (choice == '1') {
        loginMenu();
      } else if (choice == '2') {
  print('\nThank you — Goodbye!\n');
        exit(0);
      } else {
        print('\nInvalid option — please try again.');
      }
    }
  }

  void loginMenu() {
  print('\nLogin');
  stdout.write('Email: ');
    String? email = stdin.readLineSync();
  stdout.write('Password: ');
    String? password = stdin.readLineSync();
    
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      print('\n✗ Email and password are required!');
      return;
    }
    
    bool success = userService.login(email, password);
    if (success) {
      User? user = userService.getCurrentUser();
      if (user == null) {
        print('\nLogin failed!');
        return;
      }
      print('\nLogin successful! Welcome ${user.getName()}');
      
      if (user.getRole() == UserRole.PATIENT) {
        patientService.setCurrentPatient(user as Patient);
        patientUI.showPatientMenu(user as Patient);
      } else if (user.getRole() == UserRole.DOCTOR) {
        doctorService.setCurrentDoctor(user as Doctor);
        doctorUI.showDoctorMenu(user as Doctor);
      } else if (user.getRole() == UserRole.RECEPTIONIST) {
        receptionistUI.showReceptionistMenu();
      }
    } else {
      print('\nInvalid email or password — please try again.');
    }
  }
}
