import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/app_localizations.dart';
import '../models/pet.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../dialogs/add_pet_owner_dialog.dart';

class PetOwnersPage extends StatefulWidget {
  final Pet pet;

  const PetOwnersPage({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<PetOwnersPage> createState() => _PetOwnersPageState();
}

class _PetOwnersPageState extends State<PetOwnersPage> {
  List<app_user.User> owners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    try {
      setState(() => isLoading = true);
      
      final dbService = DatabaseService();
      final ownersList = <app_user.User>[];
      
      for (final ownerId in widget.pet.ownerIds) {
        final user = await dbService.getUser(ownerId);
        if (user != null) {
          ownersList.add(user);
        }
      }
      
      setState(() {
        owners = ownersList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading owners: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading pet owners'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addOwner() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => AddPetOwnerDialog(
        pet: widget.pet,
        existingOwnerIds: widget.pet.ownerIds,
      ),
    );

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Owner request sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.read<AuthService>().currentUser;
    final isPrimaryOwner = currentUser?.id == widget.pet.ownerId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.petOwners,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (widget.pet.ownerIds.contains(currentUser?.id))
                IconButton(
                  icon: Icon(Icons.person_add, color: Colors.orange),
                  onPressed: _addOwner,
                ),
            ],
          ),

          // Pet Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Pet Photo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: widget.pet.photoURL != null
                              ? Image.network(
                                  widget.pet.photoURL!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPetPlaceholder(),
                                )
                              : _buildPetPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Pet Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pet.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.pet.breed,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.pet.age.toStringAsFixed(1)} years old',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Owners Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Owners (${owners.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (widget.pet.ownerIds.contains(currentUser?.id))
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addOwner,
                        iconSize: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Owners List
          if (isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
            )
          else if (owners.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No owners found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final owner = owners[index];
                  final isPrimary = owner.id == widget.pet.ownerId;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          backgroundImage: owner.photoURL != null
                              ? NetworkImage(owner.photoURL!)
                              : null,
                          child: owner.photoURL == null
                              ? Text(
                                  (owner.displayName ?? owner.email).isNotEmpty
                                      ? (owner.displayName ?? owner.email)[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                owner.displayName ?? owner.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isPrimary)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Primary',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          owner.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        trailing: _buildOwnerMenu(owner, isPrimary, isPrimaryOwner),
                      ),
                    ),
                  );
                },
                childCount: owners.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPetPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
      ),
      child: const Icon(
        Icons.pets,
        size: 40,
        color: Colors.orange,
      ),
    );
  }

  Widget? _buildOwnerMenu(app_user.User owner, bool isPrimary, bool isPrimaryOwner) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = owner.id == currentUser?.id;
    
    // Don't show menu for primary owner (they can't be removed)
    if (isPrimary) return null;
    
    // Show menu if:
    // 1. Current user is the primary owner (can remove others)
    // 2. This is the current user's own card (can withdraw)
    if (!isPrimaryOwner && !isCurrentUser) return null;
    
    return _CustomDropdownMenu(
      onSelected: (action) {
        if (action == 'withdraw' && isCurrentUser) {
          _withdrawOwnership(owner);
        } else if (action == 'remove' && isPrimaryOwner) {
          _removeOwner(owner);
        }
      },
      items: [
        if (isCurrentUser)
          _DropdownItem(
            value: 'withdraw',
            icon: Icons.exit_to_app,
            text: 'Withdraw Ownership',
            color: Colors.orange,
          ),
        if (isPrimaryOwner && !isCurrentUser)
          _DropdownItem(
            value: 'remove',
            icon: Icons.person_remove,
            text: 'Remove Owner',
            color: Colors.red,
          ),
      ],
    );
  }

  Future<void> _withdrawOwnership(app_user.User owner) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Withdraw Ownership',
      content: 'Are you sure you want to withdraw your ownership of ${widget.pet.name}?\n\nYou will no longer be able to access or edit this pet\'s information.',
      confirmText: 'Withdraw',
      confirmColor: Colors.orange,
      icon: Icons.exit_to_app,
    );

    if (confirmed == true) {
      await _removeOwnerFromPet(owner, isWithdraw: true);
    }
  }

  Future<void> _removeOwner(app_user.User owner) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Remove Owner',
      content: 'Are you sure you want to remove ${owner.displayName ?? owner.email} as an owner of ${widget.pet.name}?\n\nThey will no longer be able to access or edit this pet\'s information.',
      confirmText: 'Remove',
      confirmColor: Colors.red,
      icon: Icons.person_remove,
    );

    if (confirmed == true) {
      await _removeOwnerFromPet(owner, isWithdraw: false);
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: confirmColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeOwnerFromPet(app_user.User owner, {required bool isWithdraw}) async {
    try {
      final updatedOwnerIds = List<String>.from(widget.pet.ownerIds);
      updatedOwnerIds.remove(owner.id);

      await FirebaseFirestore.instance
          .collection('pets')
          .doc(widget.pet.id)
          .update({'ownerIds': updatedOwnerIds});

      if (isWithdraw) {
        // If withdrawing, navigate back to pets page
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have withdrawn your ownership of ${widget.pet.name}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // If removing someone else, reload the owners list
        await _loadOwners();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${owner.displayName ?? owner.email} removed as owner'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error ${isWithdraw ? 'withdrawing' : 'removing'} owner: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ${isWithdraw ? 'withdrawing ownership' : 'removing owner'}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _DropdownItem {
  final String value;
  final IconData icon;
  final String text;
  final Color color;

  _DropdownItem({
    required this.value,
    required this.icon,
    required this.text,
    required this.color,
  });
}

class _CustomDropdownMenu extends StatelessWidget {
  final Function(String) onSelected;
  final List<_DropdownItem> items;

  const _CustomDropdownMenu({
    required this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      onSelected: onSelected,
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
        size: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      offset: const Offset(-8, 0),
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<String>(
          value: item.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    size: 16,
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item.text,
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
