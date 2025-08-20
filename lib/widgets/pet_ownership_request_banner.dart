import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/pet_ownership_request.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class PetOwnershipRequestBanner extends StatelessWidget {
  final VoidCallback? onRequestAccepted;
  
  const PetOwnershipRequestBanner({
    Key? key,
    this.onRequestAccepted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = context.read<AuthService>();
    final currentUser = authService.currentUser;
    
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<List<PetOwnershipRequest>>(
      stream: DatabaseService().getUserOwnershipRequests(currentUser.id),
      builder: (context, snapshot) {
        print('🔍 [PetOwnershipRequestBanner] Stream state: ${snapshot.connectionState}');
        print('🔍 [PetOwnershipRequestBanner] Has data: ${snapshot.hasData}');
        print('🔍 [PetOwnershipRequestBanner] Has error: ${snapshot.hasError}');
        print('🔍 [PetOwnershipRequestBanner] Data length: ${snapshot.data?.length ?? 0}');
        
        if (snapshot.hasError) {
          print('❌ [PetOwnershipRequestBanner] Stream error: ${snapshot.error}');
          print('❌ [PetOwnershipRequestBanner] Stack trace: ${snapshot.stackTrace}');
          return const SizedBox.shrink();
        }
        
        // Show loading indicator while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          print('🔍 [PetOwnershipRequestBanner] Waiting for data...');
          return const SizedBox.shrink(); // Don't show anything while loading
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('🔍 [PetOwnershipRequestBanner] No requests to show - hasData: ${snapshot.hasData}, isEmpty: ${snapshot.data?.isEmpty}');
          return const SizedBox.shrink();
        }

        final requests = snapshot.data!;
        print('🔍 [PetOwnershipRequestBanner] Showing ${requests.length} requests');
        
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.orange.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.petOwnershipRequests,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.pendingRequests(requests.length),
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Request List
              ...requests.take(3).map((request) => _buildRequestItem(context, request)),
              
              if (requests.length > 3)
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.moreRequests(requests.length - 3),
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestItem(BuildContext context, PetOwnershipRequest request) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Pet Photo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: request.petPhotoUrl != null
                  ? Image.network(
                      request.petPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.pets, color: Colors.orange.shade600, size: 20),
                    )
                  : Icon(Icons.pets, color: Colors.orange.shade600, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          
          // Request Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wantsToCoOwn(request.fromUserName, request.petName),
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${request.petBreed} • ${request.petAge.toStringAsFixed(1)} years old',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context,
                icon: Icons.check,
                color: Colors.green,
                onTap: () => _respondToRequest(context, request, 'accepted'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                context,
                icon: Icons.close,
                color: Colors.red,
                onTap: () => _respondToRequest(context, request, 'rejected'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _respondToRequest(
    BuildContext context,
    PetOwnershipRequest request,
    String response,
  ) async {
    try {
      await DatabaseService().respondToPetOwnershipRequest(request.id, response);
      
      // If request was accepted, trigger refresh callback
      if (response == 'accepted' && onRequestAccepted != null) {
        onRequestAccepted!();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response == 'accepted' 
                ? 'Request accepted! ${request.fromUserName} is now a co-owner of ${request.petName}'
                : 'Request declined'),
            backgroundColor: response == 'accepted' ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error responding to request: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error responding to request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
