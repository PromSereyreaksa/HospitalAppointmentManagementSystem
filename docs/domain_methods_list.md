# Domain Model Business Logic Methods

This document lists all business logic methods added to each domain model.

---

## User Model

```
+authenticate(password: String): bool
+hasEmail(email: String): bool
+hasRole(role: UserRole): bool
+isDoctor(): bool
+isPatient(): bool
+isReceptionist(): bool
```

**Total: 6 methods**

---

## Patient Model

```
+isValidEmail(email: String): bool [static]
```

**Total: 1 method**

---

## Staff Model

```
+hasEmployeeId(employeeId: String): bool
+worksInDepartment(department: Department): bool
+isOnShift(shift: Shift): bool
+isCurrentlyWorking(): bool
```

**Total: 4 methods**

---

## Doctor Model

```
+isAvailable(): bool
+hasSpecialty(specialty: Specialty): bool
+worksInDepartment(department: Department): bool
+isOnShift(shift: Shift): bool
```

**Total: 5 methods**

---

## Receptionist Model

```
+isAtDesk(deskNumber: String): bool
+canApproveAppointments(): bool
+canRegisterPatients(): bool
```

**Total: 3 methods**

---

## Appointment Model

```
+isUpcoming(): bool
+isPending(): bool
+isApproved(): bool
+isSameDate(date: DateTime): bool
+conflictsWith(doctorId: String, date: DateTime, timeSlot: AppointmentTimeSlot): bool
+copyWithStatus(newStatus: AppointmentStatus): Appointment
+copyWithNotes(newNotes: String): Appointment
+copyWithDateTime(newDateTime: DateTime, newTimeSlot: AppointmentTimeSlot): Appointment
```

**Total: 12 methods**

---

## Summary

| Domain Model | Business Logic Methods |
|--------------|------------------------|
| User | 6 |
| Patient | 1 |
| Staff | 4 |
| Doctor | 5 |
| Receptionist | 3 |
| Appointment | 12 |
| **TOTAL** | **31** |
