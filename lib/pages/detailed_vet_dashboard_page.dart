import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/revenue_chart_widget.dart';
import '../models/user.dart';
import '../models/appointment.dart';
import '../models/pet.dart'; // Added import for Pet model

import 'vet_schedule_page.dart';
import 'detailed_schedule_page.dart';

class DetailedVetDashboardPage extends StatefulWidget {
  const DetailedVetDashboardPage({super.key});

  @override
  State<DetailedVetDashboardPage> createState() => _DetailedVetDashboardPageState();
}

class _DetailedVetDashboardPageState extends State<DetailedVetDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  final List<String> _filters = ['All', 'Today', 'Tomorrow', 'This Week'];
  int _selectedFilterIndex = 0; // Start with 'All' to show all appointments

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addPatientToVet(String vetId, String petId) async {
    final vet = await DatabaseService().getUser(vetId);
    if (vet != null) {
      final List<String> patients = List<String>.from(vet.patients ?? []);
      if (!patients.contains(petId)) {
        patients.add(petId);
        await DatabaseService().updateUserPatients(vetId, patients);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user?.accountType != 'vet') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text('This page is only available for veterinary accounts.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with safe space
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Vet Dashboard',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.schedule, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const VetSchedulePage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DetailedSchedulePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
                         // Pill-shaped tab bar with extra spacing
             Container(
               margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
               decoration: BoxDecoration(
                 color: Colors.grey[200],
                 borderRadius: BorderRadius.circular(25),
               ),
                               child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.orange.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.dashboard),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: Icon(Icons.calendar_today),
                    text: 'Appointments',
                  ),
                  Tab(
                    icon: Icon(Icons.people),
                    text: 'Patients',
                  ),
                  Tab(
                    icon: Icon(Icons.analytics),
                    text: 'Analytics',
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(user!),
                  _buildAppointmentsTab(user),
                  _buildPatientsTab(user),
                  _buildAnalyticsTab(user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Cards
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _databaseService.getVetDashboardStats(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: SpinningLoader());
              }

              if (snapshot.hasError) {
                print('🔍 [DetailedVetDashboard] Error: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading dashboard',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print('🔍 [DetailedVetDashboard] No data available');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No dashboard data available',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              final stats = snapshot.data!.first;
              
              // Safely extract values with proper type conversion
              final nextAppointment = stats['nextAppointment']?.toString() ?? 'No upcoming';
              final patientsCount = (stats['patientsCount'] ?? 0).toString();
              final appointmentsToday = (stats['appointmentsToday'] ?? 0).toString();
              final revenueToday = (stats['revenueToday'] ?? 0.0) as double;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          'Today\'s Appoint.',
                          appointmentsToday,
                          Icons.medical_services,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Patients',
                          patientsCount,
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewCard(
                          'Revenue Today',
                          '\$${revenueToday.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Next Appoint.',
                          nextAppointment,
                          Icons.calendar_today,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                'Schedule Appointment',
                Icons.add_circle_outline,
                Colors.blue,
                () => _showSnackBar('Schedule appointment feature coming soon!'),
              ),
              _buildQuickActionCard(
                'Add Patient',
                Icons.person_add,
                Colors.green,
                () => _showSnackBar('Add patient feature coming soon!'),
              ),
              _buildQuickActionCard(
                'View Records',
                Icons.folder_open,
                Colors.orange,
                () => _showSnackBar('Patient records feature coming soon!'),
              ),
              _buildQuickActionCard(
                'Emergency Contact',
                Icons.emergency,
                Colors.red,
                () => _showSnackBar('Emergency contact feature coming soon!'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment Filters
          Row(
            children: List.generate(_filters.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
                  child: _buildFilterChip(_filters[index], _selectedFilterIndex == index, index),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Appointments List
          const Text(
            'Upcoming Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          _buildAppointmentsList(),
        ],
      ),
    );
  }

  Widget _buildPatientsTab(User user) {
    return StreamBuilder<List<Appointment>>(
      stream: DatabaseService().getVetAppointments(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SpinningLoader());
        }
        final appointments = snapshot.data ?? [];
        // Only consider confirmed or completed appointments
        final filtered = appointments.where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.completed).toList();
        // Map petId to all their appointments
        final Map<String, List<Appointment>> petAppointments = {};
        for (final apt in filtered) {
          petAppointments.putIfAbsent(apt.petId, () => []).add(apt);
        }
        // Active patients: unique petIds
        final int activePatients = petAppointments.length;
        // New this month: unique petIds whose first confirmed appointment is in this month
        final now = DateTime.now();
        final int newThisMonth = petAppointments.values.where((apts) {
          final first = apts.map((a) => a.createdAt).reduce((a, b) => a.isBefore(b) ? a : b);
          return first.year == now.year && first.month == now.month;
        }).length;
        // Recent patients: unique pets, ordered by most recent appointment
        final List<MapEntry<String, List<Appointment>>> recentPetEntries = petAppointments.entries.toList()
          ..sort((a, b) => b.value.map((a) => a.createdAt).reduce((a1, a2) => a1.isAfter(a2) ? a1 : a2)
            .compareTo(a.value.map((a) => a.createdAt).reduce((a1, a2) => a1.isAfter(a2) ? a1 : a2)));
        final List<String> orderedPetIds = recentPetEntries.map((e) => e.key).toList();
        
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Patient Categories
          Row(
            children: [
              Expanded(
                child: _buildPatientCategoryCard(
                  'Active Patients',
                      activePatients.toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatientCategoryCard(
                  'New This Month',
                      newThisMonth.toString(),
                  Icons.person_add,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
                'My Patients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
              // Show real recent patients ordered by most recent
              if (orderedPetIds.isEmpty)
                const Center(child: Text('No patients found'))
              else
                FutureBuilder<List<Pet>>(
                  future: DatabaseService().getPets(orderedPetIds),
                  builder: (context, petSnap) {
                    if (petSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: SpinningLoader());
                    }
                    if (!petSnap.hasData || petSnap.data!.isEmpty) {
                      return const Center(child: Text('No patients found'));
                    }
                    final pets = petSnap.data!;
                    // Order pets by orderedPetIds
                    final petMap = {for (var pet in pets) pet.id: pet};
                    return Column(
                      children: orderedPetIds.map((petId) {
                        final pet = petMap[petId];
                        if (pet == null) return const SizedBox.shrink();
                        return ListTile(
                          leading: CircleAvatar(child: Text(pet.name.isNotEmpty ? pet.name[0] : '?')),
                          title: Text(pet.name),
                          subtitle: Text(pet.species),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(User user) {
    print('🔍 [AnalyticsTab] Building analytics tab for user: ${user.id}');
    print('🔍 [AnalyticsTab] User account type: ${user.accountType}');
    
    return StreamBuilder<Map<String, dynamic>>(
      stream: DatabaseService().getVetAnalytics(user.id),
      builder: (context, snapshot) {
        print('🔍 [AnalyticsTab] StreamBuilder state: ${snapshot.connectionState}');
        print('🔍 [AnalyticsTab] Has data: ${snapshot.hasData}');
        print('🔍 [AnalyticsTab] Has error: ${snapshot.hasError}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('🔍 [AnalyticsTab] Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('🔍 [AnalyticsTab] Error occurred: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final analytics = snapshot.data ?? {};
        
        print('🔍 [AnalyticsTab] Received analytics data: $analytics');
        print('🔍 [AnalyticsTab] Analytics data type: ${analytics.runtimeType}');
        print('🔍 [AnalyticsTab] Analytics keys: ${analytics.keys.toList()}');
        print('🔍 [AnalyticsTab] Total appointments: ${analytics['thisMonthAppointments']}');
        print('🔍 [AnalyticsTab] New patients: ${analytics['newPatientsThisMonth']}');
        print('🔍 [AnalyticsTab] Revenue: ${analytics['thisMonthRevenue']}');
        print('🔍 [AnalyticsTab] Emergency cases: ${analytics['emergencyCases']}');
        print('🔍 [AnalyticsTab] Average duration: ${analytics['averageDuration']}');
        print('🔍 [AnalyticsTab] Patient satisfaction: ${analytics['patientSatisfaction']}');
        print('🔍 [AnalyticsTab] This week revenue: ${analytics['thisWeekRevenue']}');
        print('🔍 [AnalyticsTab] Last week revenue: ${analytics['lastWeekRevenue']}');
        print('🔍 [AnalyticsTab] Completed appointments: ${analytics['completedAppointments']}');
        print('🔍 [AnalyticsTab] Pending appointments: ${analytics['pendingAppointments']}');
        print('🔍 [AnalyticsTab] Confirmed appointments: ${analytics['confirmedAppointments']}');
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue Chart
              StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                stream: DatabaseService().getVetRevenueChartData(user.id),
                builder: (context, chartSnapshot) {
                  if (chartSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 500,
                decoration: BoxDecoration(
                  color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final chartData = chartSnapshot.data ?? {
                    'daily': <Map<String, dynamic>>[],
                    'weekly': <Map<String, dynamic>>[],
                    'monthly': <Map<String, dynamic>>[],
                  };
                  
                  return RevenueChartWidget(
                    chartData: chartData,
                    title: 'Revenue Analytics',
                  );
                },
              ),
              const SizedBox(height: 24),

              // Performance Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Avg. Appointment Duration',
                      '${analytics['averageDuration'] ?? 45} min',
                      Icons.timer,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Patient Satisfaction',
                      '${analytics['patientSatisfaction'] ?? 4.8}/5',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Monthly Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMonthlyStats(analytics),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appointment Status Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusBreakdown(analytics),
              ],
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildAppointmentsList() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return const Center(child: Text('No user logged in'));
    }

    return StreamBuilder<List<Appointment>>(
      stream: DatabaseService().getVetAppointmentsForDashboard(currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final appointments = snapshot.data ?? [];
        print('🔍 [VetDashboard] Received ${appointments.length} appointments from database');
        for (final apt in appointments) {
          print('🔍 [VetDashboard] Appointment: ${apt.petName} on ${apt.appointmentDate} - Status: ${apt.status}');
        }
        
        List<Appointment> filteredAppointments = appointments;
        final now = DateTime.now();
        print('🔍 [VetDashboard] Current filter: ${_filters[_selectedFilterIndex]}');
        print('🔍 [VetDashboard] Current date: $now');
        
        if (_filters[_selectedFilterIndex] == 'Today') {
          filteredAppointments = appointments.where((apt) =>
            apt.appointmentDate.year == now.year &&
            apt.appointmentDate.month == now.month &&
            apt.appointmentDate.day == now.day
          ).toList();
          print('🔍 [VetDashboard] Filtered to today: ${filteredAppointments.length} appointments');
        } else if (_filters[_selectedFilterIndex] == 'Tomorrow') {
          final tomorrow = now.add(Duration(days: 1));
          filteredAppointments = appointments.where((apt) =>
            apt.appointmentDate.year == tomorrow.year &&
            apt.appointmentDate.month == tomorrow.month &&
            apt.appointmentDate.day == tomorrow.day
          ).toList();
          print('🔍 [VetDashboard] Filtered to tomorrow: ${filteredAppointments.length} appointments');
        } else if (_filters[_selectedFilterIndex] == 'This Week') {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          filteredAppointments = appointments.where((apt) {
            final date = apt.appointmentDate;
            return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   date.isBefore(endOfWeek.add(const Duration(days: 1)));
          }).toList();
          print('🔍 [VetDashboard] Filtered to this week: ${filteredAppointments.length} appointments');
        } else {
          print('🔍 [VetDashboard] No date filtering applied: ${filteredAppointments.length} appointments');
        }

        if (filteredAppointments.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your schedule is clear for today',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: filteredAppointments.map((appointment) {
            Color statusColor = Colors.blue;
            switch (appointment.status) {
              case AppointmentStatus.confirmed:
                statusColor = Colors.green;
                break;
              case AppointmentStatus.pending:
                statusColor = Colors.orange;
                break;
              case AppointmentStatus.completed:
                statusColor = Colors.purple;
                break;
              case AppointmentStatus.cancelled:
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.blue;
            }

            final now = DateTime.now();
            final isCurrentAppointment = _isSameDay(appointment.appointmentDate, now) &&
                appointment.appointmentDate.hour == now.hour &&
                appointment.appointmentDate.minute >= now.minute - 30 &&
                appointment.appointmentDate.minute <= now.minute + 30;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.schedule, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _filters[_selectedFilterIndex] == 'Today'
                            ? appointment.formattedTime
                            : '${_formatDate(appointment.appointmentDate)} ${appointment.formattedTime}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${appointment.petName} • ${appointment.typeDisplayName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        if (appointment.reason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            appointment.reason!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                    ],
                  ),
                  // Progress tracking for current appointments
                  if (isCurrentAppointment) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                  Container(
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
                              const SizedBox(width: 8),
                              const Text(
                                'Appointment in Progress',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildProgressBar(appointment),
                        ],
                      ),
                    ),
                  ],
                  // Status and actions
                  const SizedBox(height: 12),
                  Row(
                      children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          appointment.statusDisplayName,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                        if (appointment.status == AppointmentStatus.pending)
                        ElevatedButton(
                              onPressed: () async {
                                await DatabaseService().updateAppointmentStatus(appointment.id, AppointmentStatus.confirmed);
                                await _addPatientToVet(appointment.vetId, appointment.petId);
                                setState(() {}); // Refresh UI
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Confirm'),
                        ),
                      const SizedBox(width: 8),
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
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProgressBar(Appointment appointment) {
    final now = DateTime.now();
    final appointmentStart = appointment.appointmentDate;
    final appointmentEnd = appointmentStart.add(const Duration(hours: 1));
    
    if (now.isBefore(appointmentStart) || now.isAfter(appointmentEnd)) {
      return const SizedBox.shrink();
    }
    
    final totalDuration = appointmentEnd.difference(appointmentStart).inMinutes;
    final elapsedDuration = now.difference(appointmentStart).inMinutes;
    final progress = elapsedDuration / totalDuration;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${elapsedDuration}min / ${totalDuration}min',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }

  void _handleAppointmentAction(String action, Appointment appointment) async {
    switch (action) {
      case 'confirm':
        await DatabaseService().updateAppointmentStatus(
          appointment.id,
          AppointmentStatus.confirmed,
        );
        await _addPatientToVet(appointment.vetId, appointment.petId);
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
    setState(() {}); // Refresh UI
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

  Widget _buildFilterChip(String label, bool isSelected, int index) {
    return FilterChip(
      avatar: label == 'All' ? Icon(Icons.list, color: isSelected ? Colors.blue : Colors.grey) : null,
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      elevation: isSelected ? 4 : 0,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey[300]!),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCategoryCard(String title, String count, IconData icon, Color color) {
          return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(Map<String, dynamic> analytics) {
    print('🔍 [RevenueChart] Building revenue chart with analytics: $analytics');
    final thisWeekRevenue = analytics['thisWeekRevenue'] ?? 0.0;
    final lastWeekRevenue = analytics['lastWeekRevenue'] ?? 0.0;
    print('🔍 [RevenueChart] This week revenue: $thisWeekRevenue');
    print('🔍 [RevenueChart] Last week revenue: $lastWeekRevenue');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week: \$${thisWeekRevenue.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Week: \$${lastWeekRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Revenue Chart\n(Coming Soon)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(Map<String, dynamic> analytics) {
    print('🔍 [MonthlyStats] Building monthly stats with analytics: $analytics');
    final totalAppointments = analytics['thisMonthAppointments'] ?? 0;
    final newPatients = analytics['newPatientsThisMonth'] ?? 0;
    final revenue = analytics['thisMonthRevenue'] ?? 0.0;
    final emergencyCases = analytics['emergencyCases'] ?? 0;
    
    print('🔍 [MonthlyStats] Total appointments: $totalAppointments');
    print('🔍 [MonthlyStats] New patients: $newPatients');
    print('🔍 [MonthlyStats] Revenue: $revenue');
    print('🔍 [MonthlyStats] Emergency cases: $emergencyCases');
    
    return Column(
    children: [
        _buildStatRow('Total Appointments', totalAppointments.toString()),
        _buildStatRow('New Patients', newPatients.toString()),
        _buildStatRow('Revenue', '\$${revenue.toStringAsFixed(2)}'),
        _buildStatRow('Emergency Cases', emergencyCases.toString()),
    ],
  );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(Map<String, dynamic> analytics) {
    print('🔍 [StatusBreakdown] Building status breakdown with analytics: $analytics');
    final completed = analytics['completedAppointments'] ?? 0;
    final pending = analytics['pendingAppointments'] ?? 0;
    final confirmed = analytics['confirmedAppointments'] ?? 0;
    final total = completed + pending + confirmed;
    
    print('🔍 [StatusBreakdown] Completed: $completed');
    print('🔍 [StatusBreakdown] Pending: $pending');
    print('🔍 [StatusBreakdown] Confirmed: $confirmed');
    print('🔍 [StatusBreakdown] Total: $total');
    
    if (total == 0) {
      print('🔍 [StatusBreakdown] No appointments found, showing empty state');
      return const Text(
        'No appointments yet',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      );
    }

    return Column(
      children: [
        _buildStatusRow('Completed', completed, total, Colors.green),
        _buildStatusRow('Confirmed', confirmed, total, Colors.blue),
        _buildStatusRow('Pending', pending, total, Colors.orange),
      ],
    );
  }

  Widget _buildStatusRow(String status, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // Mock activity data
    final activities = [
      {'action': 'Appointment completed', 'details': 'Max - Check-up', 'time': '2 hours ago'},
      {'action': 'New patient registered', 'details': 'Bella - Poodle', 'time': '1 day ago'},
      {'action': 'Vaccination given', 'details': 'Luna - Cat', 'time': '2 days ago'},
      {'action': 'Surgery scheduled', 'details': 'Buddy - Labrador', 'time': '3 days ago'},
    ];

    return Column(
      children: activities.map((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['action']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      activity['details']!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                activity['time']!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 