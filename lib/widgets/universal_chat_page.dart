import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/chat_message.dart';
import '../models/store_product.dart';
import '../models/service_ad.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/app_fonts.dart';
import '../widgets/keyboard_dismissible_text_field.dart';
import '../widgets/currency_symbol.dart';
import '../pages/service_ad_detail_page.dart';
import '../pages/product_details_page.dart';

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

  const UniversalChatPage({
    super.key,
    required this.otherUser,
    required this.chatType,
    this.subtitle,
    this.themeColor,
    this.initialProduct,
    this.initialServiceAd,
    this.initialOrderData,
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
  
  StoreProduct? _attachedProduct;
  ServiceAd? _attachedServiceAd;
  Map<String, dynamic>? _attachedOrderData;

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
    _loadMessages();
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
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
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

  Future<void> _sendMessage() async {
    final hasText = _messageController.text.trim().isNotEmpty;
    final hasAnyAttachment = _hasProductAttachment || _hasServiceAdAttachment || _hasOrderAttachment;
    
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
        }
        
        // Default message for attachments without text
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
                        _buildMessage(
                          isFromUser: isFromUser,
                          message: message.message,
                          timestamp: message.timestamp,
                        ),
                        if (message.productAttachment != null) ...[
                          const SizedBox(height: 8),
                          _buildUniversalAttachment(message.productAttachment!, isFromUser, message),
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
            if (_hasOrderAttachment && _attachedOrderData != null)
              _buildOrderAttachmentPreview(),
            
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
          ClipRRect(
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
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
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

  Widget _buildMessage({
    required bool isFromUser,
    required String message,
    required DateTime timestamp,
  }) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
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
    );
  }

  Widget _buildUniversalAttachment(Map<String, dynamic> attachmentData, bool isFromUser, ChatMessage message) {
    final attachmentType = attachmentData['type'] ?? 'product';
    
    switch (attachmentType) {
      case 'serviceAd':
        return _buildServiceAdAttachment(attachmentData, isFromUser);
      case 'order':
        return _buildOrderAttachment(attachmentData, isFromUser);
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
}
