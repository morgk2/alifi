import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/time_slot.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class VetSchedulePage extends StatefulWidget {
  const VetSchedulePage({super.key});

  @override
  State<VetSchedulePage> createState() => _VetSchedulePageState();
}

class _VetSchedulePageState extends State<VetSchedulePage> {
  bool _isLoading = true;
  VetSchedule? _schedule;
  final Map<String, bool> _expandedDays = {};
  final Map<String, RangeValues> _workingHours = {};
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        final schedule = await DatabaseService().getVetSchedule(currentUser.id);
        if (mounted) {
          setState(() {
            _schedule = schedule;
            // Initialize working hours from schedule
            for (final day in _weekDays) {
              final slots = schedule.weeklySchedule[day] ?? [];
              if (slots.isNotEmpty) {
                final firstSlot = slots.first;
                final lastSlot = slots.last;
                final startHour = int.parse(firstSlot.split(':')[0]);
                final endHour = int.parse(lastSlot.split(':')[0]);
                _workingHours[day] = RangeValues(startHour.toDouble(), endHour.toDouble());
              } else {
                _workingHours[day] = const RangeValues(8, 21); // Default 8 AM to 9 PM
              }
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSchedule(String day) async {
    if (_schedule == null) return;

    try {
      final hours = _workingHours[day]!;
      final slots = VetSchedule.generateTimeSlots(
        startHour: hours.start.toInt(),
        endHour: hours.end.toInt(),
        intervalMinutes: _schedule!.appointmentDuration,
      );

      final updatedSchedule = VetSchedule(
        vetId: _schedule!.vetId,
        weeklySchedule: {
          ..._schedule!.weeklySchedule,
          day: slots,
        },
        blockedDates: _schedule!.blockedDates,
        appointmentDuration: _schedule!.appointmentDuration,
        scheduleStartDate: _schedule!.scheduleStartDate,
        scheduleEndDate: _schedule!.scheduleEndDate,
      );

      await DatabaseService().updateVetSchedule(updatedSchedule);

      if (mounted) {
        setState(() => _schedule = updatedSchedule);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$day schedule updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDaySchedule(String day) {
    final isExpanded = _expandedDays[day] ?? false;
    final hours = _workingHours[day]!;
    final slots = _schedule?.weeklySchedule[day] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              slots.isEmpty
                  ? 'Closed'
                  : '${hours.start.toInt()}:00 - ${hours.end.toInt()}:00',
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() => _expandedDays[day] = !isExpanded);
              },
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Working Hours',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _updateSchedule(day),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: hours,
                    min: 0,
                    max: 24,
                    divisions: 24,
                    labels: RangeLabels(
                      '${hours.start.toInt()}:00',
                      '${hours.end.toInt()}:00',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() => _workingHours[day] = values);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available Time Slots',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (slots.isEmpty)
                    Text(
                      'No time slots available',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slots.map((slot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Working Hours',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedule == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No schedule found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _loadSchedule,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: _weekDays.map((day) => _buildDaySchedule(day)).toList(),
                ),
    );
  }
}