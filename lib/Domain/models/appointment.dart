import '../enums/appointment.dart';

class Appointment {
  final String _appointmentId;
  final String _patientId;
  final String _doctorId;
  final DateTime _dateTime;
  final AppointmentTimeSlot _timeSlot;
  final AppointmentStatus _status;
  final AppointmentType _type;
  final String _notes;
  final String _reason;

  Appointment({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
    required AppointmentTimeSlot timeSlot,
    required AppointmentStatus status,
    required AppointmentType type,
    required String notes,
    required String reason,
  })  : _appointmentId = appointmentId,
        _patientId = patientId,
        _doctorId = doctorId,
        _dateTime = dateTime,
        _timeSlot = timeSlot,
        _status = status,
        _type = type,
        _notes = notes,
        _reason = reason;

  String getAppointmentId() {
    return _appointmentId;
  }

  String getPatientId() {
    return _patientId;
  }

  String getDoctorId() {
    return _doctorId;
  }

  DateTime getDateTime() {
    return _dateTime;
  }

  AppointmentTimeSlot getTimeSlot() {
    return _timeSlot;
  }

  AppointmentStatus getStatus() {
    return _status;
  }

  AppointmentType getType() {
    return _type;
  }

  String getNotes() {
    return _notes;
  }

  String getReason() {
    return _reason;
  }
}
