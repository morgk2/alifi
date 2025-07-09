class Fundraising {
  final String id;
  final double currentAmount;
  final double goalAmount;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> donorIds;
  final String status; // 'active', 'completed', 'cancelled'

  const Fundraising({
    required this.id,
    required this.currentAmount,
    required this.goalAmount,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.donorIds,
    required this.status,
  });

  // Mock data for development
  static Fundraising get mockData => Fundraising(
        id: 'fund_001',
        currentAmount: 324223.21,
        goalAmount: 635000.00,
        title: 'Animal Shelter Expansion',
        description:
            'Help us expand our shelter to accommodate more animals in need.',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        donorIds: ['user_001', 'user_002', 'user_003'],
        status: 'active',
      );

  double get progressPercentage =>
      (currentAmount / goalAmount * 100).clamp(0, 100);

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentAmount': currentAmount,
        'goalAmount': goalAmount,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'donorIds': donorIds,
        'status': status,
      };

  factory Fundraising.fromJson(Map<String, dynamic> json) => Fundraising(
        id: json['id'] as String,
        currentAmount: (json['currentAmount'] as num).toDouble(),
        goalAmount: (json['goalAmount'] as num).toDouble(),
        title: json['title'] as String,
        description: json['description'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        donorIds: (json['donorIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        status: json['status'] as String,
      );
}
