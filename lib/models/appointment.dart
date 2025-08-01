import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow,
}

enum AppointmentType {
  checkup,
  vaccination,
  surgery,
  consultation,
  emergency,
  followUp,
}

class Appointment {
  final String id;
  final String vetId;
  final String userId;
  final String petId;
  final String petName;
  final DateTime appointmentDate;
  final String timeSlot; // e.g., "09:00-09:30"
  final AppointmentType type;
  final AppointmentStatus status;
  final String? notes;
  final String? reason;
  final double? price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? vetNotes;
  final String? prescription;

  Appointment({
    required this.id,
    required this.vetId,
    required this.userId,
    required this.petId,
    required this.petName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.type,
    required this.status,
    this.notes,
    this.reason,
    this.price,
    required this.createdAt,
    required this.updatedAt,
    this.vetNotes,
    this.prescription,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'vetId': vetId,
      'userId': userId,
      'petId': petId,
      'petName': petName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'type': type.name,
      'status': status.name,
      'notes': notes,
      'reason': reason,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'vetNotes': vetNotes,
      'prescription': prescription,
    };
  }

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Appointment(
      id: doc.id,
      vetId: data['vetId'] ?? '',
      userId: data['userId'] ?? '',
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      type: AppointmentType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AppointmentType.checkup,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      notes: data['notes'],
      reason: data['reason'],
      price: data['price']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      vetNotes: data['vetNotes'],
      prescription: data['prescription'],
    );
  }

  Appointment copyWith({
    String? id,
    String? vetId,
    String? userId,
    String? petId,
    String? petName,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentType? type,
    AppointmentStatus? status,
    String? notes,
    String? reason,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vetNotes,
    String? prescription,
  }) {
    return Appointment(
      id: id ?? this.id,
      vetId: vetId ?? this.vetId,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vetNotes: vetNotes ?? this.vetNotes,
      prescription: prescription ?? this.prescription,
    );
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.surgery:
        return 'Surgery';
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.followUp:
        return 'Follow-up';
    }
  }

  String get formattedTime {
    try {
      final parts = timeSlot.split('-');
      if (parts.isNotEmpty) {
        return parts[0];
      }
      return timeSlot;
    } catch (e) {
      print('🔍 [Appointment] Error formatting time for appointment $id: $e');
      return timeSlot;
    }
  }

  bool get isUpcoming {
    try {
      final now = DateTime.now();
      final parts = timeSlot.split('-');
      if (parts.isEmpty) {
        print('🔍 [Appointment] Invalid timeSlot format: $timeSlot');
        return false;
      }
      
      final timePart = parts[0];
      final timeComponents = timePart.split(':');
      if (timeComponents.length < 2) {
        print('🔍 [Appointment] Invalid time format in timeSlot: $timeSlot');
        return false;
      }
      
      final hour = int.tryParse(timeComponents[0]);
      final minute = int.tryParse(timeComponents[1]);
      
      if (hour == null || minute == null) {
        print('🔍 [Appointment] Invalid hour/minute in timeSlot: $timeSlot');
        return false;
      }
      
      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        hour,
        minute,
      );
      
      final isAfterNow = appointmentDateTime.isAfter(now);
      final isValidStatus = status == AppointmentStatus.pending || status == AppointmentStatus.confirmed;
      
      print('🔍 [Appointment] ${id}: appointmentDateTime=$appointmentDateTime, now=$now, isAfterNow=$isAfterNow, status=${status.name}, isValidStatus=$isValidStatus');
      
      return isAfterNow && isValidStatus;
    } catch (e) {
      print('🔍 [Appointment] Error calculating isUpcoming for appointment $id: $e');
      return false;
    }
  }

  bool get isPast {
    try {
      final now = DateTime.now();
      final parts = timeSlot.split('-');
      if (parts.isEmpty) {
        print('🔍 [Appointment] Invalid timeSlot format for isPast: $timeSlot');
        return false;
      }
      
      final timePart = parts[0];
      final timeComponents = timePart.split(':');
      if (timeComponents.length < 2) {
        print('🔍 [Appointment] Invalid time format in timeSlot for isPast: $timeSlot');
        return false;
      }
      
      final hour = int.tryParse(timeComponents[0]);
      final minute = int.tryParse(timeComponents[1]);
      
      if (hour == null || minute == null) {
        print('🔍 [Appointment] Invalid hour/minute in timeSlot for isPast: $timeSlot');
        return false;
      }
      
      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        hour,
        minute,
      );
      
      return appointmentDateTime.isBefore(now);
    } catch (e) {
      print('🔍 [Appointment] Error calculating isPast for appointment $id: $e');
      return false;
    }
  }
}