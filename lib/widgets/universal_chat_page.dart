import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'chat_video_player.dart';
import '../services/media_upload_service.dart';
import '../models/user.dart';
import '../models/chat_message.dart';
import '../models/store_product.dart';
import '../models/service_ad.dart';
import '../models/lost_pet.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/app_fonts.dart';
import '../widgets/keyboard_dismissible_text_field.dart';
import '../widgets/currency_symbol.dart';
import '../pages/service_ad_detail_page.dart';
import '../pages/product_details_page.dart';
import '../pages/booking_page.dart';
import '../pages/user_profile_page.dart';

enum ChatType {
  discussion,
  storeProduct,
  vetConsultation,
  storeReceiver,
  serviceAd,
}

enum AttachmentType {
  product,
  order,
  serviceAd,
  lostPet,
  media, // For photos and videos
}

class UniversalChatPage extends StatefulWidget {
  final User otherUser;
  final ChatType chatType;
  final String? subtitle;
  final Color? themeColor;
  
  // Optional initial attachments
  final StoreProduct? initialProduct;
  final ServiceAd? initialServiceAd;
  final Map<String, dynamic>? initialOrderData;
  final dynamic initialLostPet;

  const UniversalChatPage({
    super.key,
    required this.otherUser,
    required this.chatType,
    this.subtitle,
    this.themeColor,
    this.initialProduct,
    this.initialServiceAd,
    this.initialOrderData,
    this.initialLostPet,
  });

  @override
  State<UniversalChatPage> createState() => _UniversalChatPageState();
}

class _UniversalChatPageState extends State<UniversalChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  List<ChatMessage> _messages = [];
  
  // Attachment states
  bool _hasProductAttachment = false;
  bool _hasServiceAdAttachment = false;
  bool _hasOrderAttachment = false;
  bool _hasLostPetAttachment = false;
  bool _hasMediaAttachment = false;
  
  StoreProduct? _attachedProduct;
  ServiceAd? _attachedServiceAd;
  Map<String, dynamic>? _attachedOrderData;
  dynamic _attachedLostPet;
  List<Map<String, dynamic>> _attachedMedia = []; // {type: 'image/video', path: String, url: String?}
  
  // Missing pet detection
  bool _userHasMissingPets = false;
  
  // Meeting scheduling
  bool _shouldShowMeetingSchedule = false;
  bool _isMeetingExpanded = true;
  List<Map<String, dynamic>> _meetings = [];
  final TextEditingController _placeController = TextEditingController();
  DateTime? _selectedDateTime;
  Timer? _meetingTimer;
  
  // Upload progress
  bool _isUploadingMedia = false;
  int _uploadProgress = 0;
  int _totalUploads = 0;

  @override
  void initState() {
    super.initState();
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));
    _slideAnimationController.forward();
    
    // Set initial attachments
    _initializeAttachments();
    _checkUserMissingPets();
    _loadMessages();
    _loadMeetings();
  }

  void _initializeAttachments() {
    if (widget.initialProduct != null) {
      _hasProductAttachment = true;
      _attachedProduct = widget.initialProduct;
    }
    if (widget.initialServiceAd != null) {
      _hasServiceAdAttachment = true;
      _attachedServiceAd = widget.initialServiceAd;
    }
    if (widget.initialOrderData != null) {
      _hasOrderAttachment = true;
      _attachedOrderData = widget.initialOrderData;
    }
    if (widget.initialLostPet != null) {
      _hasLostPetAttachment = true;
      _attachedLostPet = widget.initialLostPet;
    }
  }

  Future<void> _checkUserMissingPets() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      print('🔍 [UniversalChat] No current user found');
      return;
    }

    try {
      print('🔍 [UniversalChat] Checking missing pets for user: ${currentUser.id}');
      final hasMissingPets = await DatabaseService().userHasActiveMissingPets(currentUser.id);
      print('🔍 [UniversalChat] User has missing pets: $hasMissingPets');
      
      if (mounted) {
        setState(() {
          _userHasMissingPets = hasMissingPets;
        });
      }
    } catch (e) {
      print('❌ [UniversalChat] Error checking missing pets: $e');
    }
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.camera, color: Colors.blue),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, isVideo: false);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.photo, color: Colors.green),
              ),
              title: const Text('Photo Library'),
              subtitle: const Text('Choose from library'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo: false);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(CupertinoIcons.videocam, color: Colors.purple),
              ),
              title: const Text('Video'),
              subtitle: const Text('Record or choose video'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo: true);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? file;

      if (isVideo) {
        file = await picker.pickVideo(source: source);
      } else {
        file = await picker.pickImage(source: source);
      }

      if (file != null) {
        setState(() {
          _attachedMedia.add({
            'type': isVideo ? 'video' : 'image',
            'path': file!.path,
            'name': file.name,
          });
          _hasMediaAttachment = true;
        });
      }
    } catch (e) {
      print('Error picking media: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting media: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeMediaAttachment(int index) {
    setState(() {
      _attachedMedia.removeAt(index);
      if (_attachedMedia.isEmpty) {
        _hasMediaAttachment = false;
      }
    });
  }

  void _startMeetingTimeMonitoring() {
    // Cancel existing timer
    _meetingTimer?.cancel();
    
    // Only start monitoring if user has missing pets and there are confirmed meetings
    if (!_userHasMissingPets || !_hasConfirmedMeeting()) {
      return;
    }
    
    // Check every minute for meeting times
    _meetingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkMeetingTimes();
    });
  }

  void _checkMeetingTimes() {
    final now = DateTime.now();
    final confirmedMeeting = _getConfirmedMeeting();
    
    if (confirmedMeeting == null) return;
    
    final scheduledTime = (confirmedMeeting['scheduledTime'] as Timestamp?)?.toDate();
    if (scheduledTime == null) return;
    
    // Check if meeting time has arrived (within 5 minutes window)
    final timeDifference = now.difference(scheduledTime).inMinutes;
    if (timeDifference >= 0 && timeDifference <= 5) {
      // Meeting time has arrived, show rescue confirmation dialog
      _showRescueConfirmationDialog(confirmedMeeting);
      _meetingTimer?.cancel(); // Stop monitoring after showing dialog
    }
  }

  Future<void> _showRescueConfirmationDialog(Map<String, dynamic> meeting) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;
    
    // Determine who is the rescuer (the other person in the chat)
    final rescuerId = widget.otherUser.id;
    final rescuerName = widget.otherUser.displayName ?? 'This person';
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Important meeting confirmation
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rescue icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: Colors.blue,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Pet Rescue Confirmation',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Content
                Text(
                  'Did $rescuerName successfully help you reunite with your lost pet at the scheduled meeting?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'This will add +1 to their pet rescue count and help other pet owners.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // No Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Yes Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Yes, Rescued!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (confirmed == true) {
      await _recordPetRescue(meeting, rescuerId);
    }
  }

  Future<void> _recordPetRescue(Map<String, dynamic> meeting, String rescuerId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      if (currentUser == null) return;
      
      // Get lost pet information
      final lostPets = await DatabaseService().getUsersActiveLostPets(currentUser.id);
      if (lostPets.isEmpty) return;
      
      final lostPet = lostPets.first; // Assume first active lost pet
      
      // Record the rescue
      await DatabaseService().recordPetRescue(
        rescuerId: rescuerId,
        petOwnerId: currentUser.id,
        petId: lostPet.pet.id,
        petName: lostPet.pet.name,
        petBreed: lostPet.pet.breed,
        petImageUrls: lostPet.pet.imageUrls,
        meetingId: meeting['id'],
        rescueLocation: meeting['place'],
        rescueStory: 'Pet rescued through scheduled meeting',
      );
      
      // Mark the lost pet as found
      await DatabaseService().markLostPetAsFound(lostPet.id);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Rescue recorded! ${widget.otherUser.displayName} now has +1 pets rescued.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Error recording pet rescue: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record rescue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showFinishMeetingDialog(String meetingId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Meeting finished icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.green,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Mark Meeting as Finished?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Content
                Text(
                  'This will mark the scheduled meeting as completed and ask if your pet was successfully rescued.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'You can only do this once per meeting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Mark as Finished Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Mark as Finished',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    if (confirmed == true) {
      await _finishMeeting(meetingId);
    }
  }

  Future<void> _finishMeeting(String meetingId) async {
    try {
      // Mark meeting as completed
      await DatabaseService().markMeetingAsCompleted(meetingId);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Meeting marked as finished!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a moment, then show rescue confirmation dialog
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Get the meeting data to pass to rescue confirmation
        final meetings = _meetings.where((m) => m['id'] == meetingId).toList();
        if (meetings.isNotEmpty && mounted) {
          await _showRescueConfirmationDialog(meetings.first);
        }
      }
    } catch (e) {
      print('❌ Error finishing meeting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finish meeting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _meetingTimer?.cancel();
    super.dispose();
  }

  void _loadMessages() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    // Mark messages as read when chat is opened
    if (widget.chatType != ChatType.vetConsultation) {
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      notificationService.markAllMessagesAsRead(currentUser.id, widget.otherUser.id);
    }

    DatabaseService().getChatMessages(currentUser.id, widget.otherUser.id).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    });
  }

  void _loadMeetings() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    DatabaseService().getChatMeetings(currentUser.id, widget.otherUser.id).listen((meetings) {
      if (mounted) {
        setState(() {
          _meetings = meetings;
          // Show meeting schedule section if there are any meetings or if pet was confirmed
          _shouldShowMeetingSchedule = _shouldShowMeetingSchedule || meetings.isNotEmpty;
          
          // Auto-minimize when meeting is confirmed
          if (_hasConfirmedMeeting()) {
            _isMeetingExpanded = false;
          }
        });
        
        // Start monitoring for meeting times
        _startMeetingTimeMonitoring();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Navigation methods
  void _navigateToUserProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(user: user),
      ),
    );
  }

  // Meeting helper methods
  bool _canProposeMeeting() {
    return _placeController.text.trim().isNotEmpty && _selectedDateTime != null;
  }

  bool _hasActiveMeetingProposal(String currentUserId) {
    return _meetings.any((meeting) => 
        meeting['proposerId'] == currentUserId && 
        meeting['status'] == 'proposed');
  }

  bool _hasConfirmedMeeting() {
    return _meetings.any((meeting) => meeting['status'] == 'confirmed');
  }

  Map<String, dynamic>? _getConfirmedMeeting() {
    try {
      return _meetings.firstWhere((meeting) => meeting['status'] == 'confirmed');
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _proposeMeeting() async {
    if (!_canProposeMeeting()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    try {
      await DatabaseService().createMeeting(
        currentUser.id,
        widget.otherUser.id,
        _placeController.text.trim(),
        _selectedDateTime!,
      );

      // Don't clear form - keep the proposal details visible
      // _placeController.clear();
      // setState(() {
      //   _selectedDateTime = null;
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting proposal sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error proposing meeting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to propose meeting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmMeeting(String meetingId) async {
    try {
      await DatabaseService().updateMeetingStatus(meetingId, 'confirmed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting confirmed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error confirming meeting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to confirm meeting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectMeeting(String meetingId) async {
    try {
      await DatabaseService().updateMeetingStatus(meetingId, 'rejected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print('❌ Error rejecting meeting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject meeting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _editingMeetingId;

  void _startEditingMeeting(String meetingId) {
    // Find the meeting to edit
    final meeting = _meetings.firstWhere((m) => m['id'] == meetingId);
    
    // Pre-populate form with existing data
    _placeController.text = meeting['place'] ?? '';
    _selectedDateTime = (meeting['scheduledTime'] as Timestamp?)?.toDate();
    
    setState(() {
      _editingMeetingId = meetingId;
    });
  }

  Future<void> _updateMeetingDetails() async {
    if (_editingMeetingId == null || !_canProposeMeeting()) return;

    try {
      await DatabaseService().updateMeetingDetails(
        _editingMeetingId!, 
        _placeController.text.trim(), 
        _selectedDateTime!
      );
      
      setState(() {
        _editingMeetingId = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting details updated!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print('❌ Error updating meeting details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update meeting details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final hasText = _messageController.text.trim().isNotEmpty;
    final hasAnyAttachment = _hasProductAttachment || _hasServiceAdAttachment || _hasOrderAttachment || _hasLostPetAttachment || _hasMediaAttachment;
    
    if (!hasText && !hasAnyAttachment) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser != null) {
        final message = _messageController.text.trim();
        _messageController.clear();
        
        // Prepare attachment data
        Map<String, dynamic>? attachmentData;
        bool isOrderAttachment = false;
        
        if (_hasProductAttachment && _attachedProduct != null) {
          attachmentData = {
            'type': 'product',
            'id': _attachedProduct!.id,
            'name': _attachedProduct!.name,
            'price': _attachedProduct!.price,
            'imageUrl': _attachedProduct!.imageUrls.isNotEmpty ? _attachedProduct!.imageUrls.first : null,
            'description': _attachedProduct!.description,
            'rating': _attachedProduct!.rating,
            'totalOrders': _attachedProduct!.totalOrders,
          };
          setState(() => _hasProductAttachment = false);
        } else if (_hasServiceAdAttachment && _attachedServiceAd != null) {
          attachmentData = {
            'type': 'serviceAd',
            'id': _attachedServiceAd!.id,
            'serviceName': _attachedServiceAd!.serviceName,
            'serviceType': _attachedServiceAd!.serviceType.name,
            'imageUrl': _attachedServiceAd!.imageUrl,
            'description': _attachedServiceAd!.description,
            'locationAddress': _attachedServiceAd!.locationAddress,
            'latitude': _attachedServiceAd!.latitude,
            'longitude': _attachedServiceAd!.longitude,
            'startTime': _attachedServiceAd!.startTime,
            'endTime': _attachedServiceAd!.endTime,
            'availableDays': _attachedServiceAd!.availableDays,
            'petTypes': _attachedServiceAd!.petTypes,
            'userName': _attachedServiceAd!.userName,
            'userProfileImage': _attachedServiceAd!.userProfileImage,
            'rating': _attachedServiceAd!.rating,
            'reviewCount': _attachedServiceAd!.reviewCount,
          };
          setState(() => _hasServiceAdAttachment = false);
        } else if (_hasOrderAttachment && _attachedOrderData != null) {
          attachmentData = Map<String, dynamic>.from(_attachedOrderData!);
          attachmentData['type'] = 'order';
          isOrderAttachment = true;
          setState(() => _hasOrderAttachment = false);
        } else if (_hasLostPetAttachment && _attachedLostPet != null) {
          attachmentData = {
            'type': 'lostPet',
            'id': _attachedLostPet.id,
            'petName': _attachedLostPet.pet.name,
            'species': _attachedLostPet.pet.species,
            'breed': _attachedLostPet.pet.breed,
            'imageUrl': _attachedLostPet.pet.imageUrls.isNotEmpty ? _attachedLostPet.pet.imageUrls.first : null,
            'lastSeenDate': _attachedLostPet.lastSeenDate.toIso8601String(),
            'address': _attachedLostPet.address,
            'reward': _attachedLostPet.reward,
            'additionalInfo': _attachedLostPet.additionalInfo,
            'contactNumbers': _attachedLostPet.contactNumbers,
          };
          setState(() => _hasLostPetAttachment = false);
        } else if (_hasMediaAttachment && _attachedMedia.isNotEmpty) {
          // Upload media files to Supabase
          setState(() {
            _isUploadingMedia = true;
            _totalUploads = _attachedMedia.length;
            _uploadProgress = 0;
          });

          final mediaUploadService = MediaUploadService();
          final uploadedMedia = await mediaUploadService.uploadMultipleMedia(
            mediaFiles: _attachedMedia,
            userId: currentUser.id,
            chatId: '${currentUser.id}_${widget.otherUser.id}',
            onProgress: (current, total) {
              print('📤 [UniversalChat] Uploading media: $current/$total');
              if (mounted) {
                setState(() {
                  _uploadProgress = current;
                });
              }
            },
          );

          setState(() {
            _isUploadingMedia = false;
          });

          if (uploadedMedia.isNotEmpty) {
            attachmentData = {
              'type': 'media',
              'mediaFiles': uploadedMedia,
            };
          } else {
            // Show error if no media was uploaded successfully
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to upload media files'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          setState(() {
            _hasMediaAttachment = false;
            _attachedMedia.clear();
          });
        }
        
        // Default message for attachments without text (except media)
        String finalMessage = message;
        if (finalMessage.isEmpty && attachmentData != null) {
          switch (attachmentData['type']) {
            case 'product':
              finalMessage = 'Check out this product!';
              break;
            case 'serviceAd':
              finalMessage = 'Interested in your service';
              break;
            case 'order':
              finalMessage = 'Order details';
              break;
            case 'lostPet':
              finalMessage = 'About my lost pet';
              break;
            case 'media':
              // Allow empty message for media - no forced text
              finalMessage = '';
              break;
          }
        }
        
        // Send message to Firestore
        await DatabaseService().sendChatMessage(
          currentUser.id,
          widget.otherUser.id,
          finalMessage,
          productAttachment: attachmentData,
          isOrderAttachment: isOrderAttachment,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color get themeColor {
    return widget.themeColor ?? _getDefaultThemeColor();
  }

  Color _getDefaultThemeColor() {
    switch (widget.chatType) {
      case ChatType.discussion:
        return Colors.blue;
      case ChatType.storeProduct:
        return Colors.orange;
      case ChatType.vetConsultation:
        return Colors.green;
      case ChatType.storeReceiver:
        return Colors.purple;
      case ChatType.serviceAd:
        return Colors.blue;
    }
  }

  String get _chatTitle {
    return widget.otherUser.displayName ?? 'User';
  }

  String? get _chatSubtitle {
    if (widget.subtitle != null) return widget.subtitle;
    
    switch (widget.chatType) {
      case ChatType.vetConsultation:
        return 'VET CONSULTATION';
      case ChatType.storeProduct:
        return 'STORE CHAT';
      case ChatType.storeReceiver:
        return 'CUSTOMER CHAT';
      case ChatType.serviceAd:
        return _attachedServiceAd != null 
            ? '${_attachedServiceAd!.serviceType.name.toUpperCase()} PROVIDER'
            : null;
      case ChatType.discussion:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(),
        body: Column(
          children: [
            // Messages Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final currentUser = authService.currentUser;
                    final isFromUser = currentUser?.id == message.senderId;
                    
                    return Column(
                      children: [
                        _buildMessageWithAvatar(
                          isFromUser: isFromUser,
                          message: message.message,
                          timestamp: message.timestamp,
                        ),
                        if (message.productAttachment != null) ...[
                          const SizedBox(height: 8),
                          _buildUniversalAttachmentWithAvatar(message.productAttachment!, isFromUser, message),
                        ],
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Attachment Previews
            if (_hasProductAttachment && _attachedProduct != null)
              _buildProductAttachmentPreview(),
            if (_hasServiceAdAttachment && _attachedServiceAd != null)
              _buildServiceAdAttachmentPreview(),
            if (_hasLostPetAttachment && _attachedLostPet != null)
              _buildLostPetAttachmentPreview(),
            if (_hasOrderAttachment && _attachedOrderData != null)
              _buildOrderAttachmentPreview(),
            if (_hasMediaAttachment && _attachedMedia.isNotEmpty)
              _buildMediaAttachmentPreview(),
            
            // Meeting Schedule Section
            if (_shouldShowMeetingSchedule)
              _buildMeetingScheduleSection(),
            
            // Input Area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(widget.otherUser),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: widget.otherUser.photoURL != null && widget.otherUser.photoURL!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.otherUser.photoURL!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[200],
                        child: Icon(CupertinoIcons.person, color: Colors.grey[400]),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[200],
                        child: Icon(CupertinoIcons.person, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: Icon(CupertinoIcons.person, color: Colors.grey[400]),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _chatTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                if (_chatSubtitle != null)
                  Text(
                    _chatSubtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: widget.chatType == ChatType.vetConsultation ? [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: themeColor,
            borderRadius: BorderRadius.circular(20),
            minSize: 0,
            onPressed: _showBookingDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.calendar_badge_plus,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ] : null,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            'assets/images/back_icon.png',
            width: 24,
            height: 24,
            color: Colors.black,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.withOpacity(0.2),
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageWithAvatar({
    required bool isFromUser,
    required String message,
    required DateTime timestamp,
  }) {
    // Return empty container for empty messages (media-only messages)
    if (message.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for messages from other user (left side)
          if (!isFromUser) ...[
            GestureDetector(
              onTap: () => _navigateToUserProfile(widget.otherUser),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.otherUser.photoURL != null && widget.otherUser.photoURL!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.otherUser.photoURL!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[200],
                          child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[200],
                          child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                        ),
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFromUser ? themeColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isFromUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    color: isFromUser ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Spacing for messages from current user (right side)
          if (isFromUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required bool isFromUser,
    required String message,
    required DateTime timestamp,
  }) {
    // Keep the old method for backward compatibility
    return _buildMessageWithAvatar(
      isFromUser: isFromUser,
      message: message,
      timestamp: timestamp,
    );
  }

  Widget _buildUniversalAttachmentWithAvatar(Map<String, dynamic> attachmentData, bool isFromUser, ChatMessage message) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for attachments from other user (left side)
          if (!isFromUser) ...[
            GestureDetector(
              onTap: () => _navigateToUserProfile(widget.otherUser),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.otherUser.photoURL != null && widget.otherUser.photoURL!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.otherUser.photoURL!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[200],
                          child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32,
                          height: 32,
                          color: Colors.grey[200],
                          child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                        ),
                      )
                    : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(CupertinoIcons.person, color: Colors.grey[400], size: 16),
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Attachment content
          Flexible(
            child: _buildUniversalAttachment(attachmentData, isFromUser, message),
          ),
          
          // Spacing for attachments from current user (right side)
          if (isFromUser) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUniversalAttachment(Map<String, dynamic> attachmentData, bool isFromUser, ChatMessage message) {
    final attachmentType = attachmentData['type'] ?? 'product';
    
    switch (attachmentType) {
      case 'serviceAd':
        return _buildServiceAdAttachment(attachmentData, isFromUser);
      case 'order':
        return _buildOrderAttachment(attachmentData, isFromUser);
      case 'lostPet':
        return _buildLostPetAttachment(attachmentData, isFromUser);
      case 'media':
        return _buildMediaAttachment(attachmentData, isFromUser, message);
      case 'product':
      default:
        return _buildProductAttachment(attachmentData, isFromUser, message);
    }
  }

  Widget _buildProductAttachment(Map<String, dynamic> productData, bool isFromUser, ChatMessage message) {
    final isOrderAttachment = message.isOrderAttachment || 
                             message.message.toLowerCase().contains('order') ||
                             message.message.toLowerCase().contains('ordered');
    
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isOrderAttachment 
              ? Border.all(color: Colors.green.withOpacity(0.3), width: 2)
              : Border.all(color: themeColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Navigate to product details
            final product = StoreProduct(
              id: productData['id'] ?? '',
              name: productData['name'] ?? '',
              description: productData['description'] ?? '',
              price: productData['price']?.toDouble() ?? 0.0,
              currency: 'USD',
              imageUrls: productData['imageUrl'] != null ? [productData['imageUrl']!] : [],
              category: productData['category'] ?? '',
              rating: productData['rating']?.toDouble() ?? 0.0,
              totalOrders: productData['totalOrders'] ?? 0,
              isFreeShipping: false,
              shippingTime: '3-5 days',
              stockQuantity: 1,
              storeId: widget.otherUser.id,
              isActive: true,
              createdAt: DateTime.now(),
              lastUpdatedAt: DateTime.now(),
            );
            
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOrderAttachment 
                      ? Colors.green.withOpacity(0.1)
                      : themeColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOrderAttachment ? CupertinoIcons.cube_box : CupertinoIcons.bag,
                      color: isOrderAttachment ? Colors.green : themeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOrderAttachment ? 'ORDER CONFIRMATION' : 'PRODUCT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOrderAttachment ? Colors.green : themeColor,
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Product Image
              if (productData['imageUrl'] != null && productData['imageUrl']!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: productData['imageUrl']!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: Center(
                        child: CupertinoActivityIndicator(color: themeColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 40),
                    ),
                  ),
                ),
              
              // Product Info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData['name'] ?? 'Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: AppFonts.getTitleFontFamily(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CurrencySymbol(
                          size: 16,
                          color: themeColor,
                        ),
                        Text(
                          '${productData['price']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: themeColor,
                            fontFamily: AppFonts.getTitleFontFamily(context),
                          ),
                        ),
                        const Spacer(),
                        if (productData['rating'] != null && productData['rating'] > 0) ...[
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${productData['rating']?.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceAdAttachment(Map<String, dynamic> serviceAdData, bool isFromUser) {
    final serviceColor = serviceAdData['serviceType'] == 'training' ? Colors.blue : Colors.green;
    
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: serviceColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            // Navigate to service ad detail page
            final serviceAd = ServiceAd(
              id: serviceAdData['id'] ?? '',
              userId: widget.otherUser.id,
              userName: serviceAdData['userName'] ?? '',
              userProfileImage: serviceAdData['userProfileImage'] ?? '',
              serviceType: ServiceAdType.values.firstWhere(
                (e) => e.name == serviceAdData['serviceType'],
                orElse: () => ServiceAdType.training,
              ),
              serviceName: serviceAdData['serviceName'] ?? '',
              description: serviceAdData['description'] ?? '',
              imageUrl: serviceAdData['imageUrl'],
              availableDays: List<String>.from(serviceAdData['availableDays'] ?? []),
              startTime: serviceAdData['startTime'] ?? '',
              endTime: serviceAdData['endTime'] ?? '',
              petTypes: List<String>.from(serviceAdData['petTypes'] ?? []),
              locationAddress: serviceAdData['locationAddress'] ?? '',
              latitude: serviceAdData['latitude']?.toDouble() ?? 0.0,
              longitude: serviceAdData['longitude']?.toDouble() ?? 0.0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isActive: true,
              rating: serviceAdData['rating']?.toDouble() ?? 0.0,
              reviewCount: serviceAdData['reviewCount'] ?? 0,
            );
            
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ServiceAdDetailPage(serviceAd: serviceAd),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: serviceColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      serviceAdData['serviceType'] == 'training'
                          ? CupertinoIcons.person_2_alt
                          : CupertinoIcons.scissors_alt,
                      color: serviceColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${serviceAdData['serviceType']?.toString().toUpperCase()} SERVICE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: serviceColor,
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Service Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[100],
                        child: serviceAdData['imageUrl'] != null && serviceAdData['imageUrl']!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: serviceAdData['imageUrl']!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                              )
                            : Icon(
                                CupertinoIcons.photo,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Service Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceAdData['serviceName'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: AppFonts.getTitleFontFamily(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.location,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  serviceAdData['locationAddress'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${serviceAdData['startTime']} - ${serviceAdData['endTime']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderAttachment(Map<String, dynamic> orderData, bool isFromUser) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.cube_box,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ORDER CONFIRMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ],
              ),
            ),
            
            // Order Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${orderData['orderId'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: AppFonts.getTitleFontFamily(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (orderData['productName'] != null)
                    Text(
                      orderData['productName'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                      ),
                    ),
                  if (orderData['totalAmount'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Total: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: AppFonts.getLocalizedFontFamily(context),
                          ),
                        ),
                        CurrencySymbol(
                          size: 16,
                          color: Colors.green,
                        ),
                        Text(
                          '${orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                            fontFamily: AppFonts.getTitleFontFamily(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Attachment preview widgets (when waiting to be sent)
  Widget _buildProductAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.bag, color: themeColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sharing product',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeColor,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasProductAttachment = false;
                      _attachedProduct = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[100],
                    child: _attachedProduct!.imageUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _attachedProduct!.imageUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 16),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 16),
                            ),
                          )
                        : Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _attachedProduct!.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: AppFonts.getTitleFontFamily(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          CurrencySymbol(size: 12, color: Colors.grey[600]),
                          Text(
                            '${_attachedProduct!.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAdAttachmentPreview() {
    final serviceColor = _attachedServiceAd!.serviceType == ServiceAdType.training ? Colors.blue : Colors.green;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: serviceColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: serviceColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: serviceColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _attachedServiceAd!.serviceType == ServiceAdType.training
                      ? CupertinoIcons.person_2_alt
                      : CupertinoIcons.scissors_alt,
                  color: serviceColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sharing ${_attachedServiceAd!.serviceType.name} service',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: serviceColor,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasServiceAdAttachment = false;
                      _attachedServiceAd = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[100],
                    child: _attachedServiceAd!.imageUrl != null && _attachedServiceAd!.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: _attachedServiceAd!.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 16),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 16),
                            ),
                          )
                        : Icon(CupertinoIcons.photo, color: Colors.grey[400], size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _attachedServiceAd!.serviceName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: AppFonts.getTitleFontFamily(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _attachedServiceAd!.locationAddress,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: AppFonts.getLocalizedFontFamily(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.cube_box, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sharing order details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasOrderAttachment = false;
                      _attachedOrderData = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${_attachedOrderData!['orderId'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: AppFonts.getTitleFontFamily(context),
                  ),
                ),
                if (_attachedOrderData!['productName'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _attachedOrderData!['productName'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingScheduleSection() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    // Check if we should show minimized view
    if (_hasConfirmedMeeting() && !_isMeetingExpanded) {
      return _buildMinimizedMeetingView();
    }

    return _buildExpandedMeetingView(currentUser);
  }

  Widget _buildMinimizedMeetingView() {
    final confirmedMeeting = _getConfirmedMeeting();
    if (confirmedMeeting == null) return const SizedBox.shrink();

    final place = confirmedMeeting['place'] ?? '';
    final scheduledTime = (confirmedMeeting['scheduledTime'] as Timestamp?)?.toDate();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200,
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
        children: [
          // Meeting confirmed icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green.shade600,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Meeting details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meeting Confirmed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                if (scheduledTime != null)
                  Text(
                    '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year} at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (place.isNotEmpty)
                  Text(
                    place,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              // Mark as finished button
              GestureDetector(
                onTap: () => _showFinishMeetingDialog(confirmedMeeting['id']),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.checkmark,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Expand button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMeetingExpanded = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.plus,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedMeetingView(User currentUser) {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Max 70% of screen height
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.calendar,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Schedule Meeting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Mark as finished button (only show for confirmed meetings)
                        if (_hasConfirmedMeeting()) ...[
                          GestureDetector(
                            onTap: () {
                              final confirmedMeeting = _getConfirmedMeeting();
                              if (confirmedMeeting != null) {
                                _showFinishMeetingDialog(confirmedMeeting['id']);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_circle,
                                    color: Colors.green.shade600,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mark as Finished',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        
                        // Close/Minimize button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_hasConfirmedMeeting()) {
                                _isMeetingExpanded = false;
                              } else {
                                _shouldShowMeetingSchedule = false;
                              }
                            });
                          },
                          child: Icon(
                            _hasConfirmedMeeting() 
                                ? CupertinoIcons.minus_circle_fill
                                : CupertinoIcons.xmark_circle_fill,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Coordinate a meeting to reunite with your pet! 🐾',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Existing meetings and new meeting form
                  if (_meetings.isNotEmpty) ...[
                    ..._buildExistingMeetings(currentUser.id),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Propose New Meeting',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildNewMeetingForm(currentUser.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExistingMeetings(String currentUserId) {
    return _meetings.map((meeting) {
      final isProposer = meeting['proposerId'] == currentUserId;
      final status = meeting['status'] ?? 'proposed';
      final place = meeting['place'] ?? '';
      final scheduledTime = (meeting['scheduledTime'] as Timestamp?)?.toDate();
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: status == 'confirmed' 
                ? Colors.green.shade200 
                : status == 'rejected'
                    ? Colors.red.shade200
                    : Colors.blue.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting details
            Row(
              children: [
                Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.blue.shade600,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    place.isEmpty ? 'No location set' : place,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (scheduledTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year} at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            
            // Status and actions
            if (status == 'proposed' && !isProposer) ...[
              // Receiver can confirm or reject
              Row(
                children: [
                  Expanded(
                    child: _buildMeetingActionButton(
                      'Reject',
                      CupertinoIcons.xmark_circle,
                      Colors.red,
                      () => _rejectMeeting(meeting['id']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMeetingActionButton(
                      'Confirm',
                      CupertinoIcons.checkmark_circle_fill,
                      Colors.green,
                      () => _confirmMeeting(meeting['id']),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'proposed' && isProposer) ...[
              // Proposer waiting for response
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting for response...',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'confirmed') ...[
              // Meeting confirmed
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Meeting confirmed!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == 'rejected') ...[
              // Meeting rejected - can edit
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.xmark_circle,
                          color: Colors.red.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Meeting rejected',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildMeetingActionButton(
                      'Edit Details',
                      CupertinoIcons.pencil,
                      Colors.blue,
                      () => _startEditingMeeting(meeting['id']),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildNewMeetingForm(String currentUserId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Place input
        Text(
          'Meeting Place',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _placeController,
          decoration: InputDecoration(
            hintText: 'Enter meeting location...',
            prefixIcon: Icon(
              CupertinoIcons.location,
              color: Colors.blue.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Date/Time input
        Text(
          'Meeting Time',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateTime != null
                        ? '${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} at ${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select date and time...',
                    style: TextStyle(
                      color: _selectedDateTime != null 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: _editingMeetingId != null
              ? _buildMeetingActionButton(
                  'Update Meeting',
                  CupertinoIcons.pencil_circle_fill,
                  Colors.green,
                  _canProposeMeeting() ? _updateMeetingDetails : null,
                )
              : _hasActiveMeetingProposal(currentUserId)
                  ? _buildMeetingActionButton(
                      'Waiting for confirmation...',
                      CupertinoIcons.clock,
                      Colors.orange,
                      null, // Disabled when waiting
                    )
                  : _buildMeetingActionButton(
                      'Propose Meeting',
                      CupertinoIcons.calendar_badge_plus,
                      Colors.blue,
                      _canProposeMeeting() ? _proposeMeeting : null,
                    ),
        ),
      ],
    );
  }

  Widget _buildMeetingActionButton(String text, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: onTap != null ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: onTap != null ? Colors.white : Colors.grey.shade500,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: onTap != null ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button for users with missing pets or in discussion chats
            if (_userHasMissingPets || widget.chatType == ChatType.discussion) ...[
              GestureDetector(
                onTap: _showAttachmentOptions,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.camera_fill,
                    color: Colors.blue.shade600,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: KeyboardDismissibleTextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: themeColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style: TextStyle(
                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? CupertinoActivityIndicator(color: Colors.white)
                    : Icon(
                        CupertinoIcons.arrow_up,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showBookingDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingPage(
          vetUser: widget.otherUser,
        ),
      ),
    );
  }

  Widget _buildLostPetAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _hasLostPetAttachment = false;
                _attachedLostPet = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.red.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: _attachedLostPet!.pet.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _attachedLostPet!.pet.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets, color: Colors.grey[400]),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.pets, color: Colors.grey[400]),
                      ),
                    ),
                  )
                : Icon(Icons.pets, color: Colors.grey[400], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lost Pet: ${_attachedLostPet!.pet.name}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                Text(
                  '${_attachedLostPet!.pet.species} • ${_attachedLostPet!.pet.breed ?? 'Mixed breed'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (_attachedLostPet!.reward != null && _attachedLostPet!.reward! > 0)
                  Text(
                    'Reward: \$${_attachedLostPet!.reward!.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLostPetAttachment(Map<String, dynamic> lostPetData, bool isFromUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFromUser ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFromUser ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lost Pet Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: lostPetData['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: lostPetData['imageUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets, color: Colors.grey[400]),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.pets, color: Colors.grey[400]),
                          ),
                        ),
                      )
                    : Icon(Icons.pets, color: Colors.grey[400], size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lostPetData['petName'] ?? 'Unknown Pet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lostPetData['species'] ?? 'Pet'} • ${lostPetData['breed'] ?? 'Mixed breed'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (lostPetData['reward'] != null && lostPetData['reward'] > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${lostPetData['reward'].toStringAsFixed(0)} Reward',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Last seen: ${lostPetData['address'] ?? 'Unknown location'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (lostPetData['additionalInfo'] != null && lostPetData['additionalInfo'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lostPetData['additionalInfo'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }



  Widget _buildMediaAttachment(Map<String, dynamic> attachmentData, bool isFromUser, ChatMessage message) {
    final mediaFiles = List<Map<String, dynamic>>.from(attachmentData['mediaFiles'] ?? []);
    
    return Column(
      crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Media content with pet identification button
        Align(
          alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main media content
                Flexible(child: _buildMediaContent(mediaFiles)),
                
                // Pet identification heart button (only for received messages when user has lost pets)
                if (!isFromUser && _userHasMissingPets) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: _buildPetIdentificationIcon(message, mediaFiles),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Pet identification confirmation text
        if (message.petIdentification != null)
          _buildPetIdentificationConfirmation(message.petIdentification!, isFromUser),
      ],
    );
  }

  Widget _buildMediaContent(List<Map<String, dynamic>> mediaFiles) {
    if (mediaFiles.length == 1 && mediaFiles.first['type'] == 'video') {
      // Single video - use real aspect ratio
      return ChatVideoPlayer(
        videoUrl: mediaFiles.first['url'] ?? '',
        autoPlay: false,
        showControls: true,
        useRealAspectRatio: true,
      );
    } else if (mediaFiles.length == 1) {
      // Single image
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: mediaFiles.first['url'] ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey.shade300,
            child: Center(
              child: CupertinoActivityIndicator(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey.shade300,
            child: Center(
              child: Icon(
                CupertinoIcons.photo,
                color: Colors.grey.shade600,
                size: 48,
              ),
            ),
          ),
        ),
      );
    } else {
      // Multiple items - use grid
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: mediaFiles.length,
        itemBuilder: (context, index) {
          final media = mediaFiles[index];
          final isVideo = media['type'] == 'video';
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? ChatVideoPlayer(
                    videoUrl: media['url'] ?? '',
                    autoPlay: false,
                    showControls: true,
                    useRealAspectRatio: false, // Use fixed size in grid
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: media['url'] ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade300,
                          child: Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: Center(
                            child: Icon(
                              CupertinoIcons.photo,
                              color: Colors.grey.shade600,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      
                      // Media type indicator
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isVideo ? 'VIDEO' : 'PHOTO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
    }
  }

  Widget _buildPetIdentificationIcon(ChatMessage message, List<Map<String, dynamic>> mediaFiles) {
    // Don't show if already identified
    if (message.petIdentification != null) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('🐾 [PetIdentification] Heart button tapped!');
        _showPetIdentificationDialog(message, mediaFiles);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.heart_fill,
          color: Colors.red,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPetIdentificationConfirmation(Map<String, dynamic> petIdentification, bool isFromUser) {
    final confirmerName = petIdentification['confirmerName'] ?? 'Someone';
    final isConfirmed = petIdentification['isConfirmed'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConfirmed ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConfirmed ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
            size: 16,
            color: isConfirmed ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isConfirmed 
                  ? '$confirmerName has confirmed that this is their pet'
                  : '$confirmerName has confirmed that this is not their pet',
              style: TextStyle(
                fontSize: 12,
                color: isConfirmed ? Colors.green.shade700 : Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPetIdentificationDialog(ChatMessage message, List<Map<String, dynamic>> mediaFiles) {
    final mediaType = mediaFiles.first['type'] == 'video' ? 'video' : 'picture';
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      print('❌ [PetIdentification] No current user available');
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Pet Identification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Content
                Text(
                  'Is this $mediaType of your missing pet?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // No Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmPetIdentification(message, false, currentUser.displayName ?? 'Someone');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.xmark_circle,
                                color: Colors.red.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Yes Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmPetIdentification(message, true, currentUser.displayName ?? 'Someone');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Yes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPetIdentification(ChatMessage message, bool isConfirmed, String confirmerName) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      final petIdentificationData = {
        'isConfirmed': isConfirmed,
        'confirmerName': confirmerName,
        'confirmerId': currentUser?.id,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await DatabaseService().updateChatMessagePetIdentification(message.id, petIdentificationData);
      
      // Show a brief confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConfirmed 
                ? 'Confirmed: This is your pet' 
                : 'Confirmed: This is not your pet',
          ),
          backgroundColor: isConfirmed ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // If confirmed as their pet, trigger meeting scheduling
      if (isConfirmed) {
        setState(() {
          _shouldShowMeetingSchedule = true;
        });
      }
    } catch (e) {
      print('❌ Error updating pet identification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save identification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMediaAttachmentPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isUploadingMedia 
                    ? CupertinoIcons.cloud_upload 
                    : CupertinoIcons.photo_on_rectangle,
                color: Colors.blue.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isUploadingMedia 
                    ? 'Uploading... ($_uploadProgress/$_totalUploads)'
                    : 'Media Attachments (${_attachedMedia.length})',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasMediaAttachment = false;
                    _attachedMedia.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.xmark,
                    size: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar when uploading
          if (_isUploadingMedia) ...[
            LinearProgressIndicator(
              value: _totalUploads > 0 ? _uploadProgress / _totalUploads : 0,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 8),
          ],
          
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachedMedia.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final media = _attachedMedia[index];
                final isVideo = media['type'] == 'video';
                
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isVideo
                            ? Stack(
                                children: [
                                  Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.videocam_fill,
                                        color: Colors.grey.shade600,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'VIDEO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Image.file(
                                File(media['path']),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.photo,
                                        color: Colors.grey.shade600,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removeMediaAttachment(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
