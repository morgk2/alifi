import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DebugService {
  static final DebugService _instance = DebugService._internal();
  factory DebugService() => _instance;
  DebugService._internal();

  final List<String> _logs = [];
  final StreamController<String> _logController = StreamController<String>.broadcast();
  bool _isInitialized = false;

  Stream<String> get logStream => _logController.stream;
  List<String> get logs => List.unmodifiable(_logs);

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _addLog('🔍 [DebugService] Initializing debug service...');
    
    try {
      // Set up error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _addLog('🔍 [DebugService] Flutter error caught: ${details.exception}');
        _addLog('🔍 [DebugService] Stack trace: ${details.stack}');
        _addLog('🔍 [DebugService] Library: ${details.library}');
        _addLog('🔍 [DebugService] Context: ${details.context}');
      };

      // Set up platform channel for iOS debugging
      const platform = MethodChannel('debug_channel');
      platform.setMethodCallHandler((call) async {
        _addLog('🔍 [DebugService] Platform call: ${call.method}');
        _addLog('🔍 [DebugService] Arguments: ${call.arguments}');
        return null;
      });

      // Add system info
      _addLog('🔍 [DebugService] Platform: ${Platform.operatingSystem}');
      _addLog('🔍 [DebugService] OS version: ${Platform.operatingSystemVersion}');
      _addLog('🔍 [DebugService] Local hostname: ${Platform.localHostname}');
      _addLog('🔍 [DebugService] Number of processors: ${Platform.numberOfProcessors}');
      
      if (Platform.isIOS) {
        _addLog('🔍 [DebugService] iOS specific info:');
        _addLog('🔍 [DebugService] - iOS version: ${Platform.operatingSystemVersion}');
        _addLog('🔍 [DebugService] - Device: ${Platform.localHostname}');
      }

      _isInitialized = true;
      _addLog('🔍 [DebugService] Debug service initialized successfully');
    } catch (e, stackTrace) {
      _addLog('🔍 [DebugService] Error initializing debug service: $e');
      _addLog('🔍 [DebugService] Stack trace: $stackTrace');
    }
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().split('.')[0];
    final logEntry = '[$timestamp] $message';
    
    _logs.add(logEntry);
    _logController.add(logEntry);
    
    // Keep only last 200 logs
    if (_logs.length > 200) {
      _logs.removeAt(0);
    }
    
    print(logEntry);
  }

  void addLog(String message) {
    _addLog('🔍 [DebugService] $message');
  }

  void addError(String error, [StackTrace? stackTrace]) {
    _addLog('🔍 [DebugService] ERROR: $error');
    if (stackTrace != null) {
      _addLog('🔍 [DebugService] Stack trace: $stackTrace');
    }
  }

  void addWarning(String warning) {
    _addLog('🔍 [DebugService] WARNING: $warning');
  }

  void addInfo(String info) {
    _addLog('🔍 [DebugService] INFO: $info');
  }

  void clearLogs() {
    _logs.clear();
    _addLog('🔍 [DebugService] Logs cleared');
  }

  String getLogsAsString() {
    return _logs.join('\n');
  }

  void dispose() {
    _logController.close();
  }
} 