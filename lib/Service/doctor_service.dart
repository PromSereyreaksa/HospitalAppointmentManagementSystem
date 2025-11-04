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
    if (currentDoctor == null) {
      return [];
    }
    // AI generated
    List<Appointment> doctorSchedule = [];
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getDoctorId() == currentDoctor!.getId()) {
        doctorSchedule.add(appointments[i]);
      }
    }
    return doctorSchedule;
  }

  bool addAppointmentNotes(String appointmentId, String notes) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        if (appointments[i].getDoctorId() == currentDoctor?.getId()) {
          String currentNotes = appointments[i].getNotes();
          String newNotes =
              currentNotes.isEmpty ? notes : currentNotes + '\n' + notes;
          Appointment updatedAppointment = Appointment(
            appointmentId: appointments[i].getAppointmentId(),
            patientId: appointments[i].getPatientId(),
            doctorId: appointments[i].getDoctorId(),
            dateTime: appointments[i].getDateTime(),
            timeSlot: appointments[i].getTimeSlot(),
            status: appointments[i].getStatus(),
            type: appointments[i].getType(),
            notes: newNotes,
            reason: appointments[i].getReason(),
          );
          appointments[i] = updatedAppointment;
          appointmentRepository.saveAll(appointments);
          return true;
        }
      }
    }
    return false;
  }

  bool updateAppointmentNotes(String appointmentId, String notes) {
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].getAppointmentId() == appointmentId) {
        if (appointments[i].getDoctorId() == currentDoctor?.getId()) {
          Appointment updatedAppointment = Appointment(
            appointmentId: appointments[i].getAppointmentId(),
            patientId: appointments[i].getPatientId(),
            doctorId: appointments[i].getDoctorId(),
            dateTime: appointments[i].getDateTime(),
            timeSlot: appointments[i].getTimeSlot(),
            status: appointments[i].getStatus(),
            type: appointments[i].getType(),
            notes: notes,
            reason: appointments[i].getReason(),
          );
          appointments[i] = updatedAppointment;
          appointmentRepository.saveAll(appointments);
          return true;
        }
      }
    }
    return false;
  }

  bool isAvailable() {
    if (currentDoctor == null) {
      return false;
    }
    return currentDoctor!.getAvailability();
  }
}
