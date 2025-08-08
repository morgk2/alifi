import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import 'currency_symbol.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCurrencyButton(
                context,
                currencyService,
                Currency.USD,
                'USD',
                '\$',
              ),
              _buildCurrencyButton(
                context,
                currencyService,
                Currency.DZD,
                'DZD',
                'DZD',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyButton(
    BuildContext context,
    CurrencyService currencyService,
    Currency currency,
    String label,
    String symbol,
  ) {
    final isSelected = currencyService.currentCurrency == currency;
    
    return GestureDetector(
      onTap: () => currencyService.changeCurrency(currency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            symbol == 'DZD' 
              ? CurrencySymbol(
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey[700],
                )
              : Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 