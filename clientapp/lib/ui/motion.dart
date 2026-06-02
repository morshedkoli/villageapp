import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import 'design_system.dart';

/// Production-grade motion primitives for AL ISLAH.
///
/// Goals:
/// • Calm, intentional motion (200–320ms, no elastic bounce)
/// • Respects `MediaQuery.disableAnimations` and reduced-motion preference
/// • Hairline haptics on confirmations only — never on every tap
/// • Reusable building blocks: stagger, fade-slide, page transitions, shimmer
///
/// Use these instead of ad-hoc AnimationControllers wherever possible — they
/// keep timing and easing consistent across the app.

// ────────────────────────────────────────────────────────────────────────────
// Reduced motion helper
// ────────────────────────────────────────────────────────────────────────────

class ReducedMotion {
  const ReducedMotion._();

  /// Returns true when the OS has accessibility "reduce motion" enabled OR
  /// MediaQuery has globally disabled animations. Widgets should treat this
  /// as a signal to skip animation and snap to the final state.
  static bool of(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations ?? false;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// FadeSlideIn — calm enter animation for any widget
// ────────────────────────────────────────────────────────────────────────────

/// Fades + slides a child into place when the widget is mounted.
/// Pair with [StaggeredEnter] to delay successive items.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 320),
    this.offset = const Offset(0, 0.08),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Offset in fractional units (1.0 = full child height/width).
  final Offset offset;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctl, curve: widget.curve);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctl, curve: widget.curve));
    if (widget.delay == Duration.zero) {
      _ctl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ReducedMotion.of(context)) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// StaggeredEnter — calculates increasing delays for a list of children
// ────────────────────────────────────────────────────────────────────────────

class StaggeredColumn extends StatelessWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.gap = 12,
    this.startDelay = const Duration(milliseconds: 40),
    this.itemDelay = const Duration(milliseconds: 60),
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final double gap;
  final Duration startDelay;
  final Duration itemDelay;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final reduced = ReducedMotion.of(context);

    final wrapped = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) wrapped.add(SizedBox(height: gap));
      if (reduced) {
        wrapped.add(children[i]);
      } else {
        wrapped.add(
          FadeSlideIn(
            delay: startDelay + itemDelay * i,
            child: children[i],
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: wrapped,
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// PressScale — wraps a child to give it 0.96 press feedback
// ────────────────────────────────────────────────────────────────────────────

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.haptic = false,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  /// When true, plays a `selectionClick` haptic on press-down.
  /// Reserve for important confirmations; never use on rapid-fire taps.
  final bool haptic;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _down() {
    if (!widget.enabled) return;
    _ctl.forward();
    if (widget.haptic) HapticFeedback.selectionClick();
  }

  void _up() {
    _ctl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      onTap: widget.enabled ? widget.onTap : null,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// AnimatedCount — smoothly tweens between numeric values
// ────────────────────────────────────────────────────────────────────────────

class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.style,
    this.formatter,
  });

  final num value;
  final Duration duration;
  final TextStyle? style;
  final String Function(num)? formatter;

  @override
  Widget build(BuildContext context) {
    if (ReducedMotion.of(context)) {
      return Text(_format(value), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(_format(v), style: style),
    );
  }

  String _format(num v) {
    if (formatter != null) return formatter!(v);
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shimmer — calm skeleton shimmer that tracks the surface palette
// ────────────────────────────────────────────────────────────────────────────

class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = ReducedMotion.of(context);
    final base = AppColors.surfaceVariantC(context);
    final highlight = AppColors.borderLightC(context);
    final radius = BorderRadius.circular(
      widget.borderRadius ?? widget.height / 2.5,
    );

    if (reduced) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: base, borderRadius: radius),
      );
    }

    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, _) {
        final t = _ctl.value;
        return ClipRRect(
          borderRadius: radius,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + t * 2, 0),
                end: Alignment(0.0 + t * 2, 0),
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Hairline animated bottom-bar indicator builder
// ────────────────────────────────────────────────────────────────────────────

class AnimatedDot extends StatelessWidget {
  const AnimatedDot({
    super.key,
    required this.active,
    this.size = 4,
    this.activeWidth = 18,
  });

  final bool active;
  final double size;
  final double activeWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: active ? activeWidth : size,
      height: size,
      decoration: BoxDecoration(
        color: active ? cs.primary : AppColors.borderC(context),
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Subtle haptic helpers — wrappers so call-sites read intentionally
// ────────────────────────────────────────────────────────────────────────────

class Haptics {
  const Haptics._();

  static void tap() => HapticFeedback.selectionClick();
  static void confirm() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.mediumImpact();
  static void error() => HapticFeedback.heavyImpact();
}

// ────────────────────────────────────────────────────────────────────────────
// Smoother default page route — fade-through instead of platform default
// ────────────────────────────────────────────────────────────────────────────

class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 280),
  }) : super(
          pageBuilder: (_, _, _) => page,
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, anim, secAnim, child) {
            if (ReducedMotion.of(context)) return child;
            final fade = CurvedAnimation(
              parent: anim,
              curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
            );
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            ));
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

// ────────────────────────────────────────────────────────────────────────────
// SchedulerBinding — small helper to run after first frame
// ────────────────────────────────────────────────────────────────────────────

void afterFirstFrame(VoidCallback fn) {
  SchedulerBinding.instance.addPostFrameCallback((_) => fn());
}
