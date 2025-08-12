import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testPaymentRecord() async {
  final supabase = Supabase.instance.client;
  
  try {
    // Test inserting a payment record
    final testPaymentId = 'test_payment_${DateTime.now().millisecondsSinceEpoch}';
    
    final response = await supabase
        .from('chargily_payments')
        .insert({
          'payment_id': testPaymentId,
          'status': 'paid',
          'payment_status': 'paid',
          'payment_amount': 12220,
          'payment_currency': 'dzd',
          'payment_date': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'webhook_data': {
            'test': true,
            'payment_id': testPaymentId,
            'status': 'paid'
          }
        })
        .select();
    
    print('Test payment inserted successfully: $response');
    
    // Now try to read it back
    final readResponse = await supabase
        .from('chargily_payments')
        .select()
        .eq('payment_id', testPaymentId)
        .single();
    
    print('Test payment read successfully: $readResponse');
    
  } catch (e) {
    print('Exception in test: $e');
  }
}
