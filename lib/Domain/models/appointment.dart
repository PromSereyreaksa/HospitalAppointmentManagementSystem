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

  /// Checks if this appointment is upcoming (in the future)
  bool isUpcoming() {
    return _dateTime.isAfter(DateTime.now());
  }

  /// Checks if this appointment is pending approval
  bool isPending() {
    return _status == AppointmentStatus.PENDING;
  }

  /// Checks if this appointment is approved
  bool isApproved() {
    return _status == AppointmentStatus.APPROVED;
  }

  /// Checks if this appointment is on the same date as the given date
  bool isSameDate(DateTime date) {
    return _dateTime.year == date.year &&
        _dateTime.month == date.month &&
        _dateTime.day == date.day;
  }

  /// Checks if this appointment conflicts with the given doctor, date, and time slot
  bool conflictsWith(String doctorId, DateTime date, AppointmentTimeSlot timeSlot) {
    return _doctorId == doctorId && isSameDate(date) && _timeSlot == timeSlot;
  }

  /// Creates a new appointment with updated status
  Appointment copyWithStatus(AppointmentStatus newStatus) {
    return Appointment(
      appointmentId: _appointmentId,
      patientId: _patientId,
      doctorId: _doctorId,
      dateTime: _dateTime,
      timeSlot: _timeSlot,
      status: newStatus,
      type: _type,
      notes: _notes,
      reason: _reason,
    );
  }

  /// Creates a new appointment with updated notes
  Appointment copyWithNotes(String newNotes) {
    return Appointment(
      appointmentId: _appointmentId,
      patientId: _patientId,
      doctorId: _doctorId,
      dateTime: _dateTime,
      timeSlot: _timeSlot,
      status: _status,
      type: _type,
      notes: newNotes,
      reason: _reason,
    );
  }

  /// Creates a new appointment with rescheduled date and time
  Appointment copyWithDateTime(
      DateTime newDateTime, AppointmentTimeSlot newTimeSlot) {
    return Appointment(
      appointmentId: _appointmentId,
      patientId: _patientId,
      doctorId: _doctorId,
      dateTime: newDateTime,
      timeSlot: newTimeSlot,
      status: _status,
      type: _type,
      notes: _notes,
      reason: _reason,
    );
  }
}
