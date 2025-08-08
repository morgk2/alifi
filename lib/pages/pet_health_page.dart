import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'package:flutter/cupertino.dart';

class PetHealthPage extends StatefulWidget {
  final Pet pet;
  const PetHealthPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetHealthPage> createState() => _PetHealthPageState();
}

class _PetHealthPageState extends State<PetHealthPage> {
  late Pet _pet;
  Map<String, dynamic>? _lastDeletedEntry;
  int? _lastDeletedIndex;
  String? _lastDeletedType; // 'vaccine' or 'illness'

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  Future<void> _addVaccine(Map<String, dynamic> entry) async {
    final newVaccines = List<Map<String, dynamic>>.from(_pet.vaccines ?? [])..add(entry);
    final updatedPet = _pet.copyWith(vaccines: newVaccines);
    try {
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vaccine added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vaccine: $e')),
      );
    }
  }

  Future<void> _editVaccine(int index, Map<String, dynamic> oldEntry) async {
    final result = await showAddVaccineOrIllnessDialog(
      context: context,
      entryType: 'vaccine',
      type: oldEntry['type'] ?? 'core',
      initialName: oldEntry['name'],
    );
    if (result != null) {
      final newVaccines = List<Map<String, dynamic>>.from(_pet.vaccines ?? []);
      newVaccines[index] = result;
      final updatedPet = _pet.copyWith(vaccines: newVaccines);
      try {
        await DatabaseService().updatePet(updatedPet);
        setState(() => _pet = updatedPet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vaccine updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vaccine: $e')),
        );
      }
    }
  }

  Future<void> _deleteVaccine(int index, Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccine'),
        content: const Text('Are you sure you want to delete this vaccine?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final newVaccines = List<Map<String, dynamic>>.from(_pet.vaccines ?? []);
    _lastDeletedEntry = newVaccines.removeAt(index);
    _lastDeletedIndex = index;
    _lastDeletedType = 'vaccine';
    final updatedPet = _pet.copyWith(vaccines: newVaccines);
    try {
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vaccine deleted!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: _undoDelete,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vaccine: $e')),
      );
    }
  }

  Future<void> _addIllness(Map<String, dynamic> entry) async {
    final newIllnesses = List<Map<String, dynamic>>.from(_pet.illnesses ?? [])..add(entry);
    final updatedPet = _pet.copyWith(illnesses: newIllnesses);
    try {
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Illness added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add illness: $e')),
      );
    }
  }

  Future<void> _editIllness(int index, Map<String, dynamic> oldEntry) async {
    final result = await showAddVaccineOrIllnessDialog(
      context: context,
      entryType: 'illness',
      type: oldEntry['type'] ?? 'common',
      initialName: oldEntry['name'],
    );
    if (result != null) {
      final newIllnesses = List<Map<String, dynamic>>.from(_pet.illnesses ?? []);
      newIllnesses[index] = result;
      final updatedPet = _pet.copyWith(illnesses: newIllnesses);
      try {
        await DatabaseService().updatePet(updatedPet);
        setState(() => _pet = updatedPet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Illness updated!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update illness: $e')),
        );
      }
    }
  }

  Future<void> _deleteIllness(int index, Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Illness'),
        content: const Text('Are you sure you want to delete this illness?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final newIllnesses = List<Map<String, dynamic>>.from(_pet.illnesses ?? []);
    _lastDeletedEntry = newIllnesses.removeAt(index);
    _lastDeletedIndex = index;
    _lastDeletedType = 'illness';
    final updatedPet = _pet.copyWith(illnesses: newIllnesses);
    try {
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Illness deleted!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: _undoDelete,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete illness: $e')),
      );
    }
  }

  void _undoDelete() async {
    if (_lastDeletedEntry == null || _lastDeletedIndex == null || _lastDeletedType == null) return;
    if (_lastDeletedType == 'vaccine') {
      final newVaccines = List<Map<String, dynamic>>.from(_pet.vaccines ?? []);
      newVaccines.insert(_lastDeletedIndex!, _lastDeletedEntry!);
      final updatedPet = _pet.copyWith(vaccines: newVaccines);
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
    } else if (_lastDeletedType == 'illness') {
      final newIllnesses = List<Map<String, dynamic>>.from(_pet.illnesses ?? []);
      newIllnesses.insert(_lastDeletedIndex!, _lastDeletedEntry!);
      final updatedPet = _pet.copyWith(illnesses: newIllnesses);
      await DatabaseService().updatePet(updatedPet);
      setState(() => _pet = updatedPet);
    }
    _lastDeletedEntry = null;
    _lastDeletedIndex = null;
    _lastDeletedType = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar row
              Row(
                children: [
                  IconButton(
                    icon: Image.asset(
          'assets/images/back_icon.png',
          width: 28,
          height: 28,
        ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.favorite, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Health Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Pet info card
              _PetInfoCard(pet: _pet),
              const SizedBox(height: 24),
              // Vaccines section
              Row(
                children: [
                  const Text('Vaccines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _VaccineSection(
                vaccines: _pet.vaccines,
                onAdd: _addVaccine,
                onEdit: _editVaccine,
                onDelete: _deleteVaccine,
                species: _pet.species,
              ),
              const SizedBox(height: 32),
              // Illness section
              const Text('Illness', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 12),
              _IllnessSection(
                illnesses: _pet.illnesses,
                onAdd: _addIllness,
                onEdit: _editIllness,
                onDelete: _deleteIllness,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetInfoCard extends StatelessWidget {
  final Pet pet;
  const _PetInfoCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              pet.photoURL ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: Colors.grey[200],
                child: const Icon(Icons.pets, size: 36, color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('${pet.species}\n${pet.age} years old\n${pet.weight?.toStringAsFixed(1) ?? '-'} kg'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pet.gender, style: const TextStyle(fontSize: 14)),
              Text(pet.breed, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VaccineSection extends StatelessWidget {
  final List<Map<String, dynamic>>? vaccines;
  final ValueChanged<Map<String, dynamic>>? onAdd;
  final void Function(int, Map<String, dynamic>)? onEdit;
  final void Function(int, Map<String, dynamic>)? onDelete;
  final String species;
  const _VaccineSection({this.vaccines, this.onAdd, this.onEdit, this.onDelete, required this.species});

  @override
  Widget build(BuildContext context) {
    final core = (vaccines ?? []).where((v) => v['type'] == 'core').toList();
    final noncore = (vaccines ?? []).where((v) => v['type'] == 'noncore').toList();
    final coreIndexes = (vaccines ?? []).asMap().entries.where((e) => e.value['type'] == 'core').map((e) => e.key).toList();
    final noncoreIndexes = (vaccines ?? []).asMap().entries.where((e) => e.value['type'] == 'noncore').map((e) => e.key).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VaccineCard(
          title: 'Core Vaccines:',
          entries: core,
          emptyText: 'No logged vaccines to this pet',
          buttonText: 'Log a vaccine',
          onAdd: onAdd,
          onEdit: onEdit == null ? null : (i, v) => onEdit!(coreIndexes[i], v),
          onDelete: onDelete == null ? null : (i, v) => onDelete!(coreIndexes[i], v),
          species: species,
        ),
        const SizedBox(height: 16),
        _VaccineCard(
          title: 'Non-core Vaccines:',
          entries: noncore,
          emptyText: 'No logged non-core vaccines to this pet',
          buttonText: 'Log a vaccine',
          onAdd: onAdd,
          onEdit: onEdit == null ? null : (i, v) => onEdit!(noncoreIndexes[i], v),
          onDelete: onDelete == null ? null : (i, v) => onDelete!(noncoreIndexes[i], v),
          species: species,
        ),
      ],
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final String buttonText;
  final List<Map<String, dynamic>>? entries;
  final ValueChanged<Map<String, dynamic>>? onAdd;
  final void Function(int, Map<String, dynamic>)? onEdit;
  final void Function(int, Map<String, dynamic>)? onDelete;
  final String species; // 'Cat' or 'Dog'
  const _VaccineCard({required this.title, required this.emptyText, required this.buttonText, this.entries, this.onAdd, this.onEdit, this.onDelete, required this.species});

  static const List<String> catCore = [
    'Rabies',
    'FVRCP Combo Vaccine',
    'Feline Panleukopenia (FPV)',
    'Feline Herpesvirus-1 (FHV-1)',
    'Feline Calicivirus (FCV)',
  ];
  static const List<String> catNonCore = [
    'Feline Leukemia Virus (FeLV)',
    'Bordetella bronchiseptica',
    'Chlamydia felis',
    'FIV (Feline Immunodeficiency Virus)',
    'Feline Infectious Peritonitis (FIP)',
    'Feline Giardia',
    'Feline Microsporum canis (Ringworm)',
  ];
  static const List<String> dogCore = [
    'Rabies',
    'DA2PP / DHPP (Distemper, Adenovirus type 2, Parvovirus, Parainfluenza)',
    'Distemper',
    'Adenovirus type 2 (Hepatitis)',
    'Parvovirus',
    'Parainfluenza',
  ];
  static const List<String> dogNonCore = [
    'Bordetella bronchiseptica',
    'Leptospirosis',
    'Lyme disease',
    'Canine Influenza (CIV)',
    'Crotalus Atrox Toxoid (Rattlesnake vaccine)',
    'Coronavirus',
    'Giardia',
    'Canine Herpesvirus',
  ];

  List<String> getVaccineOptions() {
    final lowerTitle = title.toLowerCase();
    final isCore = lowerTitle.startsWith('core');
    final isNonCore = lowerTitle.startsWith('non-core');
    final isCat = species.toLowerCase().contains('cat');
    if (isCat && isCore) return [...catCore, 'Custom...'];
    if (isCat && isNonCore) return [...catNonCore, 'Custom...'];
    if (!isCat && isCore) return [...dogCore, 'Custom...'];
    if (!isCat && isNonCore) return [...dogNonCore, 'Custom...'];
    return ['Custom...'];
  }

  @override
  Widget build(BuildContext context) {
    final type = title.contains('Core') ? 'core' : 'noncore';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (entries == null || entries!.isEmpty)
            Text(emptyText, style: const TextStyle(color: Colors.grey)),
          if (entries != null && entries!.isNotEmpty)
            ...entries!.asMap().entries.map((entry) {
              final i = entry.key;
              final v = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (v['date'] != null)
                            Text(_formatDate(v['date']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (v['notes'] != null && (v['notes'] as String).isNotEmpty)
                            Text(v['notes'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                    _CustomPopupMenu(
                      onEdit: onEdit == null ? null : () => onEdit!(i, v),
                      onDelete: onDelete == null ? null : () => onDelete!(i, v),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _CupertinoPickerButton(
              label: buttonText,
              options: getVaccineOptions(),
              onSelected: (value) async {
                String name = value == 'Custom...' ? '' : value;
                final result = await showAddVaccineOrIllnessDialog(
                  context: context,
                  entryType: 'vaccine',
                  type: type,
                  initialName: name,
                );
                if (result != null && onAdd != null) {
                  onAdd!(result);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(dynamic date) {
  if (date == null) return '';
  if (date is DateTime) return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  if (date is Timestamp) {
    final d = date.toDate();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
  return date.toString();
}

Future<Map<String, dynamic>?> showAddVaccineOrIllnessDialog({
  required BuildContext context,
  required String entryType, // 'vaccine' or 'illness'
  required String type, // 'core'/'noncore' or 'chronic'/'common'
  String? initialName,
}) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController(text: initialName ?? '');
  final TextEditingController notesController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _pickDateCupertino() async {
    DateTime tempDate = selectedDate ?? DateTime.now();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  maximumDate: DateTime.now(),
                  minimumYear: 1990,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (d) => tempDate = d,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(12),
                child: const Text('Select', style: TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.w600)),
                onPressed: () {
                  selectedDate = tempDate;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  return await showCupertinoDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          'Log a ${entryType == 'vaccine' ? 'Vaccine' : 'Illness'}',
          style: const TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Material(
          color: Colors.transparent,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Name',
                  style: const TextStyle(fontFamily: 'InterDisplay', fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDateCupertino,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate == null ? 'Pick Date' : _formatDate(selectedDate),
                          style: const TextStyle(fontFamily: 'InterDisplay', fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: notesController,
                  placeholder: 'Notes',
                  style: const TextStyle(fontFamily: 'InterDisplay', fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  maxLines: 4,
                  minLines: 1,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.w500)),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                // Show error (simple way)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a name')));
                return;
              }
              Navigator.pop(context, {
                'type': type,
                'name': nameController.text.trim(),
                'date': selectedDate ?? DateTime.now(),
                'notes': notesController.text.trim(),
              });
            },
            child: const Text('Save', style: TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}

class _IllnessSection extends StatelessWidget {
  final List<Map<String, dynamic>>? illnesses;
  final ValueChanged<Map<String, dynamic>>? onAdd;
  final void Function(int, Map<String, dynamic>)? onEdit;
  final void Function(int, Map<String, dynamic>)? onDelete;
  const _IllnessSection({this.illnesses, this.onAdd, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final chronic = (illnesses ?? []).where((i) => i['type'] == 'chronic').toList();
    final common = (illnesses ?? []).where((i) => i['type'] == 'common').toList();
    final chronicIndexes = (illnesses ?? []).asMap().entries.where((e) => e.value['type'] == 'chronic').map((e) => e.key).toList();
    final commonIndexes = (illnesses ?? []).asMap().entries.where((e) => e.value['type'] == 'common').map((e) => e.key).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IllnessCard(
          title: 'Illnesses',
          entries: common,
          emptyText: 'No logged Illnesses to this pet',
          buttonText: 'Log an Illness',
          onAdd: onAdd,
          onEdit: onEdit == null ? null : (i, v) => onEdit!(commonIndexes[i], v),
          onDelete: onDelete == null ? null : (i, v) => onDelete!(commonIndexes[i], v),
        ),
        const SizedBox(height: 16),
        _IllnessCard(
          title: 'Chronic Illnesses',
          entries: chronic,
          emptyText: 'No logged Chronic Illnesses to this pet',
          buttonText: 'Log an Illness',
          onAdd: onAdd,
          onEdit: onEdit == null ? null : (i, v) => onEdit!(chronicIndexes[i], v),
          onDelete: onDelete == null ? null : (i, v) => onDelete!(chronicIndexes[i], v),
        ),
      ],
    );
  }
}

class _IllnessCard extends StatelessWidget {
  final String title;
  final String emptyText;
  final String buttonText;
  final List<Map<String, dynamic>>? entries;
  final ValueChanged<Map<String, dynamic>>? onAdd;
  final void Function(int, Map<String, dynamic>)? onEdit;
  final void Function(int, Map<String, dynamic>)? onDelete;
  const _IllnessCard({required this.title, required this.emptyText, required this.buttonText, this.entries, this.onAdd, this.onEdit, this.onDelete});

  static const List<String> commonIllnesses = [
    'Kidney disease',
    'Diabetes',
    'Asthma',
    'Arthritis',
  ];
  static const List<String> chronicIllnesses = [
    'Chronic kidney disease',
    'Chronic respiratory disease',
    'Chronic heart disease',
    'Chronic arthritis',
  ];

  List<String> getIllnessOptions() {
    final lowerTitle = title.toLowerCase();
    final isChronic = lowerTitle.startsWith('chronic');
    if (isChronic) return [...chronicIllnesses, 'Custom...'];
    return [...commonIllnesses, 'Custom...'];
  }

  @override
  Widget build(BuildContext context) {
    final type = title.contains('Chronic') ? 'chronic' : 'common';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (entries == null || entries!.isEmpty)
            Text(emptyText, style: const TextStyle(color: Colors.grey)),
          if (entries != null && entries!.isNotEmpty)
            ...entries!.asMap().entries.map((entry) {
              final i = entry.key;
              final ill = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sick, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ill['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (ill['date'] != null)
                            Text(_formatDate(ill['date']), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (ill['notes'] != null && (ill['notes'] as String).isNotEmpty)
                            Text(ill['notes'], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                    _CustomPopupMenu(
                      onEdit: onEdit == null ? null : () => onEdit!(i, ill),
                      onDelete: onDelete == null ? null : () => onDelete!(i, ill),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _CupertinoPickerButton(
              label: buttonText,
              options: getIllnessOptions(),
              onSelected: (value) async {
                String name = value == 'Custom...' ? '' : value;
                final result = await showAddVaccineOrIllnessDialog(
                  context: context,
                  entryType: 'illness',
                  type: type,
                  initialName: name,
                );
                if (result != null && onAdd != null) {
                  onAdd!(result);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoPickerButton extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  const _CupertinoPickerButton({required this.label, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            int selectedIndex = 0;
            final result = await showModalBottomSheet<String>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) {
                return _AnimatedPickerSheet(
                  options: options,
                  onSelected: onSelected,
                );
              },
            );
            if (result != null) {
              onSelected(result);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontFamily: 'InterDisplay',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedPickerSheet extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;
  const _AnimatedPickerSheet({required this.options, required this.onSelected});

  @override
  State<_AnimatedPickerSheet> createState() => _AnimatedPickerSheetState();
}

class _AnimatedPickerSheetState extends State<_AnimatedPickerSheet> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: SlideTransition(
            position: _slide,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(initialItem: 0),
                      onSelectedItemChanged: (i) => selectedIndex = i,
                      children: widget.options.map((o) => Center(
                        child: Text(
                          o,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'InterDisplay',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    child: const Text('Select', style: TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.pop(context, widget.options[selectedIndex]),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomPopupMenu extends StatefulWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _CustomPopupMenu({this.onEdit, this.onDelete});

  @override
  State<_CustomPopupMenu> createState() => _CustomPopupMenuState();
}

class _CustomPopupMenuState extends State<_CustomPopupMenu> {
  final GlobalKey _iconKey = GlobalKey();

  void _showMenu() async {
    final RenderBox button = _iconKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size size = button.size;
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: const TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: const TextStyle(fontFamily: 'InterDisplay', fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black)),
        ),
      ],
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
    );
    if (result == 'edit' && widget.onEdit != null) widget.onEdit!();
    if (result == 'delete' && widget.onDelete != null) widget.onDelete!();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      icon: const Icon(Icons.more_vert, color: Colors.black, size: 22),
      onPressed: _showMenu,
      splashRadius: 20,
    );
  }
} 