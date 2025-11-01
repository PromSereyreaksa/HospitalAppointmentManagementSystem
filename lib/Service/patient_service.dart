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
    if (currentPatient == null) {
      return [];
    }
    List<Appointment> patientAppointments = [];
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getPatientId() == currentPatient!.getId()) {
        patientAppointments.add(appointments[i]);
      }
    }
    return patientAppointments;
  }

  Patient? viewOwnDetails() {
    return currentPatient;
  }

  bool requestAppointment(
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
    AppointmentType type,
    String reason,
  ) {
    if (currentPatient == null) {
      return false;
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
    return true;
  }
}
