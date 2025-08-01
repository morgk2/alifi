import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlot {
  final String id;
  final String vetId;
  final DateTime date;
  final String startTime; // e.g., "09:00"
  final String endTime;   // e.g., "09:30"
  final bool isAvailable;
  final String? appointmentId; // If booked, reference to appointment
  final int duration; // Duration in minutes (default 30)

  TimeSlot({
    required this.id,
    required this.vetId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.appointmentId,
    this.duration = 30,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'vetId': vetId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'appointmentId': appointmentId,
      'duration': duration,
    };
  }

  factory TimeSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return TimeSlot(
      id: doc.id,
      vetId: data['vetId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      appointmentId: data['appointmentId'],
      duration: data['duration'] ?? 30,
    );
  }

  TimeSlot copyWith({
    String? id,
    String? vetId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    String? appointmentId,
    int? duration,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      vetId: vetId ?? this.vetId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      appointmentId: appointmentId ?? this.appointmentId,
      duration: duration ?? this.duration,
    );
  }

  String get timeRange => '$startTime-$endTime';

  String get displayTime {
    // Convert 24h format to 12h format
    final hour = int.parse(startTime.split(':')[0]);
    final minute = startTime.split(':')[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  DateTime get dateTime {
    final timeParts = startTime.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  bool get isPast {
    return dateTime.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}

class VetSchedule {
  final String vetId;
  final Map<String, List<String>> weeklySchedule; // Day -> List of time slots
  final List<DateTime> blockedDates;
  final int appointmentDuration; // in minutes
  final DateTime? scheduleStartDate;
  final DateTime? scheduleEndDate;

  VetSchedule({
    required this.vetId,
    required this.weeklySchedule,
    this.blockedDates = const [],
    this.appointmentDuration = 30,
    this.scheduleStartDate,
    this.scheduleEndDate,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'vetId': vetId,
      'weeklySchedule': weeklySchedule,
      'blockedDates': blockedDates.map((date) => Timestamp.fromDate(date)).toList(),
      'appointmentDuration': appointmentDuration,
      'scheduleStartDate': scheduleStartDate != null ? Timestamp.fromDate(scheduleStartDate!) : null,
      'scheduleEndDate': scheduleEndDate != null ? Timestamp.fromDate(scheduleEndDate!) : null,
    };
  }

  factory VetSchedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VetSchedule(
      vetId: data['vetId'] ?? '',
      weeklySchedule: Map<String, List<String>>.from(
        data['weeklySchedule']?.map((key, value) => MapEntry(key, List<String>.from(value))) ?? {}
      ),
      blockedDates: (data['blockedDates'] as List<dynamic>?)
          ?.map((timestamp) => (timestamp as Timestamp).toDate())
          .toList() ?? [],
      appointmentDuration: data['appointmentDuration'] ?? 30,
      scheduleStartDate: data['scheduleStartDate'] != null 
          ? (data['scheduleStartDate'] as Timestamp).toDate() 
          : null,
      scheduleEndDate: data['scheduleEndDate'] != null 
          ? (data['scheduleEndDate'] as Timestamp).toDate() 
          : null,
    );
  }

  // Generate time slots for a specific date
  List<String> getTimeSlotsForDate(DateTime date) {
    final dayName = _getDayName(date.weekday);
    return weeklySchedule[dayName] ?? [];
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Monday';
    }
  }

  bool isDateBlocked(DateTime date) {
    return blockedDates.any((blockedDate) =>
        blockedDate.year == date.year &&
        blockedDate.month == date.month &&
        blockedDate.day == date.day);
  }

  // Generate time slots for a given time range
  static List<String> generateTimeSlots({
    required int startHour,
    required int endHour,
    required int intervalMinutes,
  }) {
    List<String> slots = [];
    DateTime time = DateTime(2024, 1, 1, startHour, 0); // Use any date, we only care about time
    final endTime = DateTime(2024, 1, 1, endHour, 0);

    while (time.isBefore(endTime)) {
      slots.add('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      time = time.add(Duration(minutes: intervalMinutes));
    }

    return slots;
  }

  // Default schedule for new vets
  static VetSchedule createDefault(String vetId) {
    // Generate slots from 8 AM to 9 PM with 30-minute intervals
    final defaultSlots = generateTimeSlots(
      startHour: 8,
      endHour: 21,
      intervalMinutes: 30,
    );

    return VetSchedule(
      vetId: vetId,
      weeklySchedule: {
        'Monday': defaultSlots,
        'Tuesday': defaultSlots,
        'Wednesday': defaultSlots,
        'Thursday': defaultSlots,
        'Friday': defaultSlots,
        'Saturday': defaultSlots.where((slot) {
          final hour = int.parse(slot.split(':')[0]);
          return hour < 17; // Saturday: 8 AM to 5 PM
        }).toList(),
        'Sunday': [], // Closed on Sunday by default
      },
      appointmentDuration: 30,
    );
  }
}