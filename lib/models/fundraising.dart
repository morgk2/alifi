import 'package:cloud_firestore/cloud_firestore.dart';

class Fundraising {
  final String id;
  final String title;
  final String description;
  final double currentAmount;
  final double goalAmount;
  final String creatorId;
  final DateTime createdAt;
  final DateTime endDate;
  final String status; // 'active', 'completed', 'cancelled'
  final List<String> supporterIds;

  Fundraising({
    required this.id,
    required this.title,
    required this.description,
    required this.currentAmount,
    required this.goalAmount,
    required this.creatorId,
    required this.createdAt,
    required this.endDate,
    required this.status,
    required this.supporterIds,
  });

  factory Fundraising.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Fundraising(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      goalAmount: (data['goalAmount'] ?? 0.0).toDouble(),
      creatorId: data['creatorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      supporterIds: List<String>.from(data['supporterIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'currentAmount': currentAmount,
      'goalAmount': goalAmount,
      'creatorId': creatorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'supporterIds': supporterIds,
    };
  }
}
