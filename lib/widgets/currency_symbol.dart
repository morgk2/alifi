import 'package:flutter/material.dart';

class CurrencySymbol extends StatelessWidget {
  final double size;
  final Color? color;
  final String symbol;

  const CurrencySymbol({
    super.key,
    this.size = 20,
    this.color,
    this.symbol = 'dzd_symbol.png',
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$symbol',
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
} 