import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import '../models/pet.dart';

class DetailedSchedulePage extends StatefulWidget {
  const DetailedSchedulePage({super.key});

  @override
  State<DetailedSchedulePage> createState() => _DetailedSchedulePageState();
}

class _DetailedSchedulePageState extends State<DetailedSchedulePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  List<Appointment> _appointments = [];
  Appointment? _draggedAppointment;
  bool _isDragging = false;
  StreamSubscription<List<Appointment>>? _appointmentsSubscription;
  
     // Timeline variables
   final List<String> _timeSlots = [
     '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
     '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
     '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
     '18:00', '18:30', '19:00', '19:30', '20:00', '20:30',
     '21:00', '21:30', '22:00', '22:30', '23:00', '23:30'
   ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    print('🔍 [DetailedSchedule] _loadAppointments called');
    print('🔍 [DetailedSchedule] Current user: ${user?.id}');
    print('🔍 [DetailedSchedule] User account type: ${user?.accountType}');
    
    if (user != null) {
      // Cancel previous subscription if exists
      await _appointmentsSubscription?.cancel();
      
      // Check if user is a vet, if not, try to get user appointments instead
      Stream<List<Appointment>> appointmentsStream;
      if (user.accountType == 'vet') {
        print('🔍 [DetailedSchedule] Loading vet appointments');
        appointmentsStream = DatabaseService().getVetAppointments(user.id);
      } else {
        print('🔍 [DetailedSchedule] Loading user appointments');
        appointmentsStream = DatabaseService().getUserAppointments(user.id);
      }
      
      _appointmentsSubscription = appointmentsStream.listen((appointments) {
        print('🔍 [DetailedSchedule] Received ${appointments.length} appointments');
        for (final appointment in appointments) {
          print('🔍 [DetailedSchedule] Appointment: ${appointment.petName} - ${appointment.appointmentDate} - ${appointment.status}');
        }
        
        if (mounted) {
          setState(() {
            _appointments = appointments;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detailed Schedule',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
                 bottom: PreferredSize(
           preferredSize: const Size.fromHeight(60),
           child: Container(
             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.grey[100],
               borderRadius: BorderRadius.circular(30),
             ),
             child: TabBar(
               controller: _tabController,
               indicator: BoxDecoration(
                 color: Colors.orange,
                 borderRadius: BorderRadius.circular(30),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.orange.withOpacity(0.3),
                     blurRadius: 8,
                     offset: const Offset(0, 2),
                   ),
                 ],
               ),
               indicatorSize: TabBarIndicatorSize.tab,
               labelColor: Colors.white,
               unselectedLabelColor: Colors.grey[600],
               labelStyle: const TextStyle(
                 fontWeight: FontWeight.w600,
                 fontSize: 14,
                 fontFamily: 'Montserrat',
               ),
               unselectedLabelStyle: const TextStyle(
                 fontWeight: FontWeight.w500,
                 fontSize: 14,
                 fontFamily: 'Montserrat',
               ),
               dividerColor: Colors.transparent,
               tabs: const [
                 Tab(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.calendar_month, size: 18),
                       SizedBox(width: 8),
                       Text('Calendar'),
                     ],
                   ),
                 ),
                 Tab(
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.timeline, size: 18),
                       SizedBox(width: 8),
                       Text('Timeline'),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildTimelineView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarView() {
    final selectedDateAppointments = _getAppointmentsForDate(_selectedDate);
    
    return Column(
      children: [
        // Calendar Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Calendar Grid
        Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: _buildCalendarGrid(),
        ),
        
                 // Selected Date Appointments
         if (selectedDateAppointments.isNotEmpty)
           Container(
             height: 250, // Increased height to accommodate taller appointment cards
             padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointments for ${DateFormat('EEEE, MMMM d').format(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedDateAppointments.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        child: _buildAppointmentCard(selectedDateAppointments[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    final List<Widget> calendarDays = [];
    
    // Add day headers
    const List<String> dayHeaders = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (String day in dayHeaders) {
      calendarDays.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    
    // Add empty cells for days before the first day of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      calendarDays.add(
        Container(
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
          ),
        ),
      );
    }
    
         // Add days of the month
     for (int day = 1; day <= daysInMonth; day++) {
       final date = DateTime(_focusedDate.year, _focusedDate.month, day);
       final dayAppointments = _getAppointmentsForDate(date);
       final isSelected = _isSameDay(date, _selectedDate);
       final isToday = _isSameDay(date, DateTime.now());
       
       if (dayAppointments.isNotEmpty) {
         print('🔍 [DetailedSchedule] Calendar - Day $day has ${dayAppointments.length} appointments');
       }
      
             Color backgroundColor = Colors.white;
       Color textColor = Colors.black;
       
       if (isSelected) {
         backgroundColor = Colors.blue;
         textColor = Colors.white;
       } else if (isToday) {
         backgroundColor = Colors.orange;
         textColor = Colors.white;
       } else if (dayAppointments.isNotEmpty) {
         backgroundColor = Colors.teal;
         textColor = Colors.white;
       }
      
      calendarDays.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                if (dayAppointments.isNotEmpty)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: calendarDays.length,
      itemBuilder: (context, index) => calendarDays[index],
    );
  }

  Widget _buildTimelineView() {
    final selectedDateAppointments = _getAppointmentsForDate(_selectedDate);
    print('🔍 [DetailedSchedule] _buildTimelineView - Selected date: $_selectedDate');
    print('🔍 [DetailedSchedule] _buildTimelineView - Found ${selectedDateAppointments.length} appointments for selected date');
    
    return Column(
      children: [
        // Date selector
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Timeline
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildTimeline(selectedDateAppointments),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(List<Appointment> appointments) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          height: _timeSlots.length * 80.0, // 80px per time slot
          child: Row(
            children: [
              // Time labels
              Container(
                width: 80,
                child: Column(
                  children: _timeSlots.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    return Container(
                      height: 80,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Timeline line
              Container(
                width: 2,
                color: Colors.grey[300],
              ),
              
              const SizedBox(width: 16),
              
              // Appointment bars
              Expanded(
                child: Stack(
                  children: [
                    // Time grid lines
                    ...List.generate(_timeSlots.length, (index) {
                      return Positioned(
                        top: index * 80.0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: Colors.grey[200],
                        ),
                      );
                    }),
                    
                                         // Appointment bars
                                           ...appointments.map((appointment) {
                        final startTimeString = appointment.timeSlot.split('-')[0]; // Get start time from timeSlot
                        print('🔍 [DetailedSchedule] Timeline - Processing appointment: ${appointment.petName} at $startTimeString');
                        
                        // Calculate position based on time
                        final startIndex = _timeSlots.indexWhere((slot) {
                          final matches = slot == startTimeString;
                          print('🔍 [DetailedSchedule] Timeline - Checking slot $slot vs appointment $startTimeString - matches: $matches');
                          return matches;
                        });
                        
                        print('🔍 [DetailedSchedule] Timeline - Found startIndex: $startIndex for ${appointment.petName}');
                        if (startIndex == -1) {
                          print('🔍 [DetailedSchedule] Timeline - No matching time slot found for ${appointment.petName} at $startTimeString');
                          return const SizedBox.shrink();
                        }
                      
                      final startPosition = startIndex * 80.0;
                      
                      Color barColor = Colors.blue;
                      if (appointment.status == AppointmentStatus.confirmed) {
                        barColor = Colors.green;
                      } else if (appointment.status == AppointmentStatus.completed) {
                        barColor = Colors.purple;
                      } else if (appointment.status == AppointmentStatus.cancelled) {
                        barColor = Colors.red;
                      }
                      
                      return Positioned(
                        top: startPosition + 10, // Add some padding from the grid line
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60, // Thicker appointment bars
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        appointment.petName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        appointment.typeDisplayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                                                 Text(
                                   appointment.timeSlot.split('-')[0], // Get the start time from timeSlot
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 14,
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                                if (appointment.reason != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.reason!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    // Current time indicator
                    Positioned(
                      top: _getCurrentTimePosition() * 80.0 - 1,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.orange,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getCurrentTimePosition() {
    final now = DateTime.now();
    
    // Find the closest time slot
    double closestIndex = 0.0;
    double minDifference = double.infinity;
    
    for (int i = 0; i < _timeSlots.length; i++) {
      final slotTime = DateFormat('HH:mm').parse(_timeSlots[i]);
      final difference = (now.hour * 60 + now.minute) - (slotTime.hour * 60 + slotTime.minute);
      if (difference.abs() < minDifference.abs()) {
        minDifference = difference.toDouble();
        closestIndex = i.toDouble();
      }
    }
    
    return closestIndex;
  }

  Widget _buildAppointmentCards(List<Appointment> appointments) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 8),
          child: _buildAppointmentCard(appointment),
        );
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final now = DateTime.now();
    final isCurrentAppointment = _isSameDay(appointment.appointmentDate, now) &&
        appointment.appointmentDate.hour == now.hour &&
        appointment.appointmentDate.minute >= now.minute - 30 &&
        appointment.appointmentDate.minute <= now.minute + 30;
    
    final isPastAppointment = appointment.appointmentDate.isBefore(now);
    final isFutureAppointment = appointment.appointmentDate.isAfter(now);
    
    Color statusColor = Colors.blue;
    if (appointment.status == AppointmentStatus.confirmed) {
      statusColor = Colors.green;
    } else if (appointment.status == AppointmentStatus.completed) {
      statusColor = Colors.purple;
    } else if (appointment.status == AppointmentStatus.cancelled) {
      statusColor = Colors.red;
    }
    
         return Container(
       width: 280,
       height: 240, // Significantly increased height to properly contain all content including notes
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildAppointmentContent(appointment, statusColor),
          if (isCurrentAppointment)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentContent(Appointment appointment, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status indicator and actions
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  appointment.petName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
                             PopupMenuButton<String>(
                 onSelected: (value) => _handleAppointmentAction(value, appointment),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
                 elevation: 8,
                 color: Colors.white,
                 itemBuilder: (context) => [
                   PopupMenuItem(
                     value: 'confirm',
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.green.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.check_circle_outline,
                             color: Colors.green,
                             size: 20,
                           ),
                         ),
                         const SizedBox(width: 12),
                         const Text(
                           'Confirm',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                   PopupMenuItem(
                     value: 'complete',
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.purple.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.task_alt,
                             color: Colors.purple,
                             size: 20,
                           ),
                         ),
                         const SizedBox(width: 12),
                         const Text(
                           'Mark Complete',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                   PopupMenuItem(
                     value: 'cancel',
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: Colors.red.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.cancel_outlined,
                             color: Colors.red,
                             size: 20,
                           ),
                         ),
                         const SizedBox(width: 12),
                         const Text(
                           'Cancel',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.grey[100],
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: const Icon(
                     Icons.more_vert,
                     size: 20,
                     color: Colors.grey,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Appointment type and time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.typeDisplayName,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.timeSlot.split('-')[0], // Get the start time from timeSlot
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          // Status badge
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment.status.name.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(appointment.status),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
                     // Reason if available
           if (appointment.reason != null) ...[
             const SizedBox(height: 8),
             Text(
               appointment.reason!,
               style: TextStyle(
                 color: Colors.grey[600],
                 fontSize: 12,
               ),
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
           ],
           
           // Notes if available
           if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
             const SizedBox(height: 8),
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: Colors.grey[50],
                 borderRadius: BorderRadius.circular(6),
                 border: Border.all(color: Colors.grey[200]!),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.note,
                         size: 14,
                         color: Colors.grey[600],
                       ),
                       const SizedBox(width: 4),
                       Text(
                         'Notes',
                         style: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 10,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(
                     appointment.notes!,
                     style: TextStyle(
                       color: Colors.grey[700],
                       fontSize: 11,
                     ),
                     maxLines: 3,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ],
               ),
             ),
           ],
        ],
      ),
    );
  }

  void _handleAppointmentAction(String action, Appointment appointment) async {
    switch (action) {
      case 'confirm':
        await DatabaseService().updateAppointmentStatus(
          appointment.id,
          AppointmentStatus.confirmed,
        );
        break;
      case 'complete':
        await DatabaseService().updateAppointmentStatus(
          appointment.id,
          AppointmentStatus.completed,
        );
        // Show revenue dialog for completed appointment
        _showRevenueDialog(appointment);
        break;
      case 'cancel':
        await DatabaseService().updateAppointmentStatus(
          appointment.id,
          AppointmentStatus.cancelled,
        );
        break;
    }
    // No need to call _loadAppointments() as the stream will automatically update
  }

  void _showRevenueDialog(Appointment appointment) {
    final TextEditingController revenueController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Appointment Revenue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How much did you earn from ${appointment.petName}\'s appointment?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: revenueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Revenue Amount',
                  hintText: 'Enter amount (e.g., 150)',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final revenue = double.tryParse(revenueController.text);
                if (revenue != null && revenue > 0) {
                  // Update the appointment with the revenue amount
                  await DatabaseService().updateAppointmentPrice(appointment.id, revenue);
                  // Add revenue to the day's total
                  await _addRevenueToDay(appointment.appointmentDate, revenue);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Revenue of \$${revenue.toStringAsFixed(2)} added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRevenueToDay(DateTime appointmentDate, double revenue) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      
      if (user != null) {
        await DatabaseService().addRevenueToDay(
          userId: user.id,
          date: appointmentDate,
          revenue: revenue,
        );
      }
    } catch (e) {
      print('Error adding revenue: $e');
    }
  }

  void _showAddAppointmentDialog() {
    // TODO: Implement add appointment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add appointment feature coming soon!')),
    );
  }

  List<Appointment> _getAppointmentsForDate(DateTime date) {
    print('🔍 [DetailedSchedule] _getAppointmentsForDate called for date: $date');
    print('🔍 [DetailedSchedule] _getAppointmentsForDate - Total appointments: ${_appointments.length}');
    
    // Debug: Print all appointment dates
    for (final apt in _appointments) {
      print('🔍 [DetailedSchedule] _getAppointmentsForDate - All appointment: ${apt.petName} at ${apt.appointmentDate} (${apt.appointmentDate.year}-${apt.appointmentDate.month}-${apt.appointmentDate.day})');
    }
    
    final filteredAppointments = _appointments.where((apt) => _isSameDay(apt.appointmentDate, date)).toList();
    print('🔍 [DetailedSchedule] _getAppointmentsForDate - Filtered appointments: ${filteredAppointments.length}');
    for (final apt in filteredAppointments) {
      print('🔍 [DetailedSchedule] _getAppointmentsForDate - Filtered appointment: ${apt.petName} at ${apt.appointmentDate}');
    }
    return filteredAppointments;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.purple;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.orange;
    }
  }
} 