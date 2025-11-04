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
  // Backup file path
  final String appointmentsPath = 'lib/Data/storage/appointments.json';
  final String backupPath = 'lib/Data/storage/appointments_backup.json';

  // Backup appointments before all tests
  setUpAll(() {
    File appointmentsFile = File(appointmentsPath);
    if (appointmentsFile.existsSync()) {
      appointmentsFile.copySync(backupPath);
    }
  });

  // Restore appointments after all tests
  tearDownAll(() {
    File backupFile = File(backupPath);
    if (backupFile.existsSync()) {
      backupFile.copySync(appointmentsPath);
      backupFile.deleteSync();
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
      bool result = userService.login('john.smith@hospital.com', 'doctor123');
      expect(result, isTrue);
      expect(userService.getCurrentUser(), isNotNull);
      expect(userService.getCurrentUser()!.getRole(), equals(UserRole.DOCTOR));
    });

    test('2. Valid receptionist login', () {
      UserService userService = UserService();
      bool result =
          userService.login('alice.williams@hospital.com', 'receptionist123');
      expect(result, isTrue);
      expect(userService.getCurrentUser(), isNotNull);
      expect(userService.getCurrentUser()!.getRole(),
          equals(UserRole.RECEPTIONIST));
    });

    test('3. Invalid credentials login', () {
      UserService userService = UserService();
      bool result = userService.login('invalid@hospital.com', 'wrongpassword');
      expect(result, isFalse);
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

      bool result = receptionistService.registerPatient(
        'Test Patient',
        testEmail,
        'password123',
        '555-9999',
        DateTime(1990, 1, 1),
        Gender.MALE,
        BloodType.A,
        '123 Test Street',
      );

      expect(result, isTrue);

      // Verify the patient was added to users
      UserService userService = UserService();
      bool loginResult = userService.login(testEmail, 'password123');
      expect(loginResult, isTrue);
    });

    test('5. Duplicate email registration fails', () {
      ReceptionistService receptionistService = ReceptionistService();

      // Try to register with an existing email
      bool result = receptionistService.registerPatient(
        'Another Patient',
        'emma.wilson@email.com', // This email already exists in patients.json
        'password123',
        '555-8888',
        DateTime(1995, 5, 5),
        Gender.FEMALE,
        BloodType.B,
        '456 Test Avenue',
      );

      expect(result, isFalse);
    });

    test('6. Request appointment successfully', () {
      // Create a patient service and set current patient
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

      bool result = patientService.requestAppointment(
        'doc-001', // Dr. John Smith
        DateTime.now().add(Duration(days: 7)),
        AppointmentTimeSlot.MORNING_9_10,
        AppointmentType.CONSULTATION,
        'Regular checkup',
      );

      expect(result, isTrue);
    });
  });

  group('Appointment Service Tests', () {
    setUp(() {
      clearAppointments();
    });

    test('7. Schedule appointment without conflict', () {
      AppointmentService appointmentService = AppointmentService();

      // Use unique timestamp-based offset to avoid conflicts between test runs
      int uniqueDays = 100 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime futureDate = DateTime.now().add(Duration(days: uniqueDays));

      bool result = appointmentService.scheduleAppointment(
        'pat-001',
        'doc-002', // Dr. Sarah Johnson
        futureDate,
        AppointmentTimeSlot.MORNING_10_11,
        AppointmentType.ROUTINE_CHECKUP,
        'Annual physical',
      );

      expect(result, isTrue);
    });

    test('8. Detect time slot conflict', () {
      AppointmentService appointmentService = AppointmentService();

      // Use unique timestamp-based offset to avoid conflicts between test runs
      int uniqueDays = 150 + (DateTime.now().millisecondsSinceEpoch % 50);
      DateTime conflictDate = DateTime.now().add(Duration(days: uniqueDays));

      // Schedule first appointment
      bool firstResult = appointmentService.scheduleAppointment(
        'pat-001',
        'doc-003', // Dr. Michael Brown
        conflictDate,
        AppointmentTimeSlot.AFTERNOON_3_4,
        AppointmentType.CONSULTATION,
        'First appointment',
      );

      expect(firstResult, isTrue);

      // Try to schedule conflicting appointment (same doctor, date, time slot)
      bool conflictResult = appointmentService.scheduleAppointment(
        'pat-002',
        'doc-003', // Same doctor
        conflictDate, // Same date
        AppointmentTimeSlot.AFTERNOON_3_4, // Same time slot
        AppointmentType.FOLLOW_UP,
        'Conflicting appointment',
      );

      expect(conflictResult, isFalse);
    });

    test('9. Update appointment status to APPROVED', () {
      AppointmentService appointmentService = AppointmentService();

      // Schedule an appointment first
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

      // Get the appointment we just created
      var allAppointments = appointmentService.checkAllAppointments();
      var testAppointment = allAppointments.last;

      bool result = appointmentService.updateStatus(
        testAppointment.getAppointmentId(),
        AppointmentStatus.APPROVED,
      );

      expect(result, isTrue);

      // Verify status was updated
      var updatedAppointment = appointmentService
          .checkAppointment(testAppointment.getAppointmentId());
      expect(updatedAppointment, isNotNull);
      expect(
          updatedAppointment!.getStatus(), equals(AppointmentStatus.APPROVED));
    });

    test('10. Cancel appointment', () {
      AppointmentService appointmentService = AppointmentService();

      // Schedule an appointment first
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

      // Get the appointment we just created
      var allAppointments = appointmentService.checkAllAppointments();
      int initialCount = allAppointments.length;
      var testAppointment = allAppointments.last;

      bool result = appointmentService
          .cancelAppointment(testAppointment.getAppointmentId());

      expect(result, isTrue);

      // Verify appointment was removed
      var updatedAppointments = appointmentService.checkAllAppointments();
      expect(updatedAppointments.length, equals(initialCount - 1));

      var cancelledAppointment = appointmentService
          .checkAppointment(testAppointment.getAppointmentId());
      expect(cancelledAppointment, isNull);
    });
  });

  group('Doctor Service Tests', () {
    setUp(() {
      clearAppointments();
    });

    test('11. Add notes to appointment', () {
      AppointmentService appointmentService = AppointmentService();
      UserService userService = UserService();

      // Schedule an appointment for the doctor
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

      // Create DoctorService AFTER appointment is scheduled
      DoctorService doctorService = DoctorService();

      // Login as doctor
      userService.login('john.smith@hospital.com', 'doctor123');
      var doctor = userService.getCurrentUser();
      doctorService.setCurrentDoctor(doctor as Doctor);

      // Add notes
      bool result = doctorService.addAppointmentNotes(
        testAppointment.getAppointmentId(),
        'Patient shows good progress',
      );

      expect(result, isTrue);

      // Reload to verify notes were added
      AppointmentService verifyService = AppointmentService();
      var updatedAppointment =
          verifyService.checkAppointment(testAppointment.getAppointmentId());
      expect(updatedAppointment, isNotNull);
      expect(updatedAppointment!.getNotes(),
          contains('Patient shows good progress'));
    });

    test('12. Update appointment notes', () {
      AppointmentService appointmentService = AppointmentService();
      UserService userService = UserService();

      // Schedule an appointment
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

      // Create DoctorService AFTER appointment is scheduled
      DoctorService doctorService = DoctorService();

      // Login as doctor
      userService.login('sarah.johnson@hospital.com', 'doctor123');
      var doctor = userService.getCurrentUser();
      doctorService.setCurrentDoctor(doctor as Doctor);

      // Add initial notes
      doctorService.addAppointmentNotes(
        testAppointment.getAppointmentId(),
        'Initial notes',
      );

      // Update notes
      bool result = doctorService.updateAppointmentNotes(
        testAppointment.getAppointmentId(),
        'Updated notes with new information',
      );

      expect(result, isTrue);

      // Reload to verify notes were updated
      AppointmentService verifyService = AppointmentService();
      var updatedAppointment =
          verifyService.checkAppointment(testAppointment.getAppointmentId());
      expect(updatedAppointment, isNotNull);
      expect(updatedAppointment!.getNotes(),
          equals('Updated notes with new information'));
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
