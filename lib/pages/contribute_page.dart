import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/fundraising.dart';
import '../utils/app_fonts.dart';

class ContributePage extends StatefulWidget {
  final Fundraising fundraising;

  const ContributePage({
    super.key,
    required this.fundraising,
  });

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> with TickerProviderStateMixin {
  double _selectedAmount = 500; // Default selected amount in DZD
  bool _isCustomAmount = false; // Track if custom amount is selected
  String _selectedPaymentMethod = 'CIB'; // Default to CIB
  final TextEditingController _customAmountController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  String _formatAmountDZD(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Widget _buildCustomAmountCard() {
    final bool isSelected = _isCustomAmount;
    
    return GestureDetector(
      onTap: _showCustomAmountSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              isSelected ? _selectedAmount.toInt().toString() : 'Custom',
              style: TextStyle(
                fontFamily: AppFonts.getLocalizedFontFamily(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                decoration: TextDecoration.none,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(double amount) {
    final bool isSelected = _selectedAmount == amount && !_isCustomAmount;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _isCustomAmount = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  amount.toInt().toString(),
                  style: TextStyle(
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String method, String displayName, String logoAsset) {
    final bool isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[200]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(
              logoAsset,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: TextStyle(
                fontFamily: AppFonts.getLocalizedFontFamily(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[800],
                decoration: TextDecoration.none,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Selected',
                  style: TextStyle(
                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCustomAmountSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Enter Custom Amount',
                style: TextStyle(
                  fontFamily: AppFonts.getTitleFontFamily(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CupertinoTextField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                placeholder: 'Minimum 300',
                style: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppFonts.getLocalizedFontFamily(context),
                          color: const Color(0xFF4CAF50),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoButton(
                      color: const Color(0xFF4CAF50),
                      onPressed: () {
                        final amount = double.tryParse(_customAmountController.text);
                        if (amount != null && amount >= 300) {
                          setState(() {
                            _selectedAmount = amount;
                            _isCustomAmount = true;
                          });
                          Navigator.pop(context);
                        } else {
                          // Show error for amounts less than 300
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text(
                                'Invalid Amount',
                                style: TextStyle(
                                  fontFamily: AppFonts.getTitleFontFamily(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              content: Text(
                                'Minimum amount is 300',
                                style: TextStyle(
                                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: AppFonts.getLocalizedFontFamily(context),
                          color: Colors.white,
                          decoration: TextDecoration.none,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.fundraising.currentAmount / widget.fundraising.goalAmount;
    final int percentage = (progress * 100).round();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFF8F9FA),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: Color(0xFF4CAF50),
            size: 28,
          ),
        ),
        middle: Text(
          'Contribute',
          style: TextStyle(
            fontFamily: AppFonts.getTitleFontFamily(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fundraising info card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Text(
                        widget.fundraising.title,
                        style: TextStyle(
                          fontFamily: AppFonts.getTitleFontFamily(context),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.fundraising.description,
                        style: TextStyle(
                          fontFamily: AppFonts.getLocalizedFontFamily(context),
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Progress section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_formatAmountDZD(widget.fundraising.currentAmount * 134)}',
                                      style: TextStyle(
                                        fontFamily: AppFonts.getLocalizedFontFamily(context),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4CAF50),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Image.asset(
                                      'assets/images/dzd_symbol.png',
                                      width: 24,
                                      height: 24,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'raised of ${_formatAmountDZD(widget.fundraising.goalAmount * 134)} DZD goal',
                                  style: TextStyle(
                                    fontFamily: AppFonts.getLocalizedFontFamily(context),
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress.clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // iOS-style circular progress
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[100],
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    strokeWidth: 6,
                                    backgroundColor: Colors.transparent,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      fontFamily: AppFonts.getLocalizedFontFamily(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4CAF50),
                                      decoration: TextDecoration.none,
                                    ),
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

                const SizedBox(height: 32),

                // Amount selection
                Text(
                  'Choose Amount',
                  style: TextStyle(
                    fontFamily: AppFonts.getTitleFontFamily(context),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildAmountCard(300),
                    _buildAmountCard(500),
                    _buildAmountCard(1000),
                    _buildAmountCard(2000),
                    _buildAmountCard(10000),
                    _buildCustomAmountCard(),
                  ],
                ),

                const SizedBox(height: 32),

                // Payment methods
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontFamily: AppFonts.getTitleFontFamily(context),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'CIB',
                        'CIB Bank',
                        'assets/images/cib_logo.png',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPaymentMethodCard(
                        'EDAHABIA',
                        'EDAHABIA',
                        'assets/images/sb_logo.png', // Using SB logo as placeholder for EDAHABIA
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Contribute button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Handle contribution
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                                                      title: Text(
                            'Contribute',
                            style: TextStyle(
                              fontFamily: AppFonts.getTitleFontFamily(context),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          content: Text(
                            'Contributing ${_selectedAmount.toInt()} via $_selectedPaymentMethod',
                            style: TextStyle(
                              fontFamily: AppFonts.getLocalizedFontFamily(context),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontFamily: AppFonts.getLocalizedFontFamily(context),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Contribute ${_selectedAmount.toInt()}',
                          style: TextStyle(
                            fontFamily: AppFonts.getLocalizedFontFamily(context),
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 