import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/colors.dart';
import '../design/typography.dart';

// ─── Bouncing Wrapper ────────────────────────────────────────────────────────
class Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Bouncing({super.key, required this.child, this.onTap});

  @override
  State<Bouncing> createState() => _BouncingState();
}

class _BouncingState extends State<Bouncing> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 0.05);
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) => widget.onTap != null ? _controller.reverse() : null,
      onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
      onTap: widget.onTap,
      child: Transform.scale(scale: _scale, child: widget.child),
    );
  }
}

// ─── App Button ────────────────────────────────────────────────────────────
enum AppButtonStyle { primary, secondary, ghost, danger }
enum AppButtonSize  { sm, md, lg }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonSize size;
  final AppButtonStyle buttonStyle;
  final bool fullWidth;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = AppButtonSize.md,
    this.buttonStyle = AppButtonStyle.primary,
    this.fullWidth = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final h = size == AppButtonSize.sm ? 44.0
             : size == AppButtonSize.lg ? 60.0
             : 54.0;

    final textStyle = (size == AppButtonSize.sm ? AppText.buttonSm : AppText.button).copyWith(
      letterSpacing: 0.5,
      fontWeight: FontWeight.bold,
    );

    Widget child = isLoading
        ? SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: buttonStyle == AppButtonStyle.primary ? Colors.black : AppPalette.accent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, 
                    color: buttonStyle == AppButtonStyle.primary ? Colors.black : null), 
                const SizedBox(width: 8)
              ],
              Text(text, style: textStyle),
            ],
          );

    return Bouncing(
      onTap: isLoading ? null : onPressed,
      child: SizedBox(
        width: width ?? (fullWidth ? double.infinity : null),
        height: h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: buttonStyle == AppButtonStyle.primary ? [
              BoxShadow(
                color: AppPalette.accent.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: _buildRawButton(child),
        ),
      ),
    );
  }

  Widget _buildRawButton(Widget child) {
    switch (buttonStyle) {
      case AppButtonStyle.primary:
        return FilledButton(
          onPressed: null, // Animation handled by Bouncing
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.accent,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppPalette.accent,
            disabledForegroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
      case AppButtonStyle.secondary:
        return OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.text,
            disabledForegroundColor: AppPalette.text,
            side: const BorderSide(color: AppPalette.border, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
      case AppButtonStyle.danger:
        return FilledButton(
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppPalette.error,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
      case AppButtonStyle.ghost:
        return TextButton(
          onPressed: null,
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.accent,
            disabledForegroundColor: AppPalette.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: child,
        );
    }
  }
}

// ─── App Card ────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool hasBorder;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.hasBorder = true,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppPalette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder
            ? Border.all(color: AppPalette.border, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppPalette.accent.withOpacity(0.05),
            highlightColor: AppPalette.accent.withOpacity(0.05),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPalette.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: AppPalette.accent),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.h2.copyWith(color: AppPalette.text)),
                if (subtitle != null)
                  Text(subtitle!, 
                      style: AppText.bodySm.copyWith(color: AppPalette.textSec)),
              ],
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: AppText.labelMd.copyWith(
                    color: AppPalette.accent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppPalette.surfaceTop,
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.border),
              ),
              child: Icon(icon, size: 36, color: AppPalette.textTert),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: AppText.h3.copyWith(color: AppPalette.text, fontSize: 20),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(subtitle!,
                  style: AppText.bodyMd.copyWith(color: AppPalette.textSec, height: 1.6),
                  textAlign: TextAlign.center),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 28),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                fullWidth: false,
                size: AppButtonSize.md,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Loading Indicator ────────────────────────────────────────────────────
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32, height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppPalette.accent),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!,
                style: AppText.bodyMd.copyWith(
                    color: AppPalette.textSec, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ─── Stat Pill ─────────────────────────────────────────────────────────
class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color color;

  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.labelXs.copyWith(color: AppPalette.textTert)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppText.numberSm.copyWith(color: color, fontSize: 20)),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(unit!, style: AppText.labelXs.copyWith(color: AppPalette.textSec)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Macro Bar ───────────────────────────────────────────────────────────
class MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final goalVal = goal > 0 ? goal : 1.0;
    final pct = (value / goalVal).clamp(0.01, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppText.labelMd.copyWith(color: AppPalette.textSec)),
            Text('${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} g',
                style: AppText.labelMd.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(height: 6, color: AppPalette.surfaceTop),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
