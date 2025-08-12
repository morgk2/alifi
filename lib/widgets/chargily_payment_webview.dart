import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ChargilyPaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  final String backUrl;
  final Function(String status) onPaymentComplete;
  final Function(String error) onPaymentError;

  const ChargilyPaymentWebView({
    super.key,
    required this.checkoutUrl,
    required this.backUrl,
    required this.onPaymentComplete,
    required this.onPaymentError,
  });

  @override
  State<ChargilyPaymentWebView> createState() => _ChargilyPaymentWebViewState();
}

class _ChargilyPaymentWebViewState extends State<ChargilyPaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // For web platform, launch URL directly
    if (kIsWeb) {
      _launchWebUrl();
      return;
    }
    
    // For mobile platforms, use WebView
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar based on WebView loading progress
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check if payment is completed
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle navigation to external apps (like banking apps)
            if (request.url.startsWith('tel:') || 
                request.url.startsWith('mailto:') ||
                request.url.contains('banking') ||
                request.url.contains('cib') ||
                request.url.contains('sb')) {
              _launchExternalUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            // Check if this is a return URL
            if (request.url.contains(widget.backUrl) || 
                request.url.contains('success') ||
                request.url.contains('cancel') ||
                request.url.contains('error')) {
              _handleReturnUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<void> _launchWebUrl() async {
    try {
      if (await canLaunchUrl(Uri.parse(widget.checkoutUrl))) {
        await launchUrl(
          Uri.parse(widget.checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
        // For web, we can't track the payment status, so we'll assume it's pending
        widget.onPaymentComplete('pending');
      } else {
        widget.onPaymentError('Could not launch payment URL');
      }
    } catch (e) {
      widget.onPaymentError('Error launching payment: $e');
    }
  }

  void _checkPaymentStatus(String url) {
    if (url.contains('success')) {
      widget.onPaymentComplete('success');
    } else if (url.contains('cancel')) {
      widget.onPaymentComplete('cancelled');
    } else if (url.contains('error')) {
      widget.onPaymentError('Payment failed');
    }
  }

  void _handleReturnUrl(String url) {
    if (url.contains('success')) {
      widget.onPaymentComplete('success');
    } else if (url.contains('cancel')) {
      widget.onPaymentComplete('cancelled');
    } else if (url.contains('error')) {
      widget.onPaymentError('Payment failed');
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    // For web platform, show a simple message
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              widget.onPaymentComplete('cancelled');
            },
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Payment URL opened in new tab',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please complete your payment in the new tab',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // For mobile platforms, show WebView
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            widget.onPaymentComplete('cancelled');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
