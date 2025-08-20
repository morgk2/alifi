import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../l10n/app_localizations.dart';
import '../models/pet.dart';
import '../models/pet_profile.dart';
import '../models/pet_post.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../widgets/pet_profile_skeleton.dart';

class PetProfilePage extends StatefulWidget {
  final Pet pet;

  const PetProfilePage({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  PetProfile? petProfile;
  bool isLoading = true;
  bool isFollowing = false;
  List<PetPost> posts = [];
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPetProfile();
  }

  Future<void> _loadPetProfile() async {
    try {
      setState(() => isLoading = true);
      
      final profile = await DatabaseService().getPetProfile(widget.pet.id);
      final currentUser = context.read<AuthService>().currentUser;
      
      if (profile != null && currentUser != null) {
        final following = await DatabaseService().isFollowingPet(currentUser.id, widget.pet.id);
        setState(() {
          petProfile = profile;
          isFollowing = following;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }

      // Load posts
      DatabaseService().getPetPosts(widget.pet.id).listen((postsList) {
        if (mounted) {
          setState(() {
            posts = postsList;
          });
        }
      });
    } catch (e) {
      print('Error loading pet profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _addPhoto() async {
    try {
      // Check if maximum photos reached
      if (posts.length >= 4) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.maximumPhotosAllowed),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() => isUploading = true);

      // Get original file size
      final originalBytes = await image.readAsBytes();
      final originalSize = originalBytes.length;
      
      // Compress the image to 70%
      final File originalFile = File(image.path);
      final String dir = path.dirname(image.path);
      final String newPath = path.join(dir, 'compressed_${path.basename(image.path)}');
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        newPath,
        quality: 70, // 70% quality as requested
        minWidth: 800,
        minHeight: 800,
        rotate: 0,
      );
      
      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      final compressedSize = File(compressedFile.path).lengthSync();
      final compressionRatio = (1 - (compressedSize / originalSize)) * 100;
      
      print('Image compressed successfully:');
      print('- Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
      print('- Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
      print('- Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

      // Upload to storage
      final storageService = context.read<StorageService>();
      final imageUrl = await storageService.uploadPetPhoto(File(compressedFile.path));

      // Create post in database
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        await DatabaseService().createPetPost(
          petId: widget.pet.id,
          userId: currentUser.id,
          imageUrl: imageUrl,
        );
      }

      setState(() => isUploading = false);

      // Refresh the page to show the new post
      _loadPetProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photoAddedSuccessfully),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding photo: $e');
      setState(() => isUploading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToAddPhoto(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddPhotoMenu() {
    // Directly trigger photo add instead of showing menu
    _addPhoto();
  }

  void _showPhotoFocus(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _PhotoFocusView(
            imageUrl: imageUrl,
            animation: animation,
            pet: widget.pet,
          );
        },
      ),
    );
  }

  Future<void> _toggleFollow() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null || petProfile == null) return;

    try {
      if (isFollowing) {
        await DatabaseService().unfollowPet(currentUser.id, widget.pet.id);
      } else {
        await DatabaseService().followPet(currentUser.id, widget.pet.id);
      }
      
      setState(() {
        isFollowing = !isFollowing;
        petProfile = petProfile!.copyWith(
          followersCount: isFollowing 
            ? petProfile!.followersCount + 1 
            : petProfile!.followersCount - 1,
        );
      });
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return const PetProfileSkeleton();
    }

    if (petProfile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Pet profile not found',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800, // ExtraBold weight
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // App Bar with back button
            Container(
              height: 100,
              padding: const EdgeInsets.only(top: 40, left: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                                     // Profile Picture
                   Container(
                     width: 120,
                     height: 120,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.white,
                       border: Border.all(
                         color: _parseColor(widget.pet.color),
                         width: 3,
                       ),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.2),
                           blurRadius: 12,
                           offset: const Offset(0, 4),
                         ),
                       ],
                     ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(57), // Adjusted for 3px border
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
                  
                  const SizedBox(height: 16),
                  
                  // Pet Name
                  Text(
                    widget.pet.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900, // Black weight
                      color: Colors.black,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Followers Count
                  Text(
                    '${petProfile!.followersCount} followers',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800, // ExtraBold weight
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pet Info Chips
                  _buildInfoChips(),
                  
                  const SizedBox(height: 24),
                  
                  // Follow Button (if not owner)
                  if (!widget.pet.ownerIds.contains(context.read<AuthService>().currentUser?.id))
                    _buildFollowButton(),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Photo Grid
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length, // Only show actual photos
                itemBuilder: (context, index) {
                  return _buildPhotoTile(posts[index].imageUrl);
                },
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      // Floating Add Photo Button (if owner and less than 4 photos)
      floatingActionButton: widget.pet.ownerIds.contains(context.read<AuthService>().currentUser?.id) && posts.length < 4
          ? _buildFloatingAddPhotoButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPetPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.paw,
        size: 50,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildInfoChips() {
    final age = widget.pet.age;
    String ageText;
    
    if (age < 1) {
      final months = (age * 12).round();
      ageText = '$months month${months != 1 ? 's' : ''}';
    } else {
      final years = age.floor();
      final months = ((age - years) * 12).round();
      if (months > 0) {
        ageText = '$years year${years != 1 ? 's' : ''} $months month${months != 1 ? 's' : ''}';
      } else {
        ageText = '$years year${years != 1 ? 's' : ''}';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              widget.pet.gender == 'male' ? 'Male' : 'Female',
              style: const TextStyle(
                color: Color(0xFF7FB6FF), // Male color
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900, // Black weight
                fontSize: 16,
              ).copyWith(
                color: widget.pet.gender == 'male' 
                    ? const Color(0xFF7FB6FF) 
                    : const Color(0xFFFFA5B1), // Female color
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 1,
            height: 18,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Text(
              ageText,
              style: const TextStyle(
                color: Color(0xFFFFC464), // Age color
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900, // Black weight
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 1,
            height: 18,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Text(
              widget.pet.breed,
              style: const TextStyle(
                color: Color(0xFF95DF97), // Breed color
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900, // Black weight
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Center(
      child: Container(
        height: 48,
        child: ElevatedButton(
          onPressed: _toggleFollow,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey.shade200 : Colors.orange,
            foregroundColor: isFollowing ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(
              fontWeight: FontWeight.w800, // ExtraBold weight
              fontSize: 16,
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(String imageUrl) {
    return GestureDetector(
      onTap: () => _showPhotoFocus(imageUrl),
      child: Hero(
        tag: imageUrl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18), // Adjusted for thicker border
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade100,
                child: Icon(
                  CupertinoIcons.photo,
                  color: Colors.grey.shade400,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAddPhotoButton() {
    return GestureDetector(
      onTap: isUploading ? null : _showAddPhotoMenu,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Squircle shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isUploading
            ? CupertinoActivityIndicator(
                color: _parseColor(widget.pet.color),
                radius: 12,
              )
            : Icon(
                Icons.add,
                color: _parseColor(widget.pet.color),
                size: 30,
              ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    final hexMatch = RegExp(r'0x[a-fA-F0-9]{8}').firstMatch(colorString);
    if (hexMatch != null) {
      return Color(int.parse(hexMatch.group(0)!));
    }
    return const Color(0xFFF59E0B);
  }
}

class _PhotoFocusView extends StatefulWidget {
  final String imageUrl;
  final Animation<double> animation;
  final Pet pet;

  const _PhotoFocusView({
    Key? key,
    required this.imageUrl,
    required this.animation,
    required this.pet,
  }) : super(key: key);

  @override
  State<_PhotoFocusView> createState() => _PhotoFocusViewState();
}

class _PhotoFocusViewState extends State<_PhotoFocusView> {
  PetPost? currentPost;
  bool isLoading = true;
  bool isEditingCaption = false;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadPostData() async {
    try {
      // Find the post with this image URL
      final posts = await DatabaseService().getPetPosts(widget.pet.id).first;
      final post = posts.firstWhere(
        (p) => p.imageUrl == widget.imageUrl,
        orElse: () => posts.first,
      );
      
      setState(() {
        currentPost = post;
        _captionController.text = post.caption ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading post data: $e');
      setState(() => isLoading = false);
    }
  }

  void _toggleCaptionEdit() {
    setState(() {
      if (isEditingCaption) {
        // Save the caption
        _saveCaption();
      } else {
        // Start editing
        isEditingCaption = true;
      }
    });
  }

  void _cancelCaptionEdit() {
    setState(() {
      isEditingCaption = false;
      _captionController.text = currentPost?.caption ?? '';
    });
  }

  Future<void> _saveCaption() async {
    final newCaption = _captionController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await DatabaseService().updatePetPostCaption(currentPost!.id, newCaption);
      
      setState(() {
        currentPost = currentPost!.copyWith(caption: newCaption.isEmpty ? null : newCaption);
        isEditingCaption = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.captionUpdatedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating caption: $e');
      setState(() {
        isEditingCaption = false;
        _captionController.text = currentPost?.caption ?? '';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateCaption(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool _shouldShowCaptionPanel() {
    final currentUser = context.read<AuthService>().currentUser;
    final isOwner = widget.pet.ownerIds.contains(currentUser?.id);
    final hasCaption = currentPost?.caption?.isNotEmpty == true;
    
    // Show panel if user is owner (so they can add captions) OR if there's a caption to display
    return isOwner || hasCaption;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FadeTransition(
            opacity: widget.animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: widget.animation,
                curve: Curves.easeOutBack,
              )),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo
                  Hero(
                    tag: widget.imageUrl,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey.shade100,
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Colors.grey.shade400,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Caption Panel (only show if there's a caption OR user is owner)
                  if (!isLoading && _shouldShowCaptionPanel()) _buildCaptionPanel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionPanel() {
    final currentUser = context.read<AuthService>().currentUser;
    final isOwner = widget.pet.ownerIds.contains(currentUser?.id);
    final hasCaption = currentPost?.caption?.isNotEmpty == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to top for better multiline text alignment
        children: [
          Expanded(
            child: isEditingCaption
                ? TextField(
                    controller: _captionController,
                    maxLines: null, // Allow unlimited lines for expansion
                    minLines: 1,    // Start with 1 line minimum
                    maxLength: 200, // Keep 200 character limit
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.writeCaptionForPhoto,
                      border: InputBorder.none,
                      counterText: '', // Hide character counter
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    autofocus: true,
                  )
                : GestureDetector(
                    onTap: isOwner ? _toggleCaptionEdit : null,
                    child:                       Text(
                        hasCaption 
                            ? currentPost!.caption! 
                            : isOwner 
                                ? AppLocalizations.of(context)!.addCaptionToPhoto
                                : AppLocalizations.of(context)!.noCaption,
                        style: TextStyle(
                          fontSize: 14,
                          color: hasCaption 
                              ? Colors.black87 
                              : Colors.grey.shade600,
                          fontStyle: hasCaption ? FontStyle.normal : FontStyle.italic,
                        ),
                        // Remove maxLines and overflow to allow full text expansion
                      ),
                  ),
          ),
          if (isOwner) ...[
            const SizedBox(width: 8),
            if (isEditingCaption) ...[
              GestureDetector(
                onTap: _cancelCaptionEdit,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleCaptionEdit,
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.green,
                ),
              ),
            ] else
              GestureDetector(
                onTap: _toggleCaptionEdit,
                child: Icon(
                  hasCaption ? Icons.edit : Icons.add,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ],
      ),
    );
  }
}