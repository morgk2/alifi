import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/navigation_service.dart';
import '../services/database_service.dart';
import '../utils/app_fonts.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  State<SubscriptionManagementPage> createState() => _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState extends State<SubscriptionManagementPage> {
  Map<String, dynamic>? _subscriptionData;
  bool _isLoading = true;

  List<String> get _features {
    if (_subscriptionData == null) return [];
    
    final plan = _subscriptionData!['plan'] as String?;
    if (plan == null) return [];
    
    final planDetails = DatabaseService().getSubscriptionPlanDetails(plan);
    return List<String>.from(planDetails['features'] ?? []);
  }

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    if (user == null) return;

    try {
      final subscription = await DatabaseService().getSubscription(user.id);
      if (mounted) {
        setState(() {
          _subscriptionData = subscription;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading subscription data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    
    if (user == null || (user.accountType != 'vet' && user.accountType != 'store')) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Subscription'),
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
        ),
        body: const Center(
          child: Text('This page is only available for vet and store accounts.'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Subscription Management',
            style: TextStyle(fontFamily: context.titleFont,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
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
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Subscription Management',
          style: TextStyle(fontFamily: context.titleFont,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Current Plan Card
              _buildCurrentPlanCard(),
              
              const SizedBox(height: 24),
              
              // Payment Method Card
              _buildPaymentMethodCard(),
              
              const SizedBox(height: 24),
              
              // Plan Details Card
              _buildPlanDetailsCard(),
              
              const SizedBox(height: 24),
              
              // Change Plan Button
              _buildChangePlanButton(),
              
              const SizedBox(height: 24),
              
              // Cancel Subscription Button
              _buildCancelSubscriptionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                             Text(
                         _subscriptionData?['plan'] ?? 'No Subscription',
                         style: const TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.w700,
                           fontFamily: 'InterDisplay',
                         ),
                       ),
                      const SizedBox(height: 4),
                                             Text(
                         _subscriptionData?['status'] == 'active' ? 'Active Subscription' : 'Inactive Subscription',
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.grey[600],
                           fontFamily: 'InterDisplay',
                         ),
                       ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                                     child: Text(
                     _subscriptionData?['status'] == 'active' ? 'Active' : 'Inactive',
                     style: TextStyle(
                       fontSize: 12,
                       fontWeight: FontWeight.w600,
                       color: _subscriptionData?['status'] == 'active' ? Colors.green[700] : Colors.red[700],
                       fontFamily: 'InterDisplay',
                     ),
                   ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Billing Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Billing',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'InterDisplay',
                        ),
                      ),
                      const SizedBox(height: 4),
                                             Text(
                         _subscriptionData?['nextBillingDate'] != null 
                           ? _formatDate(_subscriptionData!['nextBillingDate'])
                           : 'No billing date',
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                           fontFamily: 'InterDisplay',
                         ),
                       ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'InterDisplay',
                        ),
                      ),
                      const SizedBox(height: 4),
                                                                                           Text(
                          _subscriptionData?['amount'] != null 
                            ? '${_subscriptionData!['amount']} ${_subscriptionData!['currency']}/${_subscriptionData!['interval']}'
                            : 'No amount',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'InterDisplay',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'InterDisplay',
                        ),
                      ),
                      const SizedBox(height: 4),
                                             Text(
                         _subscriptionData?['paymentMethod'] ?? 'No payment method',
                         style: TextStyle(
                           fontSize: 14,
                           color: Colors.grey[600],
                           fontFamily: 'InterDisplay',
                         ),
                       ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showUpdatePaymentMethodDialog();
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Plan Features',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'InterDisplay',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
                         ..._features.map((feature) =>  
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'InterDisplay',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePlanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showChangePlanDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Change Plan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'InterDisplay',
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSubscriptionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _showCancelSubscriptionDialog();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[600],
          side: BorderSide(color: Colors.red[300]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Cancel Subscription',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'InterDisplay',
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUpdatePaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Method'),
        content: const Text('This feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePlanDialog() {
    final availablePlans = DatabaseService().getAvailableSubscriptionPlans();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Plan'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: availablePlans.map((plan) {
              final isCurrentPlan = _subscriptionData?['plan'] == plan['name'];
              return ListTile(
                title: Text(plan['name']),
                subtitle: Text('${plan['price']} ${plan['currency']}/${plan['interval']}'),
                trailing: isCurrentPlan ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  Navigator.pop(context);
                  await _changeSubscriptionPlan(plan['name']);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeSubscriptionPlan(String newPlan) async {
    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;
      
      if (user == null) return;

      final planDetails = DatabaseService().getSubscriptionPlanDetails(newPlan);
      
      await DatabaseService().createOrUpdateSubscription(
        userId: user.id,
        plan: newPlan,
        status: 'active',
        amount: planDetails['price'],
        currency: planDetails['currency'],
        interval: planDetails['interval'],
        paymentMethod: _subscriptionData?['paymentMethod'] ?? 'Cash payment',
        startDate: DateTime.now(),
        nextBillingDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Reload subscription data
      await _loadSubscriptionData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan changed to $newPlan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error changing subscription plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing plan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription? You will lose access to premium features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelSubscription();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSubscription() async {
    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;
      
      if (user == null) return;

      await DatabaseService().cancelSubscription(user.id);
      
      // Reload subscription data
      await _loadSubscriptionData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling subscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 