import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class DetailedVetDashboardPage extends StatefulWidget {
  const DetailedVetDashboardPage({super.key});

  @override
  State<DetailedVetDashboardPage> createState() => _DetailedVetDashboardPageState();
}

class _DetailedVetDashboardPageState extends State<DetailedVetDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

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

              final stats = snapshot.data?.first ?? {
                'nextAppointment': 'No upcoming',
                'patientsCount': 0,
                'appointmentsToday': 0,
                'revenueToday': 0.0,
              };

              return Column(
                children: [
                  Row(
                    children: [
                                             Expanded(
                         child: _buildOverviewCard(
                           'Today\'s Appoint.',
                           stats['appointmentsToday'].toString(),
                           Icons.medical_services,
                           Colors.blue,
                         ),
                       ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOverviewCard(
                          'Total Patients',
                          stats['patientsCount'].toString(),
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
                          '\$${(stats['revenueToday'] as num).toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                                             Expanded(
                         child: _buildOverviewCard(
                           'Next Appoint.',
                           stats['nextAppointment'] ?? 'No upcoming',
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
            children: [
              Expanded(
                child: _buildFilterChip('Today', true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('Tomorrow', false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('This Week', false),
              ),
            ],
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
                  '45',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPatientCategoryCard(
                  'New This Month',
                  '12',
                  Icons.person_add,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Patients List
          const Text(
            'Recent Patients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 16),
          _buildPatientsList(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Chart
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
                  'Revenue This Week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildRevenueChart(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Performance Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Avg. Appointment Duration',
                  '45 min',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Patient Satisfaction',
                  '4.8/5',
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
                _buildMonthlyStats(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // Handle filter selection
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
    );
  }

  Widget _buildAppointmentsList() {
    // Mock appointments data
    final appointments = [
      {'time': '9:00 AM', 'patient': 'Max (Golden Retriever)', 'type': 'Check-up'},
      {'time': '10:30 AM', 'patient': 'Luna (Cat)', 'type': 'Vaccination'},
      {'time': '2:00 PM', 'patient': 'Buddy (Labrador)', 'type': 'Surgery'},
      {'time': '4:30 PM', 'patient': 'Bella (Poodle)', 'type': 'Follow-up'},
    ];

    return Column(
      children: appointments.map((appointment) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['time']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      appointment['patient']!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appointment['type']!,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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

  Widget _buildPatientsList() {
    // Mock patients data
    final patients = [
      {'name': 'Max', 'species': 'Golden Retriever', 'owner': 'John Smith', 'lastVisit': '2 days ago'},
      {'name': 'Luna', 'species': 'Cat', 'owner': 'Sarah Johnson', 'lastVisit': '1 week ago'},
      {'name': 'Buddy', 'species': 'Labrador', 'owner': 'Mike Wilson', 'lastVisit': '3 days ago'},
      {'name': 'Bella', 'species': 'Poodle', 'owner': 'Emily Davis', 'lastVisit': '5 days ago'},
    ];

    return Column(
      children: patients.map((patient) {
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
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  patient['name']![0],
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${patient['species']!} • ${patient['owner']!}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                patient['lastVisit']!,
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

  Widget _buildRevenueChart() {
    // Mock chart data
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Revenue Chart\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
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

  Widget _buildMonthlyStats() {
    return Column(
      children: [
        _buildStatRow('Total Appointments', '156'),
        _buildStatRow('New Patients', '23'),
        _buildStatRow('Revenue', '\$12,450'),
        _buildStatRow('Emergency Cases', '8'),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 