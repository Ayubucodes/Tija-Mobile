import 'package:flutter/material.dart';

class BouncingLetterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double bounceHeight;
  final Duration letterDuration; // how long each letter's bounce takes
  final Duration staggerDelay; // delay between each letter starting

  const BouncingLetterText({
    super.key,
    required this.text,
    required this.style,
    this.bounceHeight = 16,
    this.letterDuration = const Duration(milliseconds: 900),
    this.staggerDelay = const Duration(milliseconds: 120),
  });

  @override
  State<BouncingLetterText> createState() => _BouncingLetterTextState();
}

class _BouncingLetterTextState extends State<BouncingLetterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    final totalDuration = widget.letterDuration +
        widget.staggerDelay * (widget.text.length - 1);

    _controller = AnimationController(
      vsync: this,
      duration: totalDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _letterOffset(int index) {
    final totalMs = _controller.duration!.inMilliseconds;
    final startMs = widget.staggerDelay.inMilliseconds * index;
    final endMs = startMs + widget.letterDuration.inMilliseconds;

    final start = startMs / totalMs;
    final end = (endMs / totalMs).clamp(0.0, 1.0);

    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -widget.bounceHeight, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 0.001, // negligible, just to hold position after
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.linear),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (i) {
        final letter = widget.text[i];
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _letterOffset(i).value),
              child: child,
            );
          },
          child: Text(
            letter == ' ' ? '\u00A0' : letter, // preserve spaces
            style: widget.style,
          ),
        );
      }),
    );
  }
}