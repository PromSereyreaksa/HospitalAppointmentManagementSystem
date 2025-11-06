import '../Domain/models/patient.dart';
import '../Domain/models/appointment.dart';
import '../Domain/enums/appointment.dart';
import '../utils/uuid_helper.dart';
import '../Data/repositories/appointment_repository.dart';

class PatientService {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  List<Appointment> appointments = [];
  Patient? currentPatient;

  PatientService() {
    appointments = appointmentRepository.loadAll();
  }

  void setCurrentPatient(Patient patient) {
    currentPatient = patient;
  }

  List<Appointment> viewOwnAppointments() {
    try {
      if (currentPatient == null) {
        throw Exception('No patient is currently logged in');
      }
      return appointments
          .where(
              (appointment) => appointment.getPatientId() == currentPatient!.getId())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Patient? viewOwnDetails() {
    return currentPatient;
  }

  void requestAppointment(
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
    AppointmentType type,
    String reason,
  ) {
    try {
      if (currentPatient == null) {
        throw Exception('No patient is currently logged in');
      }
      String appointmentId = UuidHelper.generateUuid();

      Appointment newAppointment = Appointment(
        appointmentId: appointmentId,
        patientId: currentPatient!.getId(),
        doctorId: doctorId,
        dateTime: dateTime,
        timeSlot: timeSlot,
        status: AppointmentStatus.PENDING,
        type: type,
        notes: '',
        reason: reason,
      );

      appointments.add(newAppointment);
      appointmentRepository.saveAll(appointments);
    } catch (e) {
      rethrow;
    }
  }
}
