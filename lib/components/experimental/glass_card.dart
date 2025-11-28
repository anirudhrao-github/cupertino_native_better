import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../style/glass_effect.dart';
import '../liquid_glass_container.dart';

/// EXPERIMENTAL: A card widget with Liquid Glass effects and optional breathing animation.
/// 
/// This widget is currently experimental and API may change.
class CNGlassCard extends StatefulWidget {
  /// Creates a glass card.
  const CNGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.cornerRadius = 16.0,
    this.tint,
    this.interactive = true,
    this.breathing = false,
  });

  /// Child widget to display inside the card.
  final Widget child;

  /// Padding around the child.
  final EdgeInsetsGeometry padding;

  /// Corner radius of the card.
  final double cornerRadius;

  /// Tint color for the glass effect.
  final Color? tint;

  /// Whether the card responds to touches.
  final bool interactive;

  /// Whether to enable a subtle breathing animation (glow).
  final bool breathing;

  @override
  State<CNGlassCard> createState() => _CNGlassCardState();
}

class _CNGlassCardState extends State<CNGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.breathing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CNGlassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.breathing != oldWidget.breathing) {
      if (widget.breathing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use LiquidGlassContainer for the base effect
    final card = LiquidGlassContainer(
      config: LiquidGlassConfig(
        effect: CNGlassEffect.regular, // Use regular glass for cards
        shape: CNGlassEffectShape.rect,
        cornerRadius: widget.cornerRadius,
        tint: widget.tint,
        interactive: widget.interactive,
      ),
      child: Padding(
        padding: widget.padding,
        child: widget.child,
      ),
    );

    if (!widget.breathing) return card;

    // Wrap in animated builder for breathing effect if enabled
    // This is a Flutter-side animation that simulates the effect
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            boxShadow: [
              BoxShadow(
                color: (widget.tint ?? CupertinoColors.systemBlue)
                    .withOpacity(0.3 * _animation.value),
                blurRadius: 20 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: card,
    );
  }
}

