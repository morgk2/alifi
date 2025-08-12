import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../services/database_service.dart';
import 'page_container.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<User> _users = [];
  bool _isLoading = true;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('displayName')
          .get();

      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          displayName: data['displayName'] ?? 'Unknown',
          email: data['email'] ?? '',
          photoURL: data['photoURL'] ?? '',
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
          lastLoginAt: data['lastLoginAt'] != null 
              ? (data['lastLoginAt'] as Timestamp).toDate() 
              : DateTime.now(),
          linkedAccounts: Map<String, bool>.from(data['linkedAccounts'] ?? {}),
          accountType: data['accountType'] ?? 'normal',
          isVerified: data['isVerified'] ?? false,
          city: data['city'] ?? '',
          phone: data['phone'] ?? '',
        );
      }).toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginAsUser(User user) async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final authService = context.read<AuthService>();
      
      // Simulate login process
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Set the user in auth service without actual Firebase auth
      await authService.setCurrentUser(user);
      
      // Navigate to home page
      NavigationService.pushReplacement(
        context,
        const PageContainer(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in as ${user.displayName}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Admin - All Users',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Colors.orange,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: (user.photoURL?.isNotEmpty == true)
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: (user.photoURL?.isEmpty != false)
                            ? Text(
                                (user.displayName?.isNotEmpty == true)
                                    ? user.displayName![0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user.displayName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getUserTypeColor(user.accountType),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.accountType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: _isLoggingIn
                          ? const CupertinoActivityIndicator(
                              radius: 12,
                              color: Colors.orange,
                            )
                          : ElevatedButton(
                              onPressed: () => _loginAsUser(user),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'store':
        return Colors.blue;
      case 'vet':
        return Colors.green;
      case 'user':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
