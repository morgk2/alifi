import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../pages/vet_chat_page.dart';
import '../widgets/review_dialog.dart';
import 'package:provider/provider.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({super.key});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    print('🔍 [AppointmentDetailsPage] _loadAppointments called');
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      print('🔍 [AppointmentDetailsPage] Current user: ${user?.id}');
      
      if (user != null) {
        print('🔍 [AppointmentDetailsPage] Calling getUserAppointments for user: ${user.id}');
        final appointments = await _databaseService.getUserAppointments(user.id).first;
        
        print('🔍 [AppointmentDetailsPage] Received ${appointments.length} appointments');
        
        // Debug: Print all appointments with their status
        print('🔍 [AppointmentDetailsPage] Appointments with status:');
        for (int i = 0; i < appointments.length; i++) {
          final apt = appointments[i];
          print('  ${i + 1}. ${apt.petName} - Status: ${apt.status.name} - VetStatus: ${apt.vetStatus?.name} - ID: ${apt.id}');
        }
        
        // Sort appointments by date and time (latest first)
        appointments.sort((a, b) {
          // First sort by date
          final dateComparison = b.appointmentDate.compareTo(a.appointmentDate);
          if (dateComparison != 0) return dateComparison;
          
          // If same date, sort by time (latest time first)
          final timeA = a.timeSlot.split('-')[0];
          final timeB = b.timeSlot.split('-')[0];
          return timeB.compareTo(timeA);
        });
        
        // Filter out test appointments from being considered as "latest"
        final nonTestAppointments = appointments.where((apt) => 
          !(apt.notes?.toLowerCase().contains('test') ?? false) &&
          !apt.petName.toLowerCase().contains('test') &&
          !apt.id.toLowerCase().contains('test')
        ).toList();
        
        // If we have non-test appointments, use the first one as latest
        if (nonTestAppointments.isNotEmpty) {
          // Re-sort the list to put non-test appointments first
          appointments.sort((a, b) {
            final aIsTest = (a.notes?.toLowerCase().contains('test') ?? false) ||
                           a.petName.toLowerCase().contains('test') ||
                           a.id.toLowerCase().contains('test');
            final bIsTest = (b.notes?.toLowerCase().contains('test') ?? false) ||
                           b.petName.toLowerCase().contains('test') ||
                           b.id.toLowerCase().contains('test');
            
            // Put non-test appointments first
            if (aIsTest && !bIsTest) return 1;
            if (!aIsTest && bIsTest) return -1;
            
            // If both are test or both are non-test, sort by date and time
            final dateComparison = b.appointmentDate.compareTo(a.appointmentDate);
            if (dateComparison != 0) return dateComparison;
            
            final timeA = a.timeSlot.split('-')[0];
            final timeB = b.timeSlot.split('-')[0];
            return timeB.compareTo(timeA);
          });
        }
        
        print('🔍 [AppointmentDetailsPage] Sorted appointments, latest: ${appointments.isNotEmpty ? appointments.first.appointmentDate : 'none'}');
        
        setState(() {
          _appointments = appointments;
          _isLoading = false;
        });
      } else {
        print('🔍 [AppointmentDetailsPage] No user found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [AppointmentDetailsPage] Error loading appointments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
             appBar: AppBar(
        title: const Text(
          'Appointment History',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _loadAppointments();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _getAppointmentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _appointments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading appointments',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          final appointments = snapshot.data ?? _appointments;
          
          if (appointments.isEmpty) {
            return _buildEmptyState();
          }
          
          // Sort and filter appointments
          final sortedAppointments = _sortAndFilterAppointments(appointments);
          
          return _buildAppointmentsList(sortedAppointments);
        },
      ),
    );
  }
  
  Stream<List<Appointment>> _getAppointmentsStream() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user == null) {
      return Stream.value([]);
    }
    
    return _databaseService.getUserAppointments(user.id);
  }
  
  List<Appointment> _sortAndFilterAppointments(List<Appointment> appointments) {
    // Sort appointments by date and time (latest first)
    final sorted = List<Appointment>.from(appointments);
    sorted.sort((a, b) {
      // First sort by date
      final dateComparison = b.appointmentDate.compareTo(a.appointmentDate);
      if (dateComparison != 0) return dateComparison;
      
      // If same date, sort by time (latest time first)
      final timeA = a.timeSlot.split('-')[0];
      final timeB = b.timeSlot.split('-')[0];
      return timeB.compareTo(timeA);
    });
    
    // Filter out test appointments from being considered as "latest"
    final nonTestAppointments = sorted.where((apt) => 
      !(apt.notes?.toLowerCase().contains('test') ?? false) &&
      !apt.petName.toLowerCase().contains('test') &&
      !apt.id.toLowerCase().contains('test')
    ).toList();
    
    // If we have non-test appointments, use the first one as latest
    if (nonTestAppointments.isNotEmpty) {
      // Re-sort the list to put non-test appointments first
      sorted.sort((a, b) {
        final aIsTest = (a.notes?.toLowerCase().contains('test') ?? false) ||
                       a.petName.toLowerCase().contains('test') ||
                       a.id.toLowerCase().contains('test');
        final bIsTest = (b.notes?.toLowerCase().contains('test') ?? false) ||
                       b.petName.toLowerCase().contains('test') ||
                       b.id.toLowerCase().contains('test');
        
        // Put non-test appointments first
        if (aIsTest && !bIsTest) return 1;
        if (!aIsTest && bIsTest) return -1;
        
        // If both are test or both are non-test, sort by date and time
        final dateComparison = b.appointmentDate.compareTo(a.appointmentDate);
        if (dateComparison != 0) return dateComparison;
        
        final timeA = a.timeSlot.split('-')[0];
        final timeB = b.timeSlot.split('-')[0];
        return timeB.compareTo(timeA);
      });
    }
    
    return sorted;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No Appointments Yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your appointment history will appear here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest Appointment',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                if (appointments.isNotEmpty)
                  _buildLatestAppointmentCard(appointments.first),
                const SizedBox(height: 32),
                const Text(
                  'All Appointments',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final appointment = appointments[index + 1]; // Skip first (latest)
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildAppointmentCard(appointment, isLatest: false),
              );
            },
            childCount: appointments.length > 1 ? appointments.length - 1 : 0,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildLatestAppointmentCard(Appointment appointment) {
    // Debug: Print appointment status for debugging
    print('🔍 [AppointmentDetailsPage] Latest appointment: ${appointment.petName}');
    print('  - vetStatus: ${appointment.vetStatus}');
    print('  - isInProgress: ${appointment.isInProgress}');
    print('  - isOngoing: ${appointment.isOngoing}');
    print('  - canEnd: ${appointment.canEnd}');
    print('  - startedAt: ${appointment.startedAt}');
    print('  - status: ${appointment.status}');
    print('  - Progress bar should show: ${appointment.isOngoing}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(appointment.status),
                    color: _getStatusColor(appointment.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.typeDisplayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(appointment.appointmentDate),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: _getStatusColor(appointment.status).withOpacity(0.1),
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: Text(
                         appointment.statusDisplayName,
                         style: TextStyle(
                           fontFamily: 'Inter',
                           color: _getStatusColor(appointment.status),
                           fontWeight: FontWeight.w600,
                           fontSize: 12,
                         ),
                       ),
                     ),
                     const SizedBox(width: 8),
                     // Delete button for test appointments in latest card
                     if ((appointment.notes?.toLowerCase().contains('test') ?? false) ||
                         appointment.petName.toLowerCase().contains('test') ||
                         appointment.id.toLowerCase().contains('test'))
                       GestureDetector(
                         onTap: () => _showDeleteDialog(appointment),
                         child: Container(
                           padding: const EdgeInsets.all(4),
                           decoration: BoxDecoration(
                             color: const Color(0xFFEF4444).withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.delete_outline,
                             color: Color(0xFFEF4444),
                             size: 16,
                           ),
                         ),
                       ),
                   ],
                 ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Pet and Vet information
            Row(
              children: [
                // Pet info
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Color(0xFF6B7280),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.petName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const Text(
                              'Pet',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Vet info
                Expanded(
                  child: FutureBuilder<User?>(
                    future: _databaseService.getUser(appointment.vetId),
                    builder: (context, snapshot) {
                      final vet = snapshot.data;
                      return Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF4FF),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: vet?.photoURL != null && vet!.photoURL!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.network(
                                      vet.photoURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Color(0xFF2563EB),
                                    size: 28,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vet?.displayName ?? 'Vet',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const Text(
                                  'Veterinarian',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: Color(0xFF6B7280),
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
            
            const SizedBox(height: 24),
            
            // Time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  appointment.formattedTime,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appointment.notes!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
                         const SizedBox(height: 24),
             
                           // Progress bar for ongoing appointments
              if (appointment.isOngoing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.play_circle,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Appointment in Progress',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<DateTime>(
                        stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                        builder: (context, snapshot) {
                          final progress = _calculateProgress(appointment);
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFFE5E7EB),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(progress * 100).toInt()}% Complete',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
             
                          // Action buttons
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton(
                     onPressed: () async {
                       final vet = await _databaseService.getUser(appointment.vetId);
                       if (vet != null) {
                         NavigationService.push(
                           context,
                           VetChatPage(vetUser: vet),
                         );
                       }
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF2563EB),
                       foregroundColor: Colors.white,
                       elevation: 0,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       padding: const EdgeInsets.symmetric(vertical: 16),
                     ),
                     child: const Text(
                       'Contact Vet',
                       style: TextStyle(
                         fontFamily: 'Inter',
                         fontWeight: FontWeight.w600,
                         fontSize: 16,
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
                 if (appointment.canEnd)
                   Expanded(
                     child: ElevatedButton(
                       onPressed: () => _showEndAppointmentDialog(appointment),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFEF4444),
                         foregroundColor: Colors.white,
                         elevation: 0,
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                         padding: const EdgeInsets.symmetric(vertical: 16),
                       ),
                       child: const Text(
                         'End Appointment',
                         style: TextStyle(
                           fontFamily: 'Inter',
                           fontWeight: FontWeight.w600,
                           fontSize: 16,
                         ),
                       ),
                     ),
                   )
                 else
                   Expanded(
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       decoration: BoxDecoration(
                         color: _getVetStatusColor(appointment.vetStatus).withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(
                           color: _getVetStatusColor(appointment.vetStatus).withOpacity(0.3),
                         ),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(
                             _getVetStatusIcon(appointment.vetStatus),
                             color: _getVetStatusColor(appointment.vetStatus),
                             size: 16,
                           ),
                           const SizedBox(width: 8),
                           Text(
                             _getVetStatusText(appointment.vetStatus),
                             style: TextStyle(
                               fontFamily: 'Inter',
                               fontWeight: FontWeight.w600,
                               fontSize: 14,
                               color: _getVetStatusColor(appointment.vetStatus),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, {required bool isLatest}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A1A).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAppointmentTypeColor(appointment.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getAppointmentTypeIcon(appointment.type),
                    color: _getAppointmentTypeColor(appointment.type),
                    size: 20,
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
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(appointment.appointmentDate),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: _getStatusColor(appointment.status).withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Text(
                         appointment.statusDisplayName,
                         style: TextStyle(
                           fontFamily: 'Inter',
                           color: _getStatusColor(appointment.status),
                           fontWeight: FontWeight.w600,
                           fontSize: 10,
                         ),
                       ),
                     ),
                     const SizedBox(width: 8),
                                           // Delete button for test appointments (temporarily show for all)
                      if (true) // Temporarily show delete for all appointments
                       GestureDetector(
                         onTap: () => _showDeleteDialog(appointment),
                         child: Container(
                           padding: const EdgeInsets.all(4),
                           decoration: BoxDecoration(
                             color: const Color(0xFFEF4444).withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.delete_outline,
                             color: Color(0xFFEF4444),
                             size: 16,
                           ),
                         ),
                       ),
                   ],
                 ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Pet and time info
            Row(
              children: [
                const Icon(
                  Icons.pets,
                  color: Color(0xFF6B7280),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.petName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF2563EB),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.formattedTime,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                appointment.notes!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.confirmed:
        return const Color(0xFF10B981);
      case AppointmentStatus.completed:
        return const Color(0xFF2563EB);
      case AppointmentStatus.cancelled:
        return const Color(0xFFEF4444);
      case AppointmentStatus.noShow:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.error_outline;
    }
  }

  Color _getAppointmentTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return const Color(0xFF2563EB);
      case AppointmentType.vaccination:
        return const Color(0xFF10B981);
      case AppointmentType.surgery:
        return const Color(0xFFEF4444);
      case AppointmentType.consultation:
        return const Color(0xFF8B5CF6);
      case AppointmentType.emergency:
        return const Color(0xFFF59E0B);
      case AppointmentType.followUp:
        return const Color(0xFF14B8A6);
    }
  }

  IconData _getAppointmentTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return Icons.favorite;
      case AppointmentType.vaccination:
        return Icons.add_circle;
      case AppointmentType.surgery:
        return Icons.medical_services;
      case AppointmentType.consultation:
        return Icons.chat_bubble_outline;
      case AppointmentType.emergency:
        return Icons.warning;
      case AppointmentType.followUp:
        return Icons.refresh;
    }
  }

     String _formatDate(DateTime date) {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final yesterday = today.subtract(const Duration(days: 1));
     final appointmentDate = DateTime(date.year, date.month, date.day);

     if (appointmentDate == today) {
       return 'Today';
     } else if (appointmentDate == yesterday) {
       return 'Yesterday';
     } else {
       return '${date.day}/${date.month}/${date.year}';
     }
   }

   Color _getVetStatusColor(VetStatus? status) {
     switch (status ?? VetStatus.waiting) {
       case VetStatus.waiting:
         return const Color(0xFF6B7280);
       case VetStatus.ongoing:
         return const Color(0xFF10B981);
       case VetStatus.delayed:
         return const Color(0xFFF59E0B);
       case VetStatus.cancelled:
         return const Color(0xFFEF4444);
       case VetStatus.soon:
         return const Color(0xFF2563EB);
     }
   }

   IconData _getVetStatusIcon(VetStatus? status) {
     switch (status ?? VetStatus.waiting) {
       case VetStatus.waiting:
         return Icons.schedule;
       case VetStatus.ongoing:
         return Icons.play_circle;
       case VetStatus.delayed:
         return Icons.warning;
       case VetStatus.cancelled:
         return Icons.cancel;
       case VetStatus.soon:
         return Icons.access_time;
     }
   }

       String _getVetStatusText(VetStatus? status) {
      switch (status ?? VetStatus.waiting) {
        case VetStatus.waiting:
          return 'Waiting';
        case VetStatus.ongoing:
          return 'Ongoing';
        case VetStatus.delayed:
          return 'Delayed';
        case VetStatus.cancelled:
          return 'Cancelled';
        case VetStatus.soon:
          return 'Soon';
      }
    }

         void _showEndAppointmentDialog(Appointment appointment) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => Dialog(
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(20),
           ),
           elevation: 0,
           backgroundColor: Colors.transparent,
           child: Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(20),
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.1),
                   blurRadius: 20,
                   offset: const Offset(0, 10),
                 ),
               ],
             ),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                 // Header with icon
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: const Color(0xFFFEF2F2),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Row(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: const Color(0xFFEF4444),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: const Icon(
                           Icons.stop_circle,
                           color: Colors.white,
                           size: 20,
                         ),
                       ),
                       const SizedBox(width: 12),
                       const Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               'End Appointment',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 18,
                                 fontWeight: FontWeight.w700,
                                 color: Color(0xFF1A1A1A),
                               ),
                             ),
                             SizedBox(height: 2),
                             Text(
                               'This action cannot be undone',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Color(0xFF6B7280),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 24),
                 
                 // Content
                 Text(
                   'Are you sure you want to end this appointment?\n\n${appointment.typeDisplayName} - ${appointment.petName}',
                   style: const TextStyle(
                     fontFamily: 'Inter',
                     fontSize: 16,
                     color: Color(0xFF6B7280),
                     height: 1.5,
                   ),
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 32),
                 
                 // Buttons
                 Row(
                   children: [
                     Expanded(
                       child: OutlinedButton(
                         onPressed: () => Navigator.of(context).pop(),
                         style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                           side: const BorderSide(color: Color(0xFFE5E7EB)),
                         ),
                         child: const Text(
                           'Cancel',
                           style: TextStyle(
                             fontFamily: 'Inter',
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
                             color: Color(0xFF6B7280),
                           ),
                         ),
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: ElevatedButton(
                         onPressed: () async {
                           Navigator.of(context).pop();
                           await _endAppointment(appointment);
                         },
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFFEF4444),
                           foregroundColor: Colors.white,
                           elevation: 0,
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                         ),
                         child: const Text(
                           'End Appointment',
                           style: TextStyle(
                             fontFamily: 'Inter',
                             fontSize: 16,
                             fontWeight: FontWeight.w600,
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
       );
     }

    Future<void> _endAppointment(Appointment appointment) async {
      try {
        // Update appointment status to completed
        final updatedAppointment = appointment.copyWith(
          status: AppointmentStatus.completed,
          vetStatus: VetStatus.waiting,
          isInProgress: false,
          endedAt: DateTime.now(),
        );

        // Update in database
        await _databaseService.updateAppointment(updatedAppointment);

        // Show review dialog
        await _showReviewDialog(appointment);

        // Reload appointments
        await _loadAppointments();
      } catch (e) {
        print('Error ending appointment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error ending appointment. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }

    Future<void> _showReviewDialog(Appointment appointment) async {
      final vet = await _databaseService.getUser(appointment.vetId);
      final vetName = vet?.displayName ?? 'Vet';

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ReviewDialog(
          vetName: vetName,
          appointmentType: appointment.typeDisplayName,
          appointmentPrice: appointment.price,
        ),
      );

      print('🔍 [AppointmentDetailsPage] Dialog result: $result');
      if (result != null) {
        print('🔍 [AppointmentDetailsPage] Processing review submission...');
        await _submitReview(appointment, result['rating'], result['comment']);
      } else {
        print('🔍 [AppointmentDetailsPage] Dialog was cancelled or returned null');
      }
    }

    Future<void> _submitReview(Appointment appointment, int rating, String comment) async {
      try {
        print('🔍 [AppointmentDetailsPage] Submitting review for appointment: ${appointment.id}');
        print('🔍 [AppointmentDetailsPage] Rating: $rating, Comment: $comment');
        print('🔍 [AppointmentDetailsPage] Vet ID: ${appointment.vetId}');
        
        // Use the simplified review submission
        await DatabaseService().addSimpleReview(
          vetId: appointment.vetId,
          rating: rating,
          comment: comment,
        );
        
        print('✅ [AppointmentDetailsPage] Review submitted successfully');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } catch (e) {
        print('❌ [AppointmentDetailsPage] Error submitting review: $e');
        print('❌ [AppointmentDetailsPage] Error details: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }

                   double _calculateProgress(Appointment appointment) {
        if (!appointment.isOngoing || appointment.startedAt == null) {
          print('🔍 [Progress] Not showing progress - isOngoing: ${appointment.isOngoing}, startedAt: ${appointment.startedAt}');
          return 0.0;
        }
      
        final now = DateTime.now();
        final startTime = appointment.startedAt!;
        
        // Calculate expected duration (30 minutes default)
        final expectedDuration = const Duration(minutes: 30);
        final expectedEndTime = startTime.add(expectedDuration);
        
        // Calculate progress
        final totalDuration = expectedEndTime.difference(startTime).inMilliseconds;
        final elapsedDuration = now.difference(startTime).inMilliseconds;
        
        if (elapsedDuration <= 0) {
          return 0.0;
        }
        
        if (elapsedDuration >= totalDuration) {
          return 1.0;
        }
        
        final progress = elapsedDuration / totalDuration;
        print('🔍 [Progress] Progress: ${(progress * 100).toInt()}% - elapsed: ${elapsedDuration ~/ 1000}s, total: ${totalDuration ~/ 1000}s');
        
        return progress;
      }

     void _showDeleteDialog(Appointment appointment) {
       showDialog(
         context: context,
         builder: (context) => AlertDialog(
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(16),
           ),
           title: const Text(
             'Delete Appointment',
             style: TextStyle(
               fontFamily: 'Inter',
               fontSize: 20,
               fontWeight: FontWeight.w700,
               color: Color(0xFF1A1A1A),
             ),
           ),
           content: Text(
             'Are you sure you want to delete this appointment?\n\n${appointment.typeDisplayName} - ${appointment.petName}',
             style: const TextStyle(
               fontFamily: 'Inter',
               fontSize: 16,
               color: Color(0xFF6B7280),
             ),
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(context).pop(),
               child: const Text(
                 'Cancel',
                 style: TextStyle(
                   fontFamily: 'Inter',
                   color: Color(0xFF6B7280),
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
             ElevatedButton(
               onPressed: () async {
                 Navigator.of(context).pop();
                 await _deleteAppointment(appointment);
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: const Color(0xFFEF4444),
                 foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
               ),
               child: const Text(
                 'Delete',
                 style: TextStyle(
                   fontFamily: 'Inter',
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
           ],
         ),
       );
     }

     Future<void> _deleteAppointment(Appointment appointment) async {
       try {
         // Delete from database
         await _databaseService.deleteAppointment(appointment.id);
         
         // Reload appointments
         await _loadAppointments();
         
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Appointment deleted successfully'),
             backgroundColor: Color(0xFF10B981),
           ),
         );
       } catch (e) {
         print('Error deleting appointment: $e');
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Error deleting appointment. Please try again.'),
             backgroundColor: Color(0xFFEF4444),
           ),
         );
       }
     }
} 