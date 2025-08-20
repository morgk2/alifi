import 'package:cloud_firestore/cloud_firestore.dart';

enum MeetingStatus {
  proposed,
  confirmed,
  rejected,
  completed,
}

class Meeting {
  final String id;
  final String proposerId;
  final String receiverId;
  final String place;
  final DateTime scheduledTime;
  final MeetingStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Meeting({
    required this.id,
    required this.proposerId,
    required this.receiverId,
    required this.place,
    required this.scheduledTime,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'proposerId': proposerId,
      'receiverId': receiverId,
      'place': place,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status.name,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meeting(
      id: doc.id,
      proposerId: data['proposerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      place: data['place'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      status: MeetingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MeetingStatus.proposed,
      ),
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Meeting copyWith({
    String? id,
    String? proposerId,
    String? receiverId,
    String? place,
    DateTime? scheduledTime,
    MeetingStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Meeting(
      id: id ?? this.id,
      proposerId: proposerId ?? this.proposerId,
      receiverId: receiverId ?? this.receiverId,
      place: place ?? this.place,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
