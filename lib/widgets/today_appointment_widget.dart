import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../pages/detailed_vet_dashboard_page.dart';
import '../pages/vet_chat_page.dart';
import '../pages/appointment_details_page.dart';
import '../utils/app_fonts.dart';

class TodayAppointmentWidget extends StatelessWidget {
  final List<Appointment> appointments;
  final bool isCompact;

  const TodayAppointmentWidget({
    Key? key,
    required this.appointments,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort appointments by date and time to get the latest one
    final sortedAppointments = List<Appointment>.from(appointments);
    sortedAppointments.sort((a, b) {
      // First sort by date
      final dateComparison = b.appointmentDate.compareTo(a.appointmentDate);
      if (dateComparison != 0) return dateComparison;
      
      // If same date, sort by time (latest time first)
      final timeA = a.timeSlot.split('-')[0];
      final timeB = b.timeSlot.split('-')[0];
      return timeB.compareTo(timeA);
    });

    // Only show the latest appointment
    final latestAppointment = sortedAppointments.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.todaysVetAppointment,
          style: TextStyle(fontFamily: context.titleFont,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(context, latestAppointment),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    // Get appointment time
    final timeParts = appointment.timeSlot.split('-');
    final startTime = timeParts.isNotEmpty ? timeParts[0] : '00:00';
    
    // Calculate if appointment is soon (within next 2 hours)
    final now = DateTime.now();
    final appointmentTimeParts = startTime.split(':');
    final appointmentHour = int.tryParse(appointmentTimeParts[0]) ?? 0;
    final appointmentMinute = int.tryParse(appointmentTimeParts[1]) ?? 0;
    
    final appointmentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      appointmentHour,
      appointmentMinute,
    );
    
    final difference = appointmentDateTime.difference(now);
    final isSoon = difference.inHours < 2 && difference.inMinutes > 0;
    final isPast = difference.isNegative;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSoon ? Colors.orange.shade300 : Colors.grey.shade200,
          width: isSoon ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            NavigationService.push(
              context,
              const DetailedVetDashboardPage(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with appointment type and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getAppointmentTypeColor(appointment.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getAppointmentTypeIcon(appointment.type),
                        color: _getAppointmentTypeColor(appointment.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.typeDisplayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            startTime,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isSoon ? Colors.orange.shade800 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSoon
                            ? Colors.orange.shade100
                            : isPast
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSoon
                            ? AppLocalizations.of(context)!.soon
                            : isPast
                                ? AppLocalizations.of(context)!.past
                                : AppLocalizations.of(context)!.today,
                        style: TextStyle(
                          color: isSoon
                              ? Colors.orange.shade800
                              : isPast
                                  ? Colors.red.shade800
                                  : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Countdown timer
                if (!isPast) _buildCountdownTimer(context, difference),
                
                const SizedBox(height: 16),
                
                // Pet and Vet information
                Row(
                  children: [
                    // Pet photo and info
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey.shade200,
                            child: const Icon(
                              Icons.pets,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.petName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.pet,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Vet photo and info
                    Expanded(
                      child: FutureBuilder<User?>(
                        future: DatabaseService().getUser(appointment.vetId),
                        builder: (context, snapshot) {
                          final vet = snapshot.data;
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: vet?.photoURL != null && vet!.photoURL!.isNotEmpty
                                    ? NetworkImage(vet.photoURL!)
                                    : null,
                                child: vet?.photoURL == null || vet!.photoURL!.isEmpty
                                    ? const Icon(Icons.person, size: 30)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                       vet?.displayName ?? AppLocalizations.of(context)!.vet,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                     Text(
                                       AppLocalizations.of(context)!.veterinarian,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Appointment notes
                if (appointment.notes != null && appointment.notes!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.notesLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.notes!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                                 // Action buttons
                 Row(
                   children: [
                                           Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Get vet information and navigate to chat
                            final vet = await DatabaseService().getUser(appointment.vetId);
                                                         if (vet != null) {
                               // Navigate to chat page with the vet
                               NavigationService.push(
                                 context,
                                 VetChatPage(
                                   vetUser: vet,
                                 ),
                               );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(''),
                                ),
                              );
                            }
                          },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.blue,
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(20),
                           ),
                           padding: const EdgeInsets.symmetric(vertical: 16),
                         ),
                          child: Text(
                            AppLocalizations.of(context)!.contactVet,
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             fontSize: 16,
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                                             Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              NavigationService.push(
                                context,
                                const AppointmentDetailsPage(),
                              );
                            },
                         style: OutlinedButton.styleFrom(
                           foregroundColor: Colors.blue,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(20),
                           ),
                           padding: const EdgeInsets.symmetric(vertical: 16),
                         ),
                          child: Text(
                            AppLocalizations.of(context)!.viewDetails,
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             fontSize: 16,
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAppointmentTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return Colors.blue;
      case AppointmentType.vaccination:
        return Colors.green;
      case AppointmentType.surgery:
        return Colors.red;
      case AppointmentType.consultation:
        return Colors.purple;
      case AppointmentType.emergency:
        return Colors.orange;
      case AppointmentType.followUp:
        return Colors.teal;
    }
  }

  IconData _getAppointmentTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return Icons.health_and_safety;
      case AppointmentType.vaccination:
        return Icons.vaccines;
      case AppointmentType.surgery:
        return Icons.medical_services;
      case AppointmentType.consultation:
        return Icons.question_answer;
      case AppointmentType.emergency:
        return Icons.emergency;
      case AppointmentType.followUp:
        return Icons.repeat;
    }
  }

  Widget _buildCountdownTimer(BuildContext context, Duration difference) {
    String countdownText;
    Color countdownColor;
    
    if (difference.inHours > 0) {
      countdownText = AppLocalizations.of(context)!.hoursMinutesUntilAppointment(difference.inHours, difference.inMinutes % 60);
      countdownColor = Colors.orange.shade700;
    } else if (difference.inMinutes > 0) {
      countdownText = AppLocalizations.of(context)!.minutesUntilAppointment(difference.inMinutes);
      countdownColor = Colors.red.shade700;
    } else {
      countdownText = AppLocalizations.of(context)!.appointmentStartingNow;
      countdownColor = Colors.red.shade700;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: countdownColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: countdownColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: countdownColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            countdownText,
            style: TextStyle(
              color: countdownColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}