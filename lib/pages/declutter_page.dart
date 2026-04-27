import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import '../design_system.dart';
import '../core/services/database_service.dart';
import '../core/services/gallery_service.dart';

class DeclutterPage extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final bool openCleaningMode;

  const DeclutterPage({
    super.key,
    this.onMenuTap,
    this.openCleaningMode = false,
  });

  @override
  State<DeclutterPage> createState() => _DeclutterPageState();
}

class _DeclutterPageState extends State<DeclutterPage> {
  int _currentTab = 0;
  bool _showOnHome = true;
  final String _notificationFreq = 'Daily';

  List<AssetEntity> _mediaList = [];
  int _currentIndex = 0;
  int _totalItems = 0;
  int _cleanedItems = 0;
  bool _isLoading = false;
  bool _hasPermission = false;

  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initGallery();
  }

  Future<void> _loadSettings() async {
    final dbService = DatabaseService();
    final showOnHome = await dbService.getSetting('declutter_show_on_home');
    if (mounted) {
      setState(() {
        _showOnHome = showOnHome == null ? true : showOnHome == 'true';
      });
    }
    if (widget.openCleaningMode && mounted) {
      setState(() {
        _currentTab = 1;
      });
    }
  }

  Future<void> _initGallery() async {
    setState(() => _isLoading = true);

    final hasPermission = await GalleryService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _hasPermission = true);

    final items = await GalleryService.fetchImages(count: 20);
    if (mounted) {
      setState(() {
        _mediaList = items;
        _totalItems = items.length;
        _cleanedItems = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshGallery() async {
    await _initGallery();
  }

  Future<Uint8List?> _getThumbnailBytes(AssetEntity asset) async {
    if (_thumbnailCache.containsKey(asset.id)) {
      return _thumbnailCache[asset.id];
    }
    final bytes = await GalleryService.getThumbnailBytes(asset, width: 400);
    _thumbnailCache[asset.id] = bytes;
    return bytes;
  }

  Future<void> _nextItem() async {
    if (_currentIndex < _mediaList.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Session Complete!'),
        content: Text(
          'You reviewed $_totalItems items.\nCleaned: $_cleanedItems',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentIndex = 0;
                _cleanedItems = 0;
                _refreshGallery();
              });
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _keepItem() async {
    setState(() {
      _cleanedItems++;
    });
    await _nextItem();
    HapticFeedback.lightImpact();
  }

  Future<void> _deleteItem(AssetEntity asset) async {
    final success = await GalleryService.deleteImage(asset);
    if (success) {
      setState(() {
        _mediaList.removeAt(_currentIndex);
        _totalItems = _mediaList.length;
        _cleanedItems++;
        if (_mediaList.isEmpty) {
          _showCompletionDialog();
        }
      });
      HapticFeedback.mediumImpact();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete image')),
      );
    }
  }

  void _trashItem() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Trash'),
        content: const Text('This feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalItems > 0 ? _cleanedItems / _totalItems : 0.0;
    final currentAsset = _currentIndex < _mediaList.length ? _mediaList[_currentIndex] : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl)
                    .copyWith(top: AppSpacing.lg, bottom: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSettingsSection(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildSegmentedControl(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildProgressIndicator(progress),
                    const SizedBox(height: AppSpacing.xl),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (!_hasPermission)
                      _buildPermissionDenied()
                    else if (_mediaList.isEmpty)
                      _buildEmptyGallery()
                    else if (currentAsset != null)
                      _buildDeclutterCard(currentAsset),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onMenuTap,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(Icons.menu, color: AppColors.primary, size: 28),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Declutter',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home Page Visibility',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Show decluttering widget on home',
                      style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _buildToggle(
                value: _showOnHome,
                onChanged: (value) {
                  setState(() => _showOnHome = value);
                  DatabaseService().setSetting('declutter_show_on_home', value.toString());
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Frequency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'How often we remind you',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => HapticFeedback.lightImpact(),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _notificationFreq,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, size: 16, color: AppColors.onSurface),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: "Today's Pick",
              isActive: _currentTab == 0,
              onTap: () => setState(() => _currentTab = 0),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: 'Cleaning Mode',
              isActive: _currentTab == 1,
              onTap: () => setState(() => _currentTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: isActive ? signatureGradient : null,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$_cleanedItems of $_totalItems cleaned',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDeclutterCard(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: _getThumbnailBytes(asset),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 4),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: bytes != null
                          ? Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(asset),
                            )
                          : _buildPlaceholder(asset),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / $_totalItems',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildActionButtons(asset),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(AssetEntity asset) {
    return Container(
      color: AppColors.surfaceContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<Map<String, dynamic>>(
              future: GalleryService.getMetadata(asset),
              builder: (context, snapshot) {
                final meta = snapshot.data;
                return Column(
                  children: [
                    if (meta != null)
                      Text(
                        meta['sizeFormatted'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to load preview',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AssetEntity asset) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: Icons.delete_outline,
              label: 'Trash',
              color: AppColors.onSurfaceVariant,
              size: 64,
              onTap: _trashItem,
            ),
            const SizedBox(width: AppSpacing.xl),
            _buildActionButton(
              icon: Icons.check,
              label: 'Keep',
              color: AppColors.onPrimary,
              bgColor: AppColors.primary,
              size: 80,
              isFilled: true,
              onTap: _keepItem,
            ),
            const SizedBox(width: AppSpacing.xl),
            _buildActionButton(
              icon: Icons.close,
              label: 'Delete Forever',
              color: AppColors.onSurfaceVariant,
              size: 64,
              onTap: () => _deleteItem(asset),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? bgColor,
    double size = 64,
    bool isFilled = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor ?? AppColors.surfaceContainerHighest,
                shape: BoxShape.circle,
                gradient: isFilled ? signatureGradient : null,
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: size * 0.4,
                color: color,
                fill: isFilled ? 1 : 0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: isFilled ? 14 : 12,
                fontWeight: isFilled ? FontWeight.bold : FontWeight.w500,
                color: isFilled ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Permission denied',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'MicroStep needs access to your photos to help you declutter.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _initGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library_outlined, size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No images found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Your gallery is empty or we couldn’t load images.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}