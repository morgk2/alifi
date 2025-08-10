import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import '../models/time_slot.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import '../widgets/custom_snackbar.dart';

class AppointmentBookingDialog extends StatefulWidget {
  final User vetUser;

  const AppointmentBookingDialog({
    super.key,
    required this.vetUser,
  });

  @override
  State<AppointmentBookingDialog> createState() => _AppointmentBookingDialogState();
}

class _AppointmentBookingDialogState extends State<AppointmentBookingDialog> {
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  Pet? _selectedPet;
  AppointmentType _selectedType = AppointmentType.checkup;
  String _reason = '';
  
  List<Pet> _userPets = [];
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;
  bool _isBooking = false;

  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final pets = await DatabaseService().getUserPets(currentUser.id).first;
        setState(() {
          _userPets = pets;
          if (pets.isNotEmpty) {
            _selectedPet = pets.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          'Error loading pets: $e',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    setState(() {
      _isLoading = true;
      _selectedTimeSlot = null;
    });

    try {
      final slots = await DatabaseService().getAvailableTimeSlots(widget.vetUser.id, date);
      setState(() {
        _availableSlots = slots.where((slot) => slot.isAvailable).toList();
      });
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          'Error loading time slots: $e',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null || _selectedPet == null) {
      CustomSnackBarHelper.showInfo(
        context,
        'Please fill in all required fields',
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final appointment = Appointment(
          id: '',
          vetId: widget.vetUser.id,
          userId: currentUser.id,
          petId: _selectedPet!.id,
          petName: _selectedPet!.name,
          appointmentDate: _selectedDate!,
          timeSlot: _selectedTimeSlot!.timeRange,
          type: _selectedType,
          status: AppointmentStatus.pending,
          reason: _reason.trim().isNotEmpty ? _reason.trim() : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await DatabaseService().createAppointment(appointment);

        if (mounted) {
          Navigator.of(context).pop();
          CustomSnackBarHelper.showSuccess(
            context,
            'Appointment request sent successfully!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBarHelper.showError(
          context,
          'Error booking appointment: $e',
        );
      }
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF4092FF),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
              await _loadAvailableSlots(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF4092FF)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select a date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotSelector() {
    if (_selectedDate == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: SpinningLoader())
        else if (_availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No available time slots for this date',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSlots.map((slot) {
              final isSelected = _selectedTimeSlot?.id == slot.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF4092FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4092FF) : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    slot.displayTime,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildPetSelector() {
    if (_userPets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Pet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No pets found. Please add a pet first.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Pet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Pet>(
          value: _selectedPet,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _userPets.map((pet) {
            return DropdownMenuItem<Pet>(
              value: pet,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: pet.photoURL != null ? NetworkImage(pet.photoURL!) : null,
                    child: pet.photoURL == null 
                        ? Icon(Icons.pets, size: 16, color: Colors.grey[600])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${pet.species} • ${pet.breed}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (pet) {
            setState(() {
              _selectedPet = pet;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AppointmentType>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: AppointmentType.values.map((type) {
            return DropdownMenuItem<AppointmentType>(
              value: type,
              child: Text(type.typeDisplayName),
            );
          }).toList(),
          onChanged: (type) {
            setState(() {
              _selectedType = type!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            hintText: 'Describe the reason for the appointment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          onChanged: (value) {
            _reason = value;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
          color: Colors.black,
        ),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading && _userPets.isEmpty
          ? const Center(child: SpinningLoader())
          : _userPets.isEmpty && !_isLoading
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildVetHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildPetSelector(),
                            const SizedBox(height: 24),
                            _buildAppointmentTypeSelector(),
                            const SizedBox(height: 24),
                            _buildDateSelector(),
                            const SizedBox(height: 24),
                            _buildTimeSlotSelector(),
                            const SizedBox(height: 24),
                            _buildReasonField(),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomActions(),
                  ],
                ),
    );
  }

  Widget _buildVetHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.vetUser.photoURL != null
                ? NetworkImage(widget.vetUser.photoURL!)
                : null,
            child: widget.vetUser.photoURL == null
                ? Text(
                    (widget.vetUser.displayName ?? 'V')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.vetUser.displayName ?? 'Veterinarian'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Veterinarian',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Pets Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need to add a pet before booking an appointment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to add pet page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4092FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Add Pet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isBooking ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isBooking || _selectedDate == null || _selectedTimeSlot == null || _selectedPet == null
                    ? null
                    : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4092FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add typeDisplayName to AppointmentType
extension AppointmentTypeExtension on AppointmentType {
  String get typeDisplayName {
    switch (this) {
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.surgery:
        return 'Surgery';
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.followUp:
        return 'Follow-up';
    }
  }
}