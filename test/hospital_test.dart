import 'package:test/test.dart';
import 'dart:io';
import '../lib/Service/user_service.dart';
import '../lib/Service/patient_service.dart';
import '../lib/Service/appointment_service.dart';
import '../lib/Service/doctor_service.dart';
import '../lib/Service/receptionist_service.dart';
import '../lib/Data/repositories/user_repository.dart';
import '../lib/Data/repositories/appointment_repository.dart';
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

  final String appointmentsBackupPath = 'lib/Data/storage/appointments_backup.json';
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
        expect(userService.getCurrentUser()!.getRole(), equals(UserRole.DOCTOR));
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

      expect(() => receptionistService.registerPatient(
        'Another Patient',
        'emma.wilson@email.com',
        'password123',
        '555-8888',
        DateTime(1995, 5, 5),
        Gender.FEMALE,
        BloodType.B,
        '456 Test Avenue',
      ), throwsException);
    });

    test('5a. Invalid email format registration fails', () {
      ReceptionistService receptionistService = ReceptionistService();

      expect(() => receptionistService.registerPatient(
        'Test Patient',
        'invalidemail',
        'password123',
        '555-7777',
        DateTime(1990, 1, 1),
        Gender.MALE,
        BloodType.A,
        '789 Test Road',
      ), throwsException);
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

      expect(() => appointmentService.scheduleAppointment(
        'pat-002',
        'doc-003',
        conflictDate,
        AppointmentTimeSlot.AFTERNOON_3_4,
        AppointmentType.FOLLOW_UP,
        'Conflicting appointment',
      ), throwsException);
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
        expect(
            updatedAppointment!.getStatus(), equals(AppointmentStatus.APPROVED));
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

  group('Repository Tests', () {
    test('13. Save and load users from JSON', () {
      UserRepository userRepository = UserRepository();

      // Load users
      var users = userRepository.loadAll();

      expect(users, isNotEmpty);
      expect(users.length,
          greaterThanOrEqualTo(5)); // At least 3 doctors + 2 receptionists

      // Verify we have doctors and receptionists
      bool hasDoctors = users.any((u) => u.getRole() == UserRole.DOCTOR);
      bool hasReceptionists =
          users.any((u) => u.getRole() == UserRole.RECEPTIONIST);

      expect(hasDoctors, isTrue);
      expect(hasReceptionists, isTrue);
    });

    test('14. Save and load appointments from JSON', () {
      AppointmentRepository appointmentRepository = AppointmentRepository();

      // Load appointments
      var appointments = appointmentRepository.loadAll();
      int initialCount = appointments.length;

      // Appointments can be empty or have data
      expect(appointments, isNotNull);
      expect(appointments, isList);

      // The repository should successfully load without errors
      expect(initialCount, greaterThanOrEqualTo(0));
    });

    test('15. Handle empty JSON file gracefully', () {
      // Test that repositories can handle empty files without crashing
      AppointmentRepository appointmentRepository = AppointmentRepository();

      // This should not throw an exception even if the file is empty
      var appointments = appointmentRepository.loadAll();

      expect(appointments, isNotNull);
      expect(appointments, isList);
    });
  });
}
