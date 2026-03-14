import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/colors.dart';
import '../../core/design/typography.dart';
import '../../core/services/user_profile_service.dart';

/// Splash + name onboarding — shown only on first launch
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // Phases: 0 = splash logo, 1 = name entry
  int _phase = 0;

  late AnimationController _logoCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _cardCtrl;

  late Animation<double> _logoPulse;
  late Animation<double> _logoFade;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  final _nameCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _logoPulse = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _logoCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _cardSlide = Tween<double>(begin: 60.0, end: 0.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn));

    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _phase = 1);
          _cardCtrl.forward();
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) _focusNode.requestFocus();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _orbitCtrl.dispose();
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await UserProfileService.saveName(name);
    await UserProfileService.completeOnboarding();
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Animated background dots ─────────────────────────
            ..._buildBackgroundDots(),

            // ── Content ──────────────────────────────────────────
            Positioned.fill(
              child: Column(
                children: [
                  // Logo section — always visible
                  Expanded(
                    flex: _phase == 0 ? 3 : 2,
                    child: _LogoSection(
                      pulse: _logoPulse,
                      fade: _logoFade,
                      orbit: _orbitCtrl,
                    ),
                  ),

                  // Name card — slides up in phase 1
                  if (_phase == 1)
                    AnimatedBuilder(
                      animation: _cardCtrl,
                      builder: (_, child) => Opacity(
                        opacity: _cardFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _cardSlide.value),
                          child: child,
                        ),
                      ),
                      child: _NameCard(
                        controller: _nameCtrl,
                        focusNode: _focusNode,
                        saving: _saving,
                        onDone: _done,
                      ),
                    ),

                  if (_phase == 0)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Your AI nutrition companion',
                          style: AppText.bodyMd
                              .copyWith(color: AppPalette.textTert),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDots() {
    final dots = [
      _Dot(x: 0.12, y: 0.06, size: 140, opacity: 0.06),
      _Dot(x: 0.78, y: 0.12, size: 200, opacity: 0.04),
      _Dot(x: 0.05, y: 0.45, size: 100, opacity: 0.05),
      _Dot(x: 0.88, y: 0.50, size: 160, opacity: 0.04),
      _Dot(x: 0.35, y: 0.85, size: 180, opacity: 0.05),
    ];
    return dots.map((d) => FractionallyPositioned(
          left: d.x,
          top: d.y,
          child: Container(
            width: d.size,
            height: d.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.accent.withAlpha((255 * d.opacity).toInt()),
            ),
          ),
        )).toList();
  }
}

class _Dot {
  final double x, y, size, opacity;
  const _Dot({required this.x, required this.y, required this.size, required this.opacity});
}

/// Fractional positioning helper
class FractionallyPositioned extends StatelessWidget {
  final double left, top;
  final Widget child;
  const FractionallyPositioned({
    super.key, required this.left, required this.top, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) => Positioned(
        left: c.maxWidth * left,
        top: c.maxHeight * top,
        child: child,
      ),
    );
  }
}

// ── Logo Section ──────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final Animation<double> pulse, fade;
  final AnimationController orbit;
  const _LogoSection({required this.pulse, required this.fade, required this.orbit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          scale: pulse,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Orbiting ring + logo icon
              SizedBox(
                width: 120, height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Orbit ring
                    AnimatedBuilder(
                      animation: orbit,
                      builder: (_, __) => Transform.rotate(
                        angle: orbit.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(120, 120),
                          painter: _OrbitPainter(),
                        ),
                      ),
                    ),
                    // Core icon
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B2B), Color(0xFFFF9A2B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.accent.withAlpha(80),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          color: Colors.white, size: 34),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CalorieWala',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Dashed ring
    final paint = Paint()
      ..color = AppPalette.accent.withAlpha(60)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);

    // Dot on ring
    final dotPaint = Paint()
      ..color = AppPalette.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 5, dotPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Name Card ─────────────────────────────────────────────────────────────────

class _NameCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool saving;
  final VoidCallback onDone;

  const _NameCard({
    required this.controller,
    required this.focusNode,
    required this.saving,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
        border: const Border.fromBorderSide(BorderSide(color: AppPalette.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('What\'s your name?',
              style: AppText.h2.copyWith(color: AppPalette.text)),
          const SizedBox(height: 6),
          Text('So we can personalise your experience',
              style: AppText.bodyMd.copyWith(color: AppPalette.textSec)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppText.bodyLg.copyWith(color: AppPalette.text),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => onDone(),
            decoration: InputDecoration(
              hintText: 'e.g. Adesh',
              prefixIcon: const Icon(Icons.person_outline,
                  size: 18, color: AppPalette.textTert),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, val, __) => val.text.trim().isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 16, color: AppPalette.textTert),
                        onPressed: () => controller.clear(),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: saving ? null : onDone,
              child: saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Let's go!",
                            style: AppText.bodyLg.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: Colors.black),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
