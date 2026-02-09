import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../../core/design/spacing.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/animations/staggered_animations.dart';
import '../../analysis/presentation/review_screen.dart';
import '../../analysis/presentation/barcode_scanner_screen.dart';

/// Scan tab - Camera, Gallery, Text input
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: Spacing.xl),

              Text(
                'Analyze Your Food',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Spacing.sm),

              Text(
                'Take a photo, select from gallery, or describe your meal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Spacing.xxl),

              // Action Buttons
              FilledButton.icon(
                onPressed: () => _handleCamera(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: Spacing.md),

              FilledButton.tonalIcon(
                onPressed: () => _handleGallery(context),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: Spacing.md),

              OutlinedButton.icon(
                onPressed: () => _handleTextInput(context),
                icon: const Icon(Icons.edit),
                label: const Text('Describe Food'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: Spacing.md),

              OutlinedButton.icon(
                onPressed: () => _handleBarcodeScanner(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Barcode'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: Spacing.xxl),

              // Tips
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          'Tips for best results',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.sm),
                    _TipRow(context,
                        icon: Icons.brightness_high, text: 'Good lighting'),
                    _TipRow(context,
                        icon: Icons.fullscreen, text: 'Clear view of food'),
                    _TipRow(context,
                        icon: Icons.table_restaurant,
                        text: 'Include plate for scale'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      _showPermissionDialog(context, 'Camera');
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (photo != null && mounted) {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            ReviewScreen(imageFile: File(photo.path)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, 'Failed to take photo: $e');
    }
  }

  Future<void> _handleGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (image != null && mounted) {
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            ReviewScreen(imageFile: File(image.path)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, 'Failed to select image: $e');
    }
  }

  Future<void> _handleTextInput(BuildContext context) async {
    Navigator.of(context).push(
      PageTransitions.slideFromRight(
        const ReviewScreen(imageFile: null),
      ),
    );
  }

  Future<void> _handleBarcodeScanner(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      _showPermissionDialog(context, 'Camera');
      return;
    }

    try {
      final barcode = await Navigator.of(context).push<String>(
        PageTransitions.slideFromBottom(
          const BarcodeScannerScreen(),
        ),
      );

      if (barcode != null && mounted) {
        // Navigate to review screen with barcode data
        Navigator.of(context).push(
          PageTransitions.slideFromRight(
            ReviewScreen(
              imageFile: null,
              barcodeData: barcode,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(context, 'Failed to scan barcode: $e');
    }
  }

  void _showPermissionDialog(BuildContext context, String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text(
          'Please grant $permission permission in Settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

Widget _TipRow(BuildContext context,
    {required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(top: Spacing.xs),
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    ),
  );
}
