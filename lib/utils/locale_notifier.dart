import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale;
  LocaleNotifier(this._locale);

  Locale get locale => _locale;

  void changeLocale(Locale locale) {
    if (_locale != locale) {
      print('Locale changed from ${_locale.languageCode} to ${locale.languageCode}');
      _locale = locale;
      notifyListeners();
    }
  }

  static _LocaleNotifierProviderState? of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_LocaleNotifierProvider>();
    return provider?.data;
  }
}

class LocaleNotifierProvider extends StatefulWidget {
  final Widget child;
  final Locale initialLocale;
  const LocaleNotifierProvider({Key? key, required this.child, required this.initialLocale}) : super(key: key);

  @override
  _LocaleNotifierProviderState createState() => _LocaleNotifierProviderState();
}

class _LocaleNotifierProviderState extends State<LocaleNotifierProvider> {
  late LocaleNotifier localeNotifier;

  @override
  void initState() {
    super.initState();
    localeNotifier = LocaleNotifier(widget.initialLocale);
    // Listen to changes in the LocaleNotifier
    localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    localeNotifier.removeListener(_onLocaleChanged);
    localeNotifier.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    // Trigger rebuild when locale changes
    setState(() {});
  }

  void changeLocale(Locale locale) {
    localeNotifier.changeLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return _LocaleNotifierProvider(
      data: this,
      child: widget.child,
    );
  }
}

class _LocaleNotifierProvider extends InheritedWidget {
  final _LocaleNotifierProviderState data;
  const _LocaleNotifierProvider({required Widget child, required this.data}) : super(child: child);

  @override
  bool updateShouldNotify(_LocaleNotifierProvider oldWidget) => true;
} 