import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/pet.dart';
import '../models/user.dart' as app_user;
import '../models/pet_ownership_request.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AddPetOwnerDialog extends StatefulWidget {
  final Pet pet;
  final List<String> existingOwnerIds;

  const AddPetOwnerDialog({
    Key? key,
    required this.pet,
    required this.existingOwnerIds,
  }) : super(key: key);

  @override
  State<AddPetOwnerDialog> createState() => _AddPetOwnerDialogState();
}

class _AddPetOwnerDialogState extends State<AddPetOwnerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<app_user.User> searchResults = [];
  bool isSearching = false;
  bool isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    try {
      final dbService = DatabaseService();
      final users = await dbService.searchUsers(
        displayName: query,
        email: query,
        limit: 20,
      );
      
      // Filter out existing owners
      final filteredUsers = users.where((user) => 
        !widget.existingOwnerIds.contains(user.id)
      ).toList();

      setState(() {
        searchResults = filteredUsers;
        isSearching = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        isSearching = false;
        searchResults = [];
      });
    }
  }

  Future<void> _sendOwnershipRequest(app_user.User targetUser) async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    setState(() => isLoading = true);

    try {
      final request = PetOwnershipRequest(
        id: '', // Will be set by Firestore
        petId: widget.pet.id,
        petName: widget.pet.name,
        petBreed: widget.pet.breed,
        petAge: widget.pet.age,
        petPhotoUrl: widget.pet.photoURL,
        fromUserId: currentUser.id,
        fromUserName: currentUser.displayName ?? currentUser.email,
        toUserId: targetUser.id,
        toUserName: targetUser.displayName ?? targetUser.email,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final requestId = await DatabaseService().createPetOwnershipRequest(request);
      print('✅ [AddPetOwnerDialog] Created ownership request with ID: $requestId');

      // Send notification to target user
      await DatabaseService().sendNotification(
        userId: targetUser.id,
        senderId: currentUser.id,
        senderName: currentUser.displayName ?? currentUser.email,
        title: AppLocalizations.of(context)!.petOwnershipRequest,
        body: '${currentUser.displayName ?? currentUser.email} wants to add you as an owner of ${widget.pet.name}',
        type: 'pet_ownership_request',
        data: {
          'requestId': requestId,
          'petId': widget.pet.id,
          'petName': widget.pet.name,
          'fromUserId': currentUser.id,
          'fromUserName': currentUser.displayName ?? currentUser.email,
        },
        relatedId: widget.pet.id,
      );

      setState(() => isLoading = false);
      
      if (mounted) {
        Navigator.of(context).pop({
          'success': true,
          'message': AppLocalizations.of(context)!.ownershipRequestSent(targetUser.displayName ?? targetUser.email),
        });
      }
    } catch (e) {
      print('Error sending ownership request: $e');
      setState(() => isLoading = false);
      
      if (mounted) {
        Navigator.of(context).pop({
          'success': false,
          'message': AppLocalizations.of(context)!.errorSendingRequest,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.addPetOwner,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  l10n.searchForUsersToAddAsOwners(widget.pet.name),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Search Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by name or email...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                          ),
                          onChanged: (value) {
                            // Debounce search
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_searchController.text == value) {
                                _searchUsers(value);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Results
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.orange),
                          )
                        : isSearching
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.orange),
                              )
                            : searchResults.isEmpty && _searchController.text.isNotEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppLocalizations.of(context)!.noUsersFound,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context)!.trySearchingWithDifferentName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : _searchController.text.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              AppLocalizations.of(context)!.startTypingToSearch,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: searchResults.length,
                                        itemBuilder: (context, index) {
                                          final user = searchResults[index];
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.all(12),
                                              leading: CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Colors.orange.withOpacity(0.1),
                                                                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? Text(
                                        (user.displayName ?? user.email).isNotEmpty
                                            ? (user.displayName ?? user.email)[0].toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                                                            title: Text(
                                user.displayName ?? user.email,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              subtitle: Text(
                                                user.email,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              trailing: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(20),
                                                    onTap: () => _sendOwnershipRequest(user),
                                                    child: Padding(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(context)!.sendRequest,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                  ),
                ),

                // Bottom padding
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
