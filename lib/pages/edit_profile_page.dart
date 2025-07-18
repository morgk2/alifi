import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../widgets/placeholder_image.dart';
import '../icons.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:flutter/services.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '@username');
    _displayNameController = TextEditingController(text: user?.displayName ?? 'Display Name');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement account deletion
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();
    final updatedUser = user.copyWith(
      username: newUsername,
      displayName: _displayNameController.text.trim(),
    );

    setState(() => _isSaving = true);
    try {
      // Check if username is taken (and not the current user's username)
      if (newUsername != user.username) {
        final taken = await DatabaseService().isUsernameTaken(newUsername);
        if (taken) {
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This username is already taken. Please choose another.')),
            );
          }
          return;
        }
      }
      await DatabaseService().updateUser(updatedUser);
      authService.updateCurrentUser(updatedUser);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Information saved!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? SpinningLoader(size: 32, color: Colors.orange)
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFFF9E42),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          final user = authService.currentUser;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Stack(
                            children: [
                              if (user?.photoURL != null)
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage(user!.photoURL!),
                                )
                              else
                                const PlaceholderImage(
                                  width: 120,
                                  height: 120,
                                  isCircular: true,
                                ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9E42),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement image picker
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: 'username',
                                border: OutlineInputBorder(),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'@')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username cannot be empty';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(value.trim())) {
                                  return 'Invalid username (3-20 chars, letters, numbers, _)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Display Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                hintText: 'Display Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Display name cannot be empty';
                                }
                                if (value.trim().length < 3) {
                                  return 'Display name must be at least 3 characters';
                                }
                                if (value.trim().length > 30) {
                                  return 'Display name must be at most 30 characters';
                                }
                                if (!RegExp(r"^[a-zA-Z0-9 _\-.'!]+$").hasMatch(value.trim())) {
                                  return 'Display name contains invalid characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Linked Accounts',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLinkedAccountTile(
                              'Google',
                              AppIcons.googleIcon,
                              user?.linkedAccounts['google'] ?? false,
                              () {
                                // Already implemented in AuthService
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildLinkedAccountTile(
                              'Facebook',
                              AppIcons.facebookIcon,
                              user?.linkedAccounts['facebook'] ?? false,
                              () {
                                // TODO: Implement Facebook account linking
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildLinkedAccountTile(
                              'Apple',
                              AppIcons.appleIcon,
                              user?.linkedAccounts['apple'] ?? false,
                              () {
                                // TODO: Implement Apple account linking
                              },
                            ),
                            const SizedBox(height: 40),
                            Center(
                              child: TextButton(
                                onPressed: _showDeleteAccountDialog,
                                child: const Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
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
              ), // <-- ✅ comma added here
              if (_isSaving)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 80),
                        SpinningLoader(size: 64, color: Colors.orange),
                        const SizedBox(height: 16),
                        const Text('Saving...', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLinkedAccountTile(
    String title,
    String icon,
    bool isLinked,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SvgPicture.string(
            icon,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (isLinked)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
          else
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Text(
                'Link',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpinningLoader extends StatefulWidget {
  @override
  State<_SpinningLoader> createState() => _SpinningLoaderState();
}

class _SpinningLoaderState extends State<_SpinningLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
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
        return Transform.rotate(
          angle: _controller.value * 6.28319, // 2*pi
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/loading.png',
        width: 64,
        height: 64,
      ),
    );
  }
}
