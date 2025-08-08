import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import 'database_service.dart';
import 'push_notification_service.dart';
import 'auth_service.dart';

class AppointmentReminderService {
  final DatabaseService _databaseService = DatabaseService();
  final PushNotificationService _notificationService = PushNotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _reminderTimer;
  Set<String> _sentReminders = {};

  // Initialize the reminder service
  void initialize() {
    // Check for appointments every hour
    _reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndSendReminders();
    });
    
    // Also check immediately when initialized
    _checkAndSendReminders();
  }

  // Dispose the service
  void dispose() {
    _reminderTimer?.cancel();
  }

  // Check for today's appointments and send reminders
  Future<void> _checkAndSendReminders() async {
    try {
      print('🔍 [AppointmentReminder] Checking for today\'s appointments...');
      
      // Get current user from AuthService
      final authService = AuthService();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        print('🔍 [AppointmentReminder] No current user found');
        return;
      }

      // Use the existing DatabaseService method that already has proper indexes
      final appointmentsStream = _databaseService.getUserTodayAppointments(currentUser.id);
      final appointments = await appointmentsStream.first;

      print('🔍 [AppointmentReminder] Found ${appointments.length} appointments for today');

      for (final appointment in appointments) {
        await _processAppointmentReminder(appointment);
      }
    } catch (e) {
      print('🔍 [AppointmentReminder] Error checking appointments: $e');
    }
  }

  // Process a single appointment for reminder
  Future<void> _processAppointmentReminder(Appointment appointment) async {
    try {
      final reminderKey = '${appointment.id}_${appointment.appointmentDate.day}';
      
      // Check if we already sent a reminder for this appointment today
      if (_sentReminders.contains(reminderKey)) {
        print('🔍 [AppointmentReminder] Reminder already sent for appointment ${appointment.id}');
        return;
      }

      // Get vet information
      final vetDoc = await _firestore.collection('users').doc(appointment.vetId).get();
      if (!vetDoc.exists) {
        print('🔍 [AppointmentReminder] Vet not found for appointment ${appointment.id}');
        return;
      }

      final vetData = vetDoc.data() as Map<String, dynamic>;
      final vetName = vetData['displayName'] ?? 'Vet';

      // Check if it's time to send reminder (2 hours before appointment)
      final appointmentTime = _parseAppointmentTime(appointment.timeSlot, appointment.appointmentDate);
      final reminderTime = appointmentTime.subtract(const Duration(hours: 2));
      final now = DateTime.now();

      if (now.isAfter(reminderTime) && now.isBefore(appointmentTime)) {
        print('🔍 [AppointmentReminder] Sending reminder for appointment ${appointment.id}');
        
        await _notificationService.sendAppointmentReminder(
          recipientUserId: appointment.userId,
          petName: appointment.petName,
          appointmentType: appointment.typeDisplayName,
          time: appointment.formattedTime,
          vetName: vetName,
          appointmentId: appointment.id,
        );

        // Mark as sent
        _sentReminders.add(reminderKey);
        
        print('🔍 [AppointmentReminder] Reminder sent successfully for ${appointment.petName}');
      }
    } catch (e) {
      print('🔍 [AppointmentReminder] Error processing appointment reminder: $e');
    }
  }

  // Parse appointment time from timeSlot string
  DateTime _parseAppointmentTime(String timeSlot, DateTime appointmentDate) {
    try {
      final timeParts = timeSlot.split('-');
      if (timeParts.isNotEmpty) {
        final timeString = timeParts[0];
        final timeComponents = timeString.split(':');
        
        if (timeComponents.length == 2) {
          final hour = int.parse(timeComponents[0]);
          final minute = int.parse(timeComponents[1]);
          
          return DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
            hour,
            minute,
          );
        }
      }
    } catch (e) {
      print('🔍 [AppointmentReminder] Error parsing appointment time: $e');
    }
    
    // Fallback: return appointment date at 9 AM
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      9,
      0,
    );
  }

  // Send immediate reminder for testing
  Future<void> sendTestReminder(String appointmentId) async {
    try {
      final appointmentDoc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (!appointmentDoc.exists) {
        print('🔍 [AppointmentReminder] Appointment not found: $appointmentId');
        return;
      }

      final appointment = Appointment.fromFirestore(appointmentDoc);
      
      // Get vet information
      final vetDoc = await _firestore.collection('users').doc(appointment.vetId).get();
      if (!vetDoc.exists) {
        print('🔍 [AppointmentReminder] Vet not found for appointment $appointmentId');
        return;
      }

      final vetData = vetDoc.data() as Map<String, dynamic>;
      final vetName = vetData['displayName'] ?? 'Vet';

      await _notificationService.sendAppointmentReminder(
        recipientUserId: appointment.userId,
        petName: appointment.petName,
        appointmentType: appointment.typeDisplayName,
        time: appointment.formattedTime,
        vetName: vetName,
        appointmentId: appointment.id,
      );

      print('🔍 [AppointmentReminder] Test reminder sent successfully');
    } catch (e) {
      print('🔍 [AppointmentReminder] Error sending test reminder: $e');
    }
  }
} 