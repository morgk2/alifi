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
    final parts = timeSlot.split('-');
    return parts.isNotEmpty ? parts[0] : timeSlot;
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1].split('-')[0]),
    );
    return appointmentDateTime.isAfter(now) && 
           (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed);
  }

  bool get isPast {
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(timeSlot.split(':')[0]),
      int.parse(timeSlot.split(':')[1].split('-')[0]),
    );
    return appointmentDateTime.isBefore(now);
  }
}