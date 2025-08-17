import 'package:flutter/material.dart';
import '../models/fundraising.dart';
import '../pages/contribute_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_fonts.dart';

class FundraisingCard extends StatelessWidget {
  final Fundraising fundraising;

  const FundraisingCard({
    super.key,
    required this.fundraising,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = ((fundraising.currentAmount / fundraising.goalAmount) * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and description
            Text(
              fundraising.title,
              style: TextStyle(
                fontFamily: context.titleFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fundraising.description,
              style: TextStyle(
                fontFamily: context.localizedFont,
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 24),
            
            // Progress section with iOS-style circular indicator
            Row(
              children: [
                // Left side - Amount info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                                                  Text(
                          _formatAmountDZD(fundraising.currentAmount),
                          style: TextStyle(
                            fontFamily: context.localizedFont,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4CAF50),
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
                        'raised',
                        style: TextStyle(
                          fontFamily: context.localizedFont,
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Linear progress bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (fundraising.currentAmount / fundraising.goalAmount).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Right side - iOS-style circular progress
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      // Background circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 2,
                          ),
                        ),
                      ),
                      // Progress circle
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: (fundraising.currentAmount / fundraising.goalAmount).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      // Percentage text
                      Center(
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Large engaging contribute button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ContributePage(fundraising: fundraising),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                                                    Text(
                              l10n.contribute,
                              style: TextStyle(
                                fontFamily: context.localizedFont,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatAmountDZD(double amount) {
    // Convert to DZD (assuming the amount is in USD, 1 USD ≈ 134 DZD as of recent rates)
    // You can adjust this conversion rate as needed
    double dzdAmount = amount * 134;
    
    if (dzdAmount >= 1000000) {
      return '${(dzdAmount / 1000000).toStringAsFixed(1)}M';
    } else if (dzdAmount >= 1000) {
      return '${(dzdAmount / 1000).toStringAsFixed(0)}K';
    } else {
      return dzdAmount.toStringAsFixed(0);
    }
  }
}
