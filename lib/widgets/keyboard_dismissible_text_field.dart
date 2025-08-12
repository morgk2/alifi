import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardDismissibleTextField extends StatefulWidget {
  final TextEditingController controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final bool filled;
  final Color? fillColor;
  final double? width;
  final double? height;
  final BoxDecoration? containerDecoration;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const KeyboardDismissibleTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.style,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.validator,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.hintStyle,
    this.contentPadding,
    this.border,
    this.filled = false,
    this.fillColor,
    this.width,
    this.height,
    this.containerDecoration,
    this.margin,
    this.padding,
  });

  @override
  State<KeyboardDismissibleTextField> createState() => _KeyboardDismissibleTextFieldState();
}

class _KeyboardDismissibleTextFieldState extends State<KeyboardDismissibleTextField> {
  late FocusNode _focusNode;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    final isVisible = _focusNode.hasFocus;
    if (isVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isVisible;
      });
    }
  }

  void _dismissKeyboard() {
    _focusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Check if swipe is downward and keyboard is visible
        if (details.primaryVelocity != null && 
            details.primaryVelocity! > 0 && 
            _isKeyboardVisible) {
          _dismissKeyboard();
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        padding: widget.padding,
        decoration: widget.containerDecoration,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          style: widget.style,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          decoration: widget.decoration ?? InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.hintStyle,
            contentPadding: widget.contentPadding,
            border: widget.border,
            filled: widget.filled,
            fillColor: widget.fillColor,
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
          ),
        ),
      ),
    );
  }
}

// Extension to easily convert existing TextField to KeyboardDismissibleTextField
extension TextFieldExtension on TextField {
  Widget withKeyboardDismissal({
    double? width,
    double? height,
    BoxDecoration? containerDecoration,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return KeyboardDismissibleTextField(
      controller: controller!,
      decoration: decoration,
      style: style,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      obscureText: obscureText ?? false,
      enabled: enabled ?? true,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      focusNode: focusNode,
      autofocus: autofocus ?? false,
      readOnly: readOnly ?? false,
      inputFormatters: inputFormatters,
      width: width,
      height: height,
      containerDecoration: containerDecoration,
      margin: margin,
      padding: padding,
    );
  }
}
