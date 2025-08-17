import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class SocialMediaDialog extends StatefulWidget {
  final String platform;
  final String? currentUsername;
  final Function(String username) onSave;
  final VoidCallback? onRemove;

  const SocialMediaDialog({
    super.key,
    required this.platform,
    this.currentUsername,
    required this.onSave,
    this.onRemove,
  });

  @override
  State<SocialMediaDialog> createState() => _SocialMediaDialogState();
}

class _SocialMediaDialogState extends State<SocialMediaDialog> {
  late TextEditingController _usernameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return '🎵';
      case 'facebook':
        return '📘';
      case 'instagram':
        return '📷';
      default:
        return '🔗';
    }
  }

  String _getHintText(String platform) {
    final l10n = AppLocalizations.of(context)!;
    switch (platform.toLowerCase()) {
      case 'tiktok':
        return 'Enter TikTok username';
      case 'facebook':
        return 'Enter Facebook username';
      case 'instagram':
        return 'Enter Instagram username';
      default:
        return l10n.enterUsername;
    }
  }

  Future<void> _handleSave() async {
    if (_usernameController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Small delay for UX
      widget.onSave(_usernameController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRemove() async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove Social Media'),
        content: const Text('Are you sure you want to remove this social media account?'),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.delete),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onRemove != null) {
      widget.onRemove!();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.currentUsername != null && widget.currentUsername!.isNotEmpty;

    return CupertinoAlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_getPlatformIcon(widget.platform), style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            isEditing ? 'Edit ${widget.platform}' : 'Add ${widget.platform}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _usernameController,
            placeholder: _getHintText(widget.platform),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('@', style: TextStyle(color: Colors.grey)),
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSave(),
          ),
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        if (isEditing && widget.onRemove != null)
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(l10n.delete),
            onPressed: _handleRemove,
          ),
        CupertinoDialogAction(
          child: Text(l10n.cancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : Text(l10n.save),
          onPressed: _isLoading ? null : _handleSave,
        ),
      ],
    );
  }
}
