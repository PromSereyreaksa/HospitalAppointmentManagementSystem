import '../Domain/models/appointment.dart';
import '../Domain/enums/appointment.dart';
import '../utils/uuid_helper.dart';
import '../Data/repositories/appointment_repository.dart';

class AppointmentService {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  List<Appointment> appointments = [];

  AppointmentService() {
    appointments = appointmentRepository.loadAll();
  }

  List<Appointment> checkAllAppointments() {
    List<Appointment> sortedAppointments = List.from(appointments);
    sortedAppointments.sort((a, b) => b.getDateTime().compareTo(a.getDateTime()));
    return sortedAppointments;
  }

  List<Appointment> checkUpcomingAppointments(String userId) {
    return appointments
        .where((appointment) =>
            (appointment.getPatientId() == userId || appointment.getDoctorId() == userId) && appointment.isUpcoming())
        .toList();
  }

  Appointment? checkAppointment(String appointmentId) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        return appointments[i];
      }
    }
    return null;
  }

  void scheduleAppointment(
    String patientId,
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
    AppointmentType type,
    String reason,
  ) {
    try {
      if (checkConflict(doctorId, dateTime, timeSlot)) {
        throw Exception('Appointment conflict detected');
      }
      String appointmentId = UuidHelper.generateUuid();
      Appointment newAppointment = Appointment(
        appointmentId: appointmentId,
        patientId: patientId,
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

  void updateStatus(String appointmentId, AppointmentStatus newStatus) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          appointments[i] = appointments[i].copyWithStatus(newStatus);
          appointmentRepository.saveAll(appointments);
          return;
        }
      }
      throw Exception('Appointment not found');
    } catch (e) {
      rethrow;
    }
  }

  List<Appointment> getPendingAppointments() {
    return appointments
        .where((appointment) => appointment.isPending())
        .toList();
  }

  void rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
    AppointmentTimeSlot newTimeSlot,
  ) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          if (checkConflict(
              appointments[i].getDoctorId(), newDateTime, newTimeSlot)) {
            throw Exception('Appointment conflict detected');
          }
          appointments[i] =
              appointments[i].copyWithDateTime(newDateTime, newTimeSlot);
          appointmentRepository.saveAll(appointments);
          return;
        }
      }
      throw Exception('Appointment not found');
    } catch (e) {
      rethrow;
    }
  }

  void requestReschedule(
    String appointmentId,
    DateTime newDateTime,
    AppointmentTimeSlot newTimeSlot,
  ) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          if (checkConflict(
              appointments[i].getDoctorId(), newDateTime, newTimeSlot)) {
            throw Exception('Appointment conflict detected');
          }
          appointments[i] = appointments[i]
              .copyWithDateTime(newDateTime, newTimeSlot)
              .copyWithStatus(AppointmentStatus.PENDING);
          appointmentRepository.saveAll(appointments);
          return;
        }
      }
      throw Exception('Appointment not found');
    } catch (e) {
      rethrow;
    }
  }

  void cancelAppointment(String appointmentId) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          appointments.removeAt(i);
          appointmentRepository.saveAll(appointments);
          return;
        }
      }
      throw Exception('Appointment not found');
    } catch (e) {
      rethrow;
    }
  }

  bool checkConflict(
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
  ) {
    return appointments.any(
      (appointment) => appointment.conflictsWith(doctorId, dateTime, timeSlot),
    );
  }
}