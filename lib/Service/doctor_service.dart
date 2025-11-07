import '../Domain/models/doctor.dart';
import '../Domain/models/appointment.dart';
import '../Data/repositories/appointment_repository.dart';

class DoctorService {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  List<Appointment> appointments = [];
  Doctor? currentDoctor;

  DoctorService() {
    appointments = appointmentRepository.loadAll();
  }

  void setCurrentDoctor(Doctor doctor) {
    currentDoctor = doctor;
  }

  List<Appointment> viewOwnSchedule() {
    try {
      if (currentDoctor == null) {
        throw Exception('No doctor is currently logged in');
      }
      return appointments
          .where((appointment) => appointment.getDoctorId() == currentDoctor!.getId())
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  void addAppointmentNotes(String appointmentId, String notes) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          if (appointments[i].getDoctorId() == (currentDoctor?.getId() ?? '')) {
            String currentNotes = appointments[i].getNotes();
            String newNotes =
                currentNotes.isEmpty ? notes : currentNotes + '\n' + notes;
            appointments[i] = appointments[i].copyWithNotes(newNotes);
            appointmentRepository.saveAll(appointments);
            return;
          }
        }
      }
      throw Exception('Appointment not found or not authorized');
    } catch (e) {
      rethrow;
    }
  }

  void updateAppointmentNotes(String appointmentId, String notes) {
    try {
      for (int i = 0; i < appointments.length; i++) {
        if (appointments[i].getAppointmentId() == appointmentId) {
          if (appointments[i].getDoctorId() == (currentDoctor?.getId() ?? '')) {
            appointments[i] = appointments[i].copyWithNotes(notes);
            appointmentRepository.saveAll(appointments);
            return;
          }
        }
      }
      throw Exception('Appointment not found or not authorized');
    } catch (e) {
      rethrow;
    }
  }

  bool isAvailable() {
    try {
      if (currentDoctor == null) {
        throw Exception('No doctor is currently logged in');
      }
      return currentDoctor!.getAvailability();
    } catch (e) {
      rethrow;
    }
  }
}
