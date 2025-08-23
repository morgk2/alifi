import 'package:alifi/pages/store_signup_page.dart';
import 'package:alifi/pages/vet_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../icons.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../widgets/spinning_loader.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../l10n/app_localizations.dart';
import '../dialogs/social_media_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  late TextEditingController _basicInfoController;
  File? _selectedCoverFile;
  String? _coverPreviewUrl;
  File? _selectedProfileFile;
  
  // Social media controllers
  Map<String, String> _socialMedia = {};
  
  // Replace setState variable with ValueNotifier for better performance
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '@username');
    _displayNameController = TextEditingController(text: user?.displayName ?? 'Display Name');
    _basicInfoController = TextEditingController(text: user?.basicInfo ?? '');
    _coverPreviewUrl = user?.coverPhotoURL;
    _socialMedia = Map<String, String>.from(user?.socialMedia ?? {});
  }

  Future<void> _pickProfilePicture() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final File originalFile = File(image.path);
      final String dir = path.dirname(image.path);
      final String newPath = path.join(dir, 'compressed_profile_${path.basename(image.path)}');
      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        newPath,
        quality: 80,
        minWidth: 400,
        minHeight: 400,
      );

      final String chosenPath = compressed != null ? compressed.path : originalFile.path;
      setState(() {
        _selectedProfileFile = File(chosenPath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting profile picture: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickCover() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final File originalFile = File(image.path);
      final String dir = path.dirname(image.path);
      final String newPath = path.join(dir, 'compressed_${path.basename(image.path)}');
      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        newPath,
        quality: 70,
        minWidth: 1200,
        minHeight: 400,
      );

      final String chosenPath = compressed != null ? compressed.path : originalFile.path;
      setState(() {
        _selectedCoverFile = File(chosenPath);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSelectingCover(e.toString()))),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _basicInfoController.dispose();
    
    // Dispose ValueNotifier
    _isSavingNotifier.dispose();
    
    super.dispose();
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteAccount,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.areYouSureYouWantToDeleteYourAccount,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement account deletion
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();
    var updatedUser = user.copyWith(
      username: newUsername,
      displayName: _displayNameController.text.trim(),
      basicInfo: ['vet', 'store'].contains(user.accountType) 
        ? _basicInfoController.text.trim() 
        : user.basicInfo,
    );

    _isSavingNotifier.value = true;
    try {
      // Handle profile picture upload for store/vet accounts only
      if (_selectedProfileFile != null && ['store', 'vet'].contains(user.accountType)) {
        final storageService = Provider.of<StorageService>(context, listen: false);
        final profileUrl = await storageService.uploadPetPhoto(_selectedProfileFile!);
        updatedUser = updatedUser.copyWith(photoURL: profileUrl);
      }
      
      if (_selectedCoverFile != null) {
        final storageService = Provider.of<StorageService>(context, listen: false);
        final coverUrl = await storageService.uploadPetPhoto(_selectedCoverFile!);
        updatedUser = updatedUser.copyWith(coverPhotoURL: coverUrl);
      }
      
      // Update social media
      updatedUser = updatedUser.copyWith(socialMedia: _socialMedia);
      await DatabaseService().updateUser(updatedUser);
      authService.updateCurrentUser(updatedUser);

      if (mounted) {
        _isSavingNotifier.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccessfully),
            backgroundColor: const Color(0xFFFF9E42),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _isSavingNotifier.value = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateProfile(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
          'assets/images/back_icon.png',
          width: 24,
          height: 24,
          color: Colors.black,
        ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.editProfile,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, child) {
              return TextButton(
                onPressed: isSaving ? null : _saveChanges,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9E42)),
                    ),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: Color(0xFFFF9E42),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          final user = authService.currentUser;
          if (user == null) {
            return const Center(child: SpinningLoader());
          }
          final isNormalUser = user.accountType == 'normal';
          final isVetOrStore = ['vet', 'store'].contains(user.accountType);

          return Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Picture Section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                // Profile picture display
                                _selectedProfileFile != null
                                    ? CircleAvatar(
                                        radius: 60,
                                        backgroundImage: FileImage(_selectedProfileFile!),
                                      )
                                    : (user.photoURL != null && user.photoURL!.isNotEmpty)
                                        ? CircleAvatar(
                                            radius: 60,
                                            backgroundImage: NetworkImage(user.photoURL!),
                                          )
                                        : Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                          ),
                                // Camera button - only show for store/vet accounts
                                if (['store', 'vet'].contains(user.accountType))
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
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: _pickProfilePicture,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ['store', 'vet'].contains(user.accountType) 
                                  ? l10n.tapToChangePhoto
                                  : 'Profile picture changes available for store and vet accounts only',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      if ((user.subscriptionPlan ?? '').toLowerCase() == 'alifi favorite')
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.coverPhotoOptional,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      height: 140,
                                      width: double.infinity,
                                      child: _selectedCoverFile != null
                                          ? Image.file(_selectedCoverFile!, fit: BoxFit.cover)
                                          : (_coverPreviewUrl != null && _coverPreviewUrl!.isNotEmpty)
                                              ? Image.network(_coverPreviewUrl!, fit: BoxFit.cover)
                                              : Container(
                                                  color: Colors.grey[200],
                                                  alignment: Alignment.center,
                                                  child: const Icon(Icons.image, color: Colors.grey, size: 40),
                                                ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: ElevatedButton.icon(
                                      onPressed: _pickCover,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9E42),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                      label: Text(l10n.changeCover, style: const TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      // Form Fields Section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(
                              label: l10n.username,
                              controller: _usernameController,
                              hintText: l10n.enterUsername,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.usernameCannotBeEmpty;
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(value.trim())) {
                                  return l10n.invalidUsername;
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'@')),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            _buildFormField(
                              label: l10n.displayName,
                              controller: _displayNameController,
                              hintText: l10n.enterDisplayName,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.displayNameCannotBeEmpty;
                                }
                                return null;
                              },
                            ),
                            
                            if (isVetOrStore) ...[
                              const SizedBox(height: 24),
                              _buildFormField(
                                label: l10n.professionalInfo,
                                controller: _basicInfoController,
                                hintText: l10n.enterYourQualificationsExperience,
                                maxLines: 4,
                                maxLength: 500,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      if (isNormalUser) ...[
                        const SizedBox(height: 16),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.accountType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildAccountTypeTile(
                                l10n.requestToBeAVet,
                                AppIcons.petsIcon,
                                l10n.joinOurVeterinaryNetwork,
                                () {
                                  NavigationService.push(
                                    context,
                                    const VetSignUpPage(),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildAccountTypeTile(
                                l10n.requestToBeAStore,
                                AppIcons.storeIcon,
                                l10n.sellPetProductsAndServices,
                                () {
                                  NavigationService.push(
                                    context,
                                    const StoreSignUpPage(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Social Media Section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Social Media',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSocialMediaTile('TikTok', AppIcons.tiktokIcon, null),
                            const SizedBox(height: 12),
                            _buildSocialMediaTile('Facebook', AppIcons.facebookIcon, null),
                            const SizedBox(height: 12),
                            _buildSocialMediaTile('Instagram', AppIcons.instagramIcon, null),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Linked Accounts Section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.linkedAccounts,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLinkedAccountTile(
                              'Google',
                              AppIcons.googleIcon,
                              user.linkedAccounts['google'] ?? false,
                              () {
                                // Already implemented in AuthService
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildLinkedAccountTile(
                              'Facebook',
                              AppIcons.facebookIcon,
                              user.linkedAccounts['facebook'] ?? false,
                              () {
                                // TODO: Implement Facebook account linking
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildLinkedAccountTile(
                              'Apple',
                              AppIcons.appleIcon,
                              user.linkedAccounts['apple'] ?? false,
                              () {
                                // TODO: Implement Apple account linking
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Delete Account Section
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: TextButton(
                            onPressed: _showDeleteAccountDialog,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.red[300]!),
                              ),
                            ),
                            child: Text(
                              l10n.deleteAccount,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              
              // Loading Overlay
              ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, child) {
                  if (isSaving) {
                    return Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SpinningLoader(size: 64, color: Color(0xFFFF9E42)),
                            const SizedBox(height: 16),
                            Text(
                              l10n.savingChanges,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF9E42), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }

  Widget _buildAccountTypeTile(
    String title,
    String icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9E42).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.string(
                icon,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFFFF9E42), BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedAccountTile(
    String title,
    String icon,
    bool isLinked,
    VoidCallback onTap,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: SvgPicture.string(
              icon,
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          if (isLinked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.linked,
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: const Color(0xFFFF9E42).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.link,
                style: const TextStyle(
                  color: Color(0xFFFF9E42),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaTile(String platform, String? svgIcon, String? emoji) {
    final l10n = AppLocalizations.of(context)!;
    final hasAccount = _socialMedia.containsKey(platform.toLowerCase()) && 
                      _socialMedia[platform.toLowerCase()]!.isNotEmpty;
    final username = _socialMedia[platform.toLowerCase()];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: svgIcon != null
                ? SvgPicture.string(
                    svgIcon,
                    width: 20,
                    height: 20,
                  )
                : Text(
                    emoji ?? '🔗',
                    style: const TextStyle(fontSize: 20),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (hasAccount && username != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showSocialMediaDialog(platform),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: hasAccount 
                  ? Colors.orange[50]
                  : const Color(0xFFFF9E42).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              hasAccount ? l10n.edit : 'Add',
              style: TextStyle(
                color: hasAccount ? Colors.orange[700] : const Color(0xFFFF9E42),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSocialMediaDialog(String platform) async {
    final currentUsername = _socialMedia[platform.toLowerCase()];
    
    await showDialog(
      context: context,
      builder: (context) => SocialMediaDialog(
        platform: platform,
        currentUsername: currentUsername,
        onSave: (username) {
          setState(() {
            _socialMedia[platform.toLowerCase()] = username;
          });
        },
        onRemove: currentUsername != null && currentUsername.isNotEmpty ? () {
          setState(() {
            _socialMedia.remove(platform.toLowerCase());
          });
        } : null,
      ),
    );
  }
}
