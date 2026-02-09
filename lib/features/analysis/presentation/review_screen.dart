import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/local_food_recognizer.dart';
import '../data/models/food_item_model.dart';
import 'providers/analysis_provider.dart';
import 'result_screen.dart';

/// Review screen for confirming/editing detected food items
class ReviewScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final String? barcodeData;

  const ReviewScreen({
    super.key,
    this.imageFile,
    this.barcodeData,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _textController = TextEditingController();
  final _portionController = TextEditingController();
  final _localRecognizer = LocalFoodRecognizer();
  bool _isTextMode = false;
  bool _isAnalyzing = false;
  String? _recognitionMessage;
  List<RecognizedFoodItem>? _recognizedItems;

  @override
  void initState() {
    super.initState();
    _isTextMode = widget.imageFile == null;

    if (widget.barcodeData != null) {
      // Handle barcode data
      _handleBarcodeData();
    } else if (widget.imageFile != null) {
      // Try local recognition first
      _performLocalRecognition();
    }
  }

  void _handleBarcodeData() {
    setState(() {
      _isTextMode = true;
      _recognitionMessage = 'Barcode scanned: ${widget.barcodeData}';
      _textController.text = 'Product barcode: ${widget.barcodeData}';
    });

    // Auto-analyze barcode
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(imageAnalysisProvider.notifier).analyzeText(
            'Find nutrition info for product with barcode: ${widget.barcodeData}. If you cannot find exact product, provide best estimate for common packaged food item.');
      }
    });
  }

  Future<void> _performLocalRecognition() async {
    setState(() {
      _isAnalyzing = true;
      _recognitionMessage = 'Analyzing image locally...';
    });

    try {
      final result = await _localRecognizer.recognizeFood(widget.imageFile!);

      setState(() {
        _isAnalyzing = false;
        _recognitionMessage = result.message;
        _recognizedItems = result.items;
      });

      if (result.success && !result.requiresManualInput) {
        // High confidence - pre-fill text field with detected items
        _textController.text =
            _recognizedItems!.map((item) => item.name).join(', ');
      } else {
        // Low confidence or no detection - show manual input
        setState(() {
          _isTextMode = true;
        });
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _recognitionMessage =
            'Local recognition failed. Please describe manually.';
        _isTextMode = true;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _portionController.dispose();
    _localRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(imageAnalysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Food Items'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image preview (if available)
            if (widget.imageFile != null)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(widget.imageFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Local recognition status
            if (_recognitionMessage != null && !_isAnalyzing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _recognizedItems != null && _recognizedItems!.isNotEmpty
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _recognizedItems != null && _recognizedItems!.isNotEmpty
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _recognizedItems != null &&
                                  _recognizedItems!.isNotEmpty
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: _recognizedItems != null &&
                                  _recognizedItems!.isNotEmpty
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _recognitionMessage!,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (_recognizedItems != null &&
                        _recognizedItems!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Detected items:',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      ...(_recognizedItems!.map((item) => Padding(
                            padding: const EdgeInsets.only(left: 28, top: 4),
                            child: Text(
                              '• ${item.toDisplayString()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))),
                    ],
                  ],
                ),
              ),

            // Local analysis loading
            if (_isAnalyzing)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(_recognitionMessage ?? 'Analyzing...'),
                  ],
                ),
              ),

            // Text input mode
            if (_isTextMode && !_isAnalyzing)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        labelText: 'Food Description',
                        hintText: 'e.g., "roti aur dal"',
                        prefixIcon: const Icon(Icons.restaurant),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _textController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      maxLines: 2,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portionController,
                      decoration: const InputDecoration(
                        labelText: 'Portion Size',
                        hintText: 'e.g., "2 pieces" or "1 bowl"',
                        prefixIcon: Icon(Icons.dining),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _textController.text.trim().isEmpty
                            ? null
                            : _handleTextSubmit,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Analyze'),
                      ),
                    ),
                  ],
                ),
              ),

            // API Loading state (when using text analysis)
            if (analysisState.isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Getting nutritional information...'),
                      const SizedBox(height: 8),
                      Text(
                        'Using AI to estimate calories',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error state
            if (analysisState.error != null && !_isAnalyzing)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          analysisState.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (widget.imageFile != null) {
                              ref
                                  .read(imageAnalysisProvider.notifier)
                                  .analyzeImage(widget.imageFile!);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Food items list
            if (analysisState.foodItems != null &&
                analysisState.foodItems!.isNotEmpty &&
                !analysisState.isLoading)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: analysisState.foodItems!.length,
                  itemBuilder: (context, index) {
                    final item = analysisState.foodItems![index];
                    return _FoodItemCard(
                      item: item,
                      onUpdate: (updated) {
                        ref
                            .read(imageAnalysisProvider.notifier)
                            .updateFoodItem(index, updated);
                      },
                      onRemove: () {
                        ref
                            .read(imageAnalysisProvider.notifier)
                            .removeFoodItem(index);
                      },
                    );
                  },
                ),
              ),

            // Empty state for text mode
            if (_isTextMode && analysisState.foodItems == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Describe your meal above',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom action buttons
            if (analysisState.foodItems != null &&
                analysisState.foodItems!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _showAddItemDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm & Analyze'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTextSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your food')),
      );
      return;
    }

    // Include portion size in description if provided
    final portion = _portionController.text.trim();
    final fullDescription = portion.isNotEmpty ? '$text ($portion)' : text;

    // Analyze text description using Groq text model (free)
    ref.read(imageAnalysisProvider.notifier).analyzeText(fullDescription);
  }

  void _handleConfirm() {
    final foodItems = ref.read(imageAnalysisProvider).foodItems;
    if (foodItems == null || foodItems.isEmpty) return;

    Navigator.push(
      context,
      PageTransitions.slideFromRight(ResultScreen(foodItems: foodItems)),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final portionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                hintText: 'e.g., Roti',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portionController,
              decoration: const InputDecoration(
                labelText: 'Portion',
                hintText: 'e.g., 2 pieces',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  portionController.text.isNotEmpty) {
                final item = FoodItemModel(
                  name: nameController.text,
                  portion: portionController.text,
                  confidence: 'manual',
                );
                ref.read(imageAnalysisProvider.notifier).addFoodItem(item);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _FoodItemCard extends StatefulWidget {
  final FoodItemModel item;
  final Function(FoodItemModel) onUpdate;
  final VoidCallback onRemove;

  const _FoodItemCard({
    required this.item,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<_FoodItemCard> {
  late TextEditingController _portionController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(text: widget.item.portion);
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (widget.item.hindiName != null)
                        Text(
                          widget.item.hindiName!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                _ConfidenceBadge(confidence: widget.item.confidence),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _portionController,
                          decoration: const InputDecoration(
                            labelText: 'Portion',
                            isDense: true,
                          ),
                        )
                      : Text(
                          'Portion: ${widget.item.portion}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
                TextButton.icon(
                  onPressed: () {
                    if (_isEditing) {
                      widget.onUpdate(
                        FoodItemModel(
                          name: widget.item.name,
                          hindiName: widget.item.hindiName,
                          portion: _portionController.text,
                          confidence: widget.item.confidence,
                        ),
                      );
                    }
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  label: Text(_isEditing ? 'Save' : 'Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (confidence.toLowerCase()) {
      case 'high':
        color = AppColors.success;
        break;
      case 'low':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        confidence.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
