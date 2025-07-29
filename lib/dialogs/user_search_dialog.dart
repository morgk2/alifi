import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';

class UserSearchDialog extends StatefulWidget {
  final Function(User) onUserSelected;

  const UserSearchDialog({
    super.key,
    required this.onUserSelected,
  });

  @override
  State<UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<UserSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<User>>? _searchResults;

  void _searchUsers(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResults = DatabaseService().searchUsers(displayName: query);
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Search Users',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _searchResults == null
                  ? const Center(
                      child: Text('Type to search for users'),
                    )
                  : FutureBuilder<List<User>>(
                      future: _searchResults,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: SpinningLoader());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No users found'));
                        }

                        final users = snapshot.data!;
                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.photoURL != null
                                    ? NetworkImage(user.photoURL!)
                                    : null,
                                child: user.photoURL == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(user.displayName ?? 'No Name'),
                              subtitle: Text(user.email),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: Colors.green,
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  widget.onUserSelected(user);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Select'),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 