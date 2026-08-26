import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimeoutListener extends StatefulWidget {
  final Duration duration;
  final bool noInactivity;
  final VoidCallback onTimeOut;
  final Widget child;

  const SessionTimeoutListener({
    super.key,
    required this.duration,
    required this.noInactivity,
    required this.onTimeOut,
    required this.child,
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    if (widget.noInactivity) return;

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(widget.duration, widget.onTimeOut);
  }

  @override
  void didUpdateWidget(SessionTimeoutListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.noInactivity != oldWidget.noInactivity) {
      if (widget.noInactivity) {
        _inactivityTimer?.cancel();
      } else {
        _resetTimer();
      }
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onScaleStart: (_) => _resetTimer(),
      onScaleEnd: (_) => _resetTimer(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _resetTimer();
          return false;
        },
        child: widget.child,
      ),
    );
  }
}
