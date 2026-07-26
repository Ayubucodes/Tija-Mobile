import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShakeError extends StatefulWidget {
  const ShakeError({
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.shakeCount = 4,
    this.shakeOffset = 8,
    this.enableHaptics = true,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;
  final bool enableHaptics;

  @override
  // ignore: no_logic_in_create_state
  State<ShakeError> createState() => ShakeErrorState();
}

class ShakeErrorState extends State<ShakeError>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    animationController.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    animationController.dispose();
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reset();
    }
  }

  void shake() {
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        final t = animationController.value;

        // Oscillation
        final sineValue = sin(widget.shakeCount * 2 * pi * t);

        // Decay envelope: starts at full amplitude, tapers to 0
        // (1 - t)^2 gives a snappier, more natural settle than linear decay
        final decay = pow(1 - t, 2).toDouble();

        final dx = sineValue * widget.shakeOffset * decay;

        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
    );
  }
}