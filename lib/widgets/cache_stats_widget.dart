import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/comprehensive_cache_service.dart';

/// Widget to display cache statistics (debug only)
class CacheStatsWidget extends StatefulWidget {
  final bool showDetails;

  const CacheStatsWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  State<CacheStatsWidget> createState() => _CacheStatsWidgetState();
}

class _CacheStatsWidgetState extends State<CacheStatsWidget> {
  final ComprehensiveCacheService _cacheService = ComprehensiveCacheService();
  Map<String, dynamic> _stats = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateStats();
    // Update stats every 5 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _updateStats();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateStats() {
    if (mounted) {
      setState(() {
        _stats = _cacheService.getCacheStats();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storage,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Cache Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  _cacheService.clearAllCache();
                  _updateStats();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.clear_all,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hit Rate: ${_stats['hitRate'] ?? '0.00'}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          Text(
            'Memory: ${_stats['memoryCacheSize'] ?? 0} items',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          if (widget.showDetails) ...[
            Text(
              'Hits: ${_stats['cacheHits'] ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            Text(
              'Misses: ${_stats['cacheMisses'] ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            Text(
              'Total: ${_stats['totalRequests'] ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            Text(
              'Disk: ${_formatBytes(_stats['diskCacheSize'] ?? 0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
