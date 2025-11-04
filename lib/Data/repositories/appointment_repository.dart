import 'dart:convert';
import 'dart:io';
import '../../Domain/models/appointment.dart';
import '../../Domain/enums/appointment.dart';

class AppointmentRepository {
  final String filePath = 'lib/Data/storage/appointments.json';

  List<Appointment> loadAll() {
    List<Appointment> appointments = [];
    File file = File(filePath);
    if (!file.existsSync()) {
      return appointments;
    }

    String content = file.readAsStringSync();
    if (content.isEmpty) {
      return appointments;
    }

    List<dynamic> jsonList = jsonDecode(content);
    for (int i = 0; i < jsonList.length; i++) {
      appointments.add(_fromJson(jsonList[i]));
    }
    return appointments;
  }

  void saveAll(List<Appointment> appointments) {
    List<Map<String, dynamic>> jsonList = [];
    for (int i = 0; i < appointments.length; i++) {
      jsonList.add(_toJson(appointments[i]));
    }

    File file = File(filePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(jsonList));
  }

  Appointment _fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      dateTime: DateTime.parse(json['dateTime']),
      timeSlot: AppointmentTimeSlot.values.firstWhere(
          (e) => e.toString() == 'AppointmentTimeSlot.${json['timeSlot']}'),
      status: AppointmentStatus.values.firstWhere(
          (e) => e.toString() == 'AppointmentStatus.${json['status']}'),
      type: AppointmentType.values
          .firstWhere((e) => e.toString() == 'AppointmentType.${json['type']}'),
      notes: json['notes'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> _toJson(Appointment appointment) {
    return {
      'appointmentId': appointment.getAppointmentId(),
      'patientId': appointment.getPatientId(),
      'doctorId': appointment.getDoctorId(),
      'dateTime': appointment.getDateTime().toIso8601String(),
      'timeSlot': appointment.getTimeSlot().toString().split('.').last,
      'status': appointment.getStatus().toString().split('.').last,
      'type': appointment.getType().toString().split('.').last,
      'notes': appointment.getNotes(),
      'reason': appointment.getReason(),
    };
  }
}
