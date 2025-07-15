import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../models/fundraising.dart';

class ContributePage extends StatefulWidget {
  final Fundraising fundraising;

  const ContributePage({
    super.key,
    required this.fundraising,
  });

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  double? _customAmount;
  double _selectedAmount = 200; // Default selected amount

  @override
  Widget build(BuildContext context) {
    final double progress = widget.fundraising.currentAmount / widget.fundraising.goalAmount;
    final int percentage = (progress * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '+ Contribute',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'We\'ve raised ${widget.fundraising.currentAmount.toStringAsFixed(2)} DZD!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.fundraising.currentAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.fundraising.goalAmount.toStringAsFixed(2)} Goal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Circular progress indicator
              Center(
                child: CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 8.0,
                  percent: progress,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const Text(
                        '5',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  progressColor: const Color(0xFF4CAF50),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Contribute with :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Amount buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildAmountButton(200),
                  _buildAmountButton(500),
                  _buildAmountButton(1000),
                  _buildAmountButton(10000),
                  _buildCustomAmountButton(),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Pay via :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Payment method buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPaymentMethodButton('CIB'),
                  _buildPaymentMethodButton('SB'),
                  _buildPaymentMethodButton('PayPal'),
                  _buildPaymentMethodButton('stripe'),
                ],
              ),
              const SizedBox(height: 12),
              // Credit card logos
              Center(
                child: Image.asset(
                  'assets/images/visa_mastercard.png',
                  height: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountButton(double amount) {
    final bool isSelected = _selectedAmount == amount && _customAmount == null;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = amount;
          _customAmount = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          amount.toStringAsFixed(0),
          style: TextStyle(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAmountButton() {
    final bool isSelected = _customAmount != null;
    
    return GestureDetector(
      onTap: () {
        // Show custom amount input dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enter custom amount'),
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter amount in DZD',
              ),
              onChanged: (value) {
                setState(() {
                  _customAmount = double.tryParse(value);
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedAmount = _customAmount ?? _selectedAmount;
                  });
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          'Custom',
          style: TextStyle(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Image.asset(
        'assets/images/${method.toLowerCase()}_logo.png',
        height: 24,
      ),
    );
  }
} 