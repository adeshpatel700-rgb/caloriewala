import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../core/design/colors.dart';
import '../../../core/design/typography.dart';
import '../../../core/animations/page_transitions.dart';
import '../../analysis/presentation/review_screen.dart';
import '../../analysis/presentation/barcode_scanner_screen.dart';

/// Scan tab — 2×2 grid of scan action cards
class HomeScreen extends StatelessWidget {
  final _picker = ImagePicker();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text('Scan Food', style: AppText.h1.copyWith(color: AppPalette.text)),
              const SizedBox(height: 4),
              Text('Choose how to log your meal',
                  style: AppText.bodyMd.copyWith(color: AppPalette.textSec)),
              const SizedBox(height: 28),

              // 2×2 Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ScanCard(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      description: 'Take a photo of your food',
                      color: AppPalette.accent,
                      onTap: () => _openCamera(context),
                    ),
                    _ScanCard(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      description: 'Pick from your photos',
                      color: AppPalette.carbs,
                      onTap: () => _openGallery(context),
                    ),
                    _ScanCard(
                      icon: Icons.edit_outlined,
                      label: 'Describe',
                      description: 'Type what you ate',
                      color: AppPalette.success,
                      onTap: () => _openTextInput(context),
                    ),
                    _ScanCard(
                      icon: Icons.qr_code_scanner_outlined,
                      label: 'Barcode',
                      description: 'Scan packaged food',
                      color: AppPalette.warning,
                      onTap: () => _openBarcode(context),
                    ),
                  ],
                ),
              ),

              // Tips
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border.fromBorderSide(BorderSide(color: AppPalette.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 14, color: AppPalette.warning),
                      const SizedBox(width: 6),
                      Text('Tips for best results',
                          style: AppText.labelMd.copyWith(color: AppPalette.warning)),
                    ]),
                    const SizedBox(height: 8),
                    const _TipRow(icon: Icons.wb_sunny_outlined, text: 'Good lighting'),
                    const _TipRow(icon: Icons.fullscreen, text: 'Clear, full view of the food'),
                    const _TipRow(icon: Icons.table_restaurant_outlined,
                        text: 'Include a plate for scale'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final photo = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 85);
      if (photo == null) return;
      if (context.mounted) _goToReview(context, imageFile: File(photo.path));
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) _showPermissionSnack(context, 'Camera permission denied. Enable in Settings.');
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    final status = await Permission.photos.request();
    
    if (status.isGranted || status.isLimited) {
      final photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (photo == null) return;
      if (context.mounted) _goToReview(context, imageFile: File(photo.path));
    } else {
      // Fallback for older Android/iOS versions where permission might not be explicitly needed for picker
      final photo = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (photo == null) return;
      if (context.mounted) _goToReview(context, imageFile: File(photo.path));
    }
  }

  void _openTextInput(BuildContext context) {
    _goToReview(context, isTextMode: true);
  }

  Future<void> _openBarcode(BuildContext context) async {
    final result = await Navigator.push(
      context,
      PageTransitions.slideFromRight(const BarcodeScannerScreen()),
    );
    if (result == null) return;
    if (context.mounted) _goToReview(context, barcodeData: result.toString());
  }

  void _goToReview(BuildContext context, {
    File? imageFile,
    String? barcodeData,
    bool isTextMode = false,
  }) {
    Navigator.push(
      context,
      PageTransitions.slideFromRight(ReviewScreen(
        imageFile: imageFile,
        barcodeData: barcodeData,
        isTextMode: isTextMode,
      )),
    );
  }

  void _showPermissionSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: openAppSettings,
          textColor: AppPalette.accent,
        ),
      ),
    );
  }
}

/// Individual scan action card
class _ScanCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ScanCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          decoration: BoxDecoration(
            color: _pressed ? AppPalette.surfaceHigh : AppPalette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.fromBorderSide(BorderSide(
              color: _pressed ? widget.color.withOpacity(0.3) : AppPalette.border,
              width: 1,
            )),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 22, color: widget.color),
              ),
              const Spacer(),
              Text(widget.label,
                  style: AppText.h3.copyWith(color: AppPalette.text)),
              const SizedBox(height: 3),
              Text(widget.description,
                  style: AppText.bodySm.copyWith(color: AppPalette.textSec),
                  maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppPalette.textTert),
          const SizedBox(width: 6),
          Text(text, style: AppText.bodySm.copyWith(color: AppPalette.textSec)),
        ],
      ),
    );
  }
}
