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
    return appointments;
  }

  List<Appointment> checkUpcomingAppointments(String userId) {
    List<Appointment> upcomingAppointments = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getPatientId() == userId || appointments[i].getDoctorId() == userId) {
        if (appointments[i].getDateTime().isAfter(now)) {
          upcomingAppointments.add(appointments[i]);
        }
      }
    }
    return upcomingAppointments;
  }

  Appointment? checkAppointment(String appointmentId) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        return appointments[i];
      }
    }
    return null;
  }

  bool scheduleAppointment(
    String patientId,
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
    AppointmentType type,
    String reason,
  ) {
    if (checkConflict(doctorId, dateTime, timeSlot)) {
      return false;
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
    return true;
  }

  bool updateStatus(String appointmentId, AppointmentStatus newStatus) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        Appointment updatedAppointment = Appointment(
          appointmentId: appointments[i].getAppointmentId(),
          patientId: appointments[i].getPatientId(),
          doctorId: appointments[i].getDoctorId(),
          dateTime: appointments[i].getDateTime(),
          timeSlot: appointments[i].getTimeSlot(),
          status: newStatus,
          type: appointments[i].getType(),
          notes: appointments[i].getNotes(),
          reason: appointments[i].getReason(),
        );
        appointments[i] = updatedAppointment;
        appointmentRepository.saveAll(appointments);
        return true;
      }
    }
    return false;
  }

  List<Appointment> getPendingAppointments() {
    List<Appointment> pendingAppointments = [];
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getStatus() == AppointmentStatus.PENDING) {
        pendingAppointments.add(appointments[i]);
      }
    }
    return pendingAppointments;
  }

  bool rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
    AppointmentTimeSlot newTimeSlot,
  ) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        if (checkConflict(appointments[i].getDoctorId(), newDateTime, newTimeSlot)) {
          return false;
        }
        Appointment updatedAppointment = Appointment(
          appointmentId: appointments[i].getAppointmentId(),
          patientId: appointments[i].getPatientId(),
          doctorId: appointments[i].getDoctorId(),
          dateTime: newDateTime,
          timeSlot: newTimeSlot,
          status: appointments[i].getStatus(),
          type: appointments[i].getType(),
          notes: appointments[i].getNotes(),
          reason: appointments[i].getReason(),
        );
        appointments[i] = updatedAppointment;
        appointmentRepository.saveAll(appointments);
        return true;
      }
    }
    return false;
  }

  bool cancelAppointment(String appointmentId) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        appointments.removeAt(i);
        appointmentRepository.saveAll(appointments);
        return true;
      }
    }
    return false;
  }

  bool checkConflict(
    String doctorId,
    DateTime dateTime,
    AppointmentTimeSlot timeSlot,
  ) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getDoctorId() == doctorId) {
        if (appointments[i].getDateTime().year == dateTime.year &&
            appointments[i].getDateTime().month == dateTime.month &&
            appointments[i].getDateTime().day == dateTime.day) {
          if (appointments[i].getTimeSlot() == timeSlot) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
