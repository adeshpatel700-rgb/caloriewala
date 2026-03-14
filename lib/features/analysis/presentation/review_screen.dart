import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/typography.dart';
import '../../../core/services/local_food_recognizer.dart';
import '../../../core/widgets/app_components.dart';
import 'providers/analysis_provider.dart';
import 'result_screen.dart';

/// Review screen: confirm/edit detected food before AI analysis
class ReviewScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final String? barcodeData;
  final bool isTextMode;

  const ReviewScreen({
    super.key,
    this.imageFile,
    this.barcodeData,
    this.isTextMode = false,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _textCtrl    = TextEditingController();
  final _portionCtrl = TextEditingController();
  final _recognizer  = LocalFoodRecognizer();

  bool _textMode        = false;
  bool _scanning        = false;
  String? _statusMsg;
  List<RecognizedFoodItem>? _items;
  String _selectedCategory = 'Lunch';

  @override
  void initState() {
    super.initState();
    _textMode = widget.isTextMode || widget.imageFile == null;
    if (widget.barcodeData != null) _handleBarcode();
    else if (widget.imageFile != null) _scan();
  }

  void _handleBarcode() {
    setState(() {
      _textMode = true;
      _statusMsg = 'Barcode: ${widget.barcodeData}';
      _textCtrl.text = 'Product barcode: ${widget.barcodeData}';
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref.read(imageAnalysisProvider.notifier).analyzeText(
        'Find nutrition for product barcode ${widget.barcodeData}. '
        'Give best estimate if exact product unknown.',
      );
    });
  }

  Future<void> _scan() async {
    setState(() { _scanning = true; _statusMsg = 'Reading image…'; });
    try {
      final result = await _recognizer.recognizeFood(widget.imageFile!);
      if (!mounted) return;
      setState(() {
        _scanning  = false;
        _statusMsg = result.message;
        _items     = result.items;
      });
      if (result.success && !result.requiresManualInput) {
        _textCtrl.text = _items!.map((i) => i.name).join(', ');
      } else {
        setState(() => _textMode = true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scanning  = false;
        _textMode  = true;
        _statusMsg = 'Could not read image. Describe the food below.';
      });
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _portionCtrl.dispose();
    _recognizer.dispose();
    super.dispose();
  }

  Future<void> _analyse() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final portionNote = _portionCtrl.text.trim().isNotEmpty
        ? ' (portion: ${_portionCtrl.text.trim()})'
        : '';
    final fullPrompt = '$text$portionNote';

    if (widget.imageFile != null && !_textMode) {
      await ref.read(imageAnalysisProvider.notifier).analyzeImageWithContext(
        widget.imageFile!,
        fullPrompt,
      );
    } else {
      await ref.read(imageAnalysisProvider.notifier).analyzeText(fullPrompt);
    }

    if (!mounted) return;
    final state = ref.read(imageAnalysisProvider);
    if (state.foodItems != null && state.foodItems!.isNotEmpty) {
      Navigator.push(
        context,
        PageTransitions.slideFromRight(ResultScreen(
          foodItems: state.foodItems!,
          imageFile: widget.imageFile,
          mealCategory: _selectedCategory,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageAnalysisProvider);
    final isLoading = state.isLoading || _scanning;

    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        title: Text('Review Meal', style: AppText.h2.copyWith(color: AppPalette.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPalette.textSec, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppPalette.bg,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image preview ──────────────────────────────
                  if (widget.imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.file(
                              widget.imageFile!,
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                            // Mode toggle
                            Positioned(
                              top: 12, right: 12,
                              child: GestureDetector(
                                onTap: () => setState(() => _textMode = !_textMode),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppPalette.bg.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppPalette.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _textMode ? Icons.auto_awesome : Icons.edit,
                                        size: 14,
                                        color: AppPalette.accent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _textMode ? 'Use AI Vision' : 'Type Description',
                                        style: AppText.labelSm.copyWith(
                                            color: AppPalette.text,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Scan status / detected items ─────────────
                  if (_scanning)
                    _StatusCard(
                      icon: Icons.image_search_outlined,
                      text: _statusMsg ?? 'Analysing image patterns…',
                      color: AppPalette.accent,
                    )
                  else if (_items != null && _items!.isNotEmpty && !_textMode)
                    _DetectedCard(
                      items: _items!,
                      onDismiss: (name) => setState(() =>
                          _items!.removeWhere((i) => i.name == name)),
                    )
                  else if (_statusMsg != null && _textMode)
                    _StatusCard(
                      icon: Icons.info_outline,
                      text: _statusMsg!,
                      color: AppPalette.warning,
                    ),

                  const SizedBox(height: 24),

                  // ── Description field ──────────────────────────
                  Text('What are you eating?',
                      style: AppText.h4.copyWith(color: AppPalette.textSec)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textCtrl,
                    style: AppText.bodyLg.copyWith(color: AppPalette.text),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: _textMode
                          ? 'e.g. "2 paneer paratha with curd"'
                          : 'Add items or corrections…',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.restaurant_menu,
                            size: 18, color: AppPalette.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Portion field ──────────────────────────────
                  Text('Portion Size',
                      style: AppText.h4.copyWith(color: AppPalette.textSec)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _portionCtrl,
                    style: AppText.bodyMd.copyWith(color: AppPalette.text),
                    decoration: const InputDecoration(
                      hintText: 'e.g. "1 medium bowl", "2 pieces"',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.scale_outlined,
                            size: 18, color: AppPalette.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Meal category ──────────────────────────────
                  Text('Time of Meal',
                      style: AppText.h4.copyWith(color: AppPalette.textSec)),
                  const SizedBox(height: 12),
                  _CategoryRow(
                    selected: _selectedCategory,
                    onSelect: (c) => setState(() => _selectedCategory = c),
                  ),

                  // ── Analysis error ─────────────────────────────
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _StatusCard(
                        icon: Icons.error_outline,
                        text: state.error ?? 'Analysis failed. Please try again.',
                        color: AppPalette.error,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Pinned CTA ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: AppPalette.bg,
              border: Border(top: BorderSide(color: AppPalette.border.withOpacity(0.5))),
            ),
            child: AppButton(
              text: isLoading ? 'Calculating Nutrition…' : 'Analyse & Log',
              isLoading: isLoading,
              icon: isLoading ? null : Icons.bolt_rounded,
              onPressed: isLoading ? null : _analyse,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub‑widgets ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _StatusCard({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(BorderSide(color: color.withAlpha(60))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppText.bodyMd.copyWith(color: AppPalette.textSec)),
          ),
        ],
      ),
    );
  }
}

class _DetectedCard extends StatelessWidget {
  final List<RecognizedFoodItem> items;
  final ValueChanged<String> onDismiss;
  const _DetectedCard({required this.items, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.successMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.fromBorderSide(
            BorderSide(color: AppPalette.success.withAlpha(60))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_outline,
                size: 14, color: AppPalette.success),
            const SizedBox(width: 6),
            Text('Detected', style: AppText.labelMd.copyWith(color: AppPalette.success)),
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) => Chip(
              label: Text(item.name,
                  style: AppText.labelMd.copyWith(color: AppPalette.text)),
              deleteIcon: const Icon(Icons.close, size: 14, color: AppPalette.textSec),
              onDeleted: () => onDismiss(item.name),
              backgroundColor: AppPalette.surfaceTop,
              side: const BorderSide(color: AppPalette.border),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryRow({required this.selected, required this.onSelect});

  static const _cats = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _cats.map((c) {
        final active = c == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppPalette.accent : AppPalette.surfaceTop,
                borderRadius: BorderRadius.circular(10),
                border: Border.fromBorderSide(BorderSide(
                  color: active ? AppPalette.accent : AppPalette.border,
                )),
              ),
              child: Text(c.substring(0, 3),
                  textAlign: TextAlign.center,
                  style: AppText.labelMd.copyWith(
                    color: active ? Colors.black : AppPalette.textSec,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}
