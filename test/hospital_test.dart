import 'package:test/test.dart';
import 'dart:io';
import '../lib/Service/user_service.dart';
import '../lib/Service/patient_service.dart';
import '../lib/Service/appointment_service.dart';
import '../lib/Service/doctor_service.dart';
import '../lib/Service/receptionist_service.dart';
import '../lib/Domain/models/patient.dart';
import '../lib/Domain/models/doctor.dart';
import '../lib/Domain/enums/user.dart';
import '../lib/Domain/enums/blood_type.dart';
import '../lib/Domain/enums/appointment.dart';

void main() {
  // File paths for all data that needs backup
  final String appointmentsPath = 'lib/Data/storage/appointments.json';
  final String patientsPath = 'lib/Data/storage/patients.json';
  final String usersPath = 'lib/Data/storage/users.json';

  final String appointmentsBackupPath =
      'lib/Data/storage/appointments_backup.json';
  final String patientsBackupPath = 'lib/Data/storage/patients_backup.json';
  final String usersBackupPath = 'lib/Data/storage/users_backup.json';

  // Backup all data files before tests start
  setUpAll(() {
    // Backup appointments
    File appointmentsFile = File(appointmentsPath);
    if (appointmentsFile.existsSync()) {
      appointmentsFile.copySync(appointmentsBackupPath);
    }

    // Backup patients
    File patientsFile = File(patientsPath);
    if (patientsFile.existsSync()) {
      patientsFile.copySync(patientsBackupPath);
    }

    // Backup users
    File usersFile = File(usersPath);
    if (usersFile.existsSync()) {
      usersFile.copySync(usersBackupPath);
    }
  });

  // Restore all data files after tests complete
  tearDownAll(() {
    // Restore appointments
    File appointmentsBackup = File(appointmentsBackupPath);
    if (appointmentsBackup.existsSync()) {
      appointmentsBackup.copySync(appointmentsPath);
      appointmentsBackup.deleteSync();
    }

    // Restore patients
    File patientsBackup = File(patientsBackupPath);
    if (patientsBackup.existsSync()) {
      patientsBackup.copySync(patientsPath);
      patientsBackup.deleteSync();
    }

    // Restore users
    File usersBackup = File(usersBackupPath);
    if (usersBackup.existsSync()) {
      usersBackup.copySync(usersPath);
      usersBackup.deleteSync();
    }
  });

  // Clear appointments before appointment-related test groups
  void clearAppointments() {
    File appointmentsFile = File(appointmentsPath);
    if (appointmentsFile.existsSync()) {
      appointmentsFile.writeAsStringSync('[]');
    }
  }

  group('Authentication Tests', () {
    test('1. Valid doctor login', () {
      UserService userService = UserService();
      try {
        userService.login('john.smith@hospital.com', 'doctor123');
        expect(userService.getCurrentUser(), isNotNull);
        expect(
            userService.getCurrentUser()!.getRole(), equals(UserRole.DOCTOR));
      } catch (e) {
        fail('Login should succeed');
      }
    });

    test('2. Valid receptionist login', () {
      UserService userService = UserService();
      try {
        userService.login('alice.williams@hospital.com', 'receptionist123');
        expect(userService.getCurrentUser(), isNotNull);
        expect(userService.getCurrentUser()!.getRole(),
            equals(UserRole.RECEPTIONIST));
      } catch (e) {
        fail('Login should succeed');
      }
    });

    test('3. Invalid credentials login', () {
      UserService userService = UserService();
      expect(() => userService.login('invalid@hospital.com', 'wrongpassword'),
          throwsException);
      expect(userService.getCurrentUser(), isNull);
    });
  });

  group('Patient Service Tests', () {
    setUp(() {
      clearAppointments();
    });

    test('4. Register new patient successfully', () {
      ReceptionistService receptionistService = ReceptionistService();

      String testEmail =
          'testpatient_${DateTime.now().millisecondsSinceEpoch}@test.com';

      try {
        receptionistService.registerPatient(
          'Test Patient',
          testEmail,
          'password123',
          '555-9999',
          DateTime(1990, 1, 1),
          Gender.MALE,
          BloodType.A,
          '123 Test Street',
        );

        UserService userService = UserService();
        userService.login(testEmail, 'password123');
        expect(userService.getCurrentUser(), isNotNull);
      } catch (e) {
        fail('Registration and login should succeed');
      }
    });

    test('5. Duplicate email registration fails', () {
      ReceptionistService receptionistService = ReceptionistService();

      expect(
          () => receptionistService.registerPatient(
                'Another Patient',
                'emma.wilson@email.com',
                'password123',
                '555-8888',
                DateTime(1995, 5, 5),
                Gender.FEMALE,
                BloodType.B,
                '456 Test Avenue',
              ),
          throwsException);
    });

    test('5a. Invalid email format registration fails', () {
      ReceptionistService receptionistService = ReceptionistService();

      expect(
          () => receptionistService.registerPatient(
                'Test Patient',
                'invalidemail',
                'password123',
                '555-7777',
                DateTime(1990, 1, 1),
                Gender.MALE,
                BloodType.A,
                '789 Test Road',
              ),
          throwsException);
    });

    test('6. Request appointment successfully', () {
      PatientService patientService = PatientService();

      Patient testPatient = Patient(
        id: 'pat-test-001',
        password: 'test123',
        name: 'Test Patient',
        email: 'test@test.com',
        phoneNumber: '555-0000',
        dateOfBirth: DateTime(1990, 1, 1),
        gender: Gender.MALE,
        bloodType: BloodType.O,
        address: '123 Test St',
      );

      patientService.setCurrentPatient(testPatient);

      try {
        patientService.requestAppointment(
          'doc-001',
          DateTime.now().add(Duration(days: 7)),
          AppointmentTimeSlot.MORNING_9_10,
          AppointmentType.CONSULTATION,
          'Regular checkup',
        );
      } catch (e) {
        fail('Request appointment should succeed');
      }
    });
  });

  group('Appointment Service Tests', () {
    setUp(() {
      clearAppointments();
    });

    test('7. Schedule appointment without conflict', () {
      AppointmentService appointmentService = AppointmentService();

      int uniqueDays = 100 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime futureDate = DateTime.now().add(Duration(days: uniqueDays));

      try {
        appointmentService.scheduleAppointment(
          'pat-001',
          'doc-002',
          futureDate,
          AppointmentTimeSlot.MORNING_10_11,
          AppointmentType.ROUTINE_CHECKUP,
          'Annual physical',
        );
      } catch (e) {
        fail('Schedule appointment should succeed');
      }
    });

    test('8. Detect time slot conflict', () {
      AppointmentService appointmentService = AppointmentService();

      int uniqueDays = 150 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime conflictDate = DateTime.now().add(Duration(days: uniqueDays));

      try {
        appointmentService.scheduleAppointment(
          'pat-001',
          'doc-003',
          conflictDate,
          AppointmentTimeSlot.AFTERNOON_3_4,
          AppointmentType.CONSULTATION,
          'First appointment',
        );
      } catch (e) {
        fail('First appointment should succeed');
      }

      expect(
          () => appointmentService.scheduleAppointment(
                'pat-002',
                'doc-003',
                conflictDate,
                AppointmentTimeSlot.AFTERNOON_3_4,
                AppointmentType.FOLLOW_UP,
                'Conflicting appointment',
              ),
          throwsException);
    });

    test('9. Update appointment status to APPROVED', () {
      AppointmentService appointmentService = AppointmentService();

      int uniqueDays = 20 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime appointmentDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-001',
        appointmentDate,
        AppointmentTimeSlot.AFTERNOON_1_2,
        AppointmentType.CONSULTATION,
        'Status update test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;

      try {
        appointmentService.updateStatus(
          testAppointment.getAppointmentId(),
          AppointmentStatus.APPROVED,
        );

        var updatedAppointment = appointmentService
            .checkAppointment(testAppointment.getAppointmentId());
        expect(updatedAppointment, isNotNull);
        expect(updatedAppointment!.getStatus(),
            equals(AppointmentStatus.APPROVED));
      } catch (e) {
        fail('Update status should succeed');
      }
    });

    test('10. Cancel appointment', () {
      AppointmentService appointmentService = AppointmentService();

      int uniqueDays = 25 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime appointmentDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-002',
        appointmentDate,
        AppointmentTimeSlot.AFTERNOON_3_4,
        AppointmentType.FOLLOW_UP,
        'Cancellation test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      int initialCount = allAppointments.length;
      var testAppointment = allAppointments.last;

      try {
        appointmentService
            .cancelAppointment(testAppointment.getAppointmentId());

        var updatedAppointments = appointmentService.checkAllAppointments();
        expect(updatedAppointments.length, equals(initialCount - 1));

        var cancelledAppointment = appointmentService
            .checkAppointment(testAppointment.getAppointmentId());
        expect(cancelledAppointment, isNull);
      } catch (e) {
        fail('Cancel appointment should succeed');
      }
    });
  });

  group('Doctor Service Tests', () {
    setUp(() {
      clearAppointments();
    });

    test('11. Add notes to appointment', () {
      AppointmentService appointmentService = AppointmentService();
      UserService userService = UserService();

      int uniqueDays = 30 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime appointmentDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-001',
        appointmentDate,
        AppointmentTimeSlot.MORNING_10_11,
        AppointmentType.CONSULTATION,
        'Notes test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;

      DoctorService doctorService = DoctorService();

      userService.login('john.smith@hospital.com', 'doctor123');
      var doctor = userService.getCurrentUser();
      doctorService.setCurrentDoctor(doctor as Doctor);

      try {
        doctorService.addAppointmentNotes(
          testAppointment.getAppointmentId(),
          'Patient shows good progress',
        );

        AppointmentService verifyService = AppointmentService();
        var updatedAppointment =
            verifyService.checkAppointment(testAppointment.getAppointmentId());
        expect(updatedAppointment, isNotNull);
        expect(updatedAppointment!.getNotes(),
            contains('Patient shows good progress'));
      } catch (e) {
        fail('Add notes should succeed');
      }
    });

    test('12. Update appointment notes', () {
      AppointmentService appointmentService = AppointmentService();
      UserService userService = UserService();

      int uniqueDays = 200 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime appointmentDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-002',
        appointmentDate,
        AppointmentTimeSlot.MORNING_8_9,
        AppointmentType.FOLLOW_UP,
        'Update notes test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;

      DoctorService doctorService = DoctorService();

      userService.login('sarah.johnson@hospital.com', 'doctor123');
      var doctor = userService.getCurrentUser();
      doctorService.setCurrentDoctor(doctor as Doctor);

      doctorService.addAppointmentNotes(
        testAppointment.getAppointmentId(),
        'Initial notes',
      );

      try {
        doctorService.updateAppointmentNotes(
          testAppointment.getAppointmentId(),
          'Updated notes with new information',
        );

        AppointmentService verifyService = AppointmentService();
        var updatedAppointment =
            verifyService.checkAppointment(testAppointment.getAppointmentId());
        expect(updatedAppointment, isNotNull);
        expect(updatedAppointment!.getNotes(),
            equals('Updated notes with new information'));
      } catch (e) {
        fail('Update notes should succeed');
      }
    });
  });

  group('Receptionist Service Tests - View and Search Patients', () {
    test('13. View all patients returns list', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var patients = receptionistService.viewAllPatients();
      
      expect(patients, isNotNull);
      expect(patients, isList);
      expect(patients.length, greaterThan(0));
    });

    test('14. Search patients by name', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var results = receptionistService.searchPatients('Emma');
      
      expect(results, isList);
      expect(results.isNotEmpty, isTrue);
      expect(results.first.getName().toLowerCase(), contains('emma'));
    });

    test('15. Search patients by email', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var results = receptionistService.searchPatients('wilson@email.com');
      
      expect(results, isList);
      if (results.isNotEmpty) {
        expect(results.first.getEmail().toLowerCase(), contains('wilson'));
      }
    });

    test('16. Search patients by phone number', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var results = receptionistService.searchPatients('555-0301');
      
      expect(results, isList);
      if (results.isNotEmpty) {
        expect(results.first.getPhoneNumber(), contains('555-0301'));
      }
    });

    test('17. Search patients by ID', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var results = receptionistService.searchPatients('pat-001');
      
      expect(results, isList);
      if (results.isNotEmpty) {
        expect(results.first.getId(), equals('pat-001'));
      }
    });

    test('18. Search patients with no matches returns empty list', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var results = receptionistService.searchPatients('NonExistentPatient99999');
      
      expect(results, isList);
      expect(results.isEmpty, isTrue);
    });

    test('19. Search is case insensitive', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var resultsLower = receptionistService.searchPatients('emma');
      var resultsUpper = receptionistService.searchPatients('EMMA');
      var resultsMixed = receptionistService.searchPatients('EmMa');
      
      expect(resultsLower.length, equals(resultsUpper.length));
      expect(resultsLower.length, equals(resultsMixed.length));
    });

    test('20. Get patient by ID - existing patient', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var patient = receptionistService.getPatientById('pat-001');
      
      expect(patient, isNotNull);
      expect(patient!.getId(), equals('pat-001'));
      expect(patient.getName(), equals('Emma Wilson'));
    });

    test('21. Get patient by ID - non-existent patient', () {
      ReceptionistService receptionistService = ReceptionistService();
      
      var patient = receptionistService.getPatientById('non-existent-id-12345');
      
      expect(patient, isNull);
    });
  });

  group('Patient Service Tests - Reschedule Appointment', () {
    setUp(() {
      clearAppointments();
    });

    test('22. Request reschedule without login - uses AppointmentService', () {
      AppointmentService appointmentService = AppointmentService();
      
      int uniqueDays = 300 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime appointmentDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-001',
        appointmentDate,
        AppointmentTimeSlot.MORNING_9_10,
        AppointmentType.CONSULTATION,
        'Reschedule test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;
      appointmentService.updateStatus(
        testAppointment.getAppointmentId(),
        AppointmentStatus.APPROVED,
      );

      DateTime newDate = DateTime.now().add(Duration(days: uniqueDays + 5));
      
      try {
        appointmentService.requestReschedule(
          testAppointment.getAppointmentId(),
          newDate,
          AppointmentTimeSlot.AFTERNOON_2_3,
        );
        
        var rescheduled = appointmentService.checkAppointment(testAppointment.getAppointmentId());
        expect(rescheduled, isNotNull);
        expect(rescheduled!.getStatus(), equals(AppointmentStatus.PENDING));
      } catch (e) {
        fail('Reschedule should succeed');
      }
    });

    test('23. Reschedule appointment changes status to PENDING', () {
      AppointmentService appointmentService = AppointmentService();
      
      int uniqueDays = 310 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime originalDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-001',
        originalDate,
        AppointmentTimeSlot.MORNING_10_11,
        AppointmentType.CONSULTATION,
        'Status change test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;
      
      // Approve the appointment first
      appointmentService.updateStatus(
        testAppointment.getAppointmentId(),
        AppointmentStatus.APPROVED,
      );
      
      var approved = appointmentService.checkAppointment(testAppointment.getAppointmentId());
      expect(approved!.getStatus(), equals(AppointmentStatus.APPROVED));

      // Request reschedule
      DateTime newDate = DateTime.now().add(Duration(days: uniqueDays + 7));
      try {
        appointmentService.requestReschedule(
          testAppointment.getAppointmentId(),
          newDate,
          AppointmentTimeSlot.AFTERNOON_3_4,
        );

        var rescheduled = appointmentService.checkAppointment(testAppointment.getAppointmentId());
        expect(rescheduled, isNotNull);
        expect(rescheduled!.getStatus(), equals(AppointmentStatus.PENDING));
        expect(rescheduled.getTimeSlot(), equals(AppointmentTimeSlot.AFTERNOON_3_4));
      } catch (e) {
        fail('Reschedule should succeed');
      }
    });

    test('24. Reschedule appointment updates date and time slot', () {
      AppointmentService appointmentService = AppointmentService();
      
      int uniqueDays = 320 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime originalDate = DateTime.now().add(Duration(days: uniqueDays));
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-002',
        originalDate,
        AppointmentTimeSlot.MORNING_8_9,
        AppointmentType.FOLLOW_UP,
        'Date time test',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;
      
      DateTime newDate = DateTime.now().add(Duration(days: uniqueDays + 10));
      try {
        appointmentService.requestReschedule(
          testAppointment.getAppointmentId(),
          newDate,
          AppointmentTimeSlot.AFTERNOON_4_5,
        );

        var rescheduled = appointmentService.checkAppointment(testAppointment.getAppointmentId());
        expect(rescheduled, isNotNull);
        expect(rescheduled!.getDateTime().day, equals(newDate.day));
        expect(rescheduled.getDateTime().month, equals(newDate.month));
        expect(rescheduled.getDateTime().year, equals(newDate.year));
        expect(rescheduled.getTimeSlot(), equals(AppointmentTimeSlot.AFTERNOON_4_5));
      } catch (e) {
        fail('Reschedule should succeed');
      }
    });

    test('25. Reschedule with conflicting time slot fails', () {
      AppointmentService appointmentService = AppointmentService();
      
      int uniqueDays = 330 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime date1 = DateTime.now().add(Duration(days: uniqueDays));
      DateTime date2 = DateTime.now().add(Duration(days: uniqueDays + 5));
      
      // Create first appointment
      appointmentService.scheduleAppointment(
        'pat-001',
        'doc-001',
        date1,
        AppointmentTimeSlot.MORNING_9_10,
        AppointmentType.CONSULTATION,
        'First appointment',
      );
      
      // Create second appointment
      appointmentService.scheduleAppointment(
        'pat-002',
        'doc-001',
        date2,
        AppointmentTimeSlot.AFTERNOON_1_2,
        AppointmentType.FOLLOW_UP,
        'Second appointment',
      );

      var allAppointments = appointmentService.checkAllAppointments();
      var secondAppointment = allAppointments.firstWhere(
        (apt) => apt.getReason() == 'Second appointment',
      );

      // Try to reschedule second appointment to conflict with first
      expect(() {
        appointmentService.requestReschedule(
          secondAppointment.getAppointmentId(),
          date1,
          AppointmentTimeSlot.MORNING_9_10,
        );
      }, throwsException);
    });

    test('26. Reschedule non-existent appointment fails', () {
      AppointmentService appointmentService = AppointmentService();
      
      DateTime newDate = DateTime.now().add(Duration(days: 50));
      
      expect(() {
        appointmentService.requestReschedule(
          'non-existent-appointment-id',
          newDate,
          AppointmentTimeSlot.AFTERNOON_2_3,
        );
      }, throwsException);
    });
  });
}
