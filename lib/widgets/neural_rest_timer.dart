import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NeuralRestTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onFinished;

  const NeuralRestTimer({super.key, required this.seconds, required this.onFinished});

  @override
  State<NeuralRestTimer> createState() => _NeuralRestTimerState();
}

class _NeuralRestTimerState extends State<NeuralRestTimer> with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds <= 3) {
          HapticFeedback.mediumImpact();
        }
      } else {
        _timer?.cancel();
        HapticFeedback.vibrate();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  String _formatTime() {
    int m = _remainingSeconds ~/ 60;
    int s = _remainingSeconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingSeconds / widget.seconds;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "NEURAL RECHARGE INITIATED",
            style: TextStyle(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: TimerHudPainter(progress: progress, pulse: _pulseController.value),
              ),
              AnimatedBuilder(
                animation: _glitchController,
                builder: (context, child) {
                  double offset = _remainingSeconds <= 5 ? (_glitchController.value * 2) : 0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: Text(
                      _formatTime(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        color: _remainingSeconds <= 5 ? Colors.redAccent : Colors.white,
                        shadows: [
                          Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            "SYSTEM STATUS: ${(_remainingSeconds > 0) ? 'COOLING' : 'READY'}",
            style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              widget.onFinished();
            },
            child: const Text("SKIP RECHARGE", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class TimerHudPainter extends CustomPainter {
  final double progress;
  final double pulse;

  TimerHudPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Paint progressPaint = Paint()
      ..color = Color.lerp(Colors.redAccent, Colors.cyanAccent, progress)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawCircle(center, radius - 15, trackPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      6.28 * progress,
      false,
      progressPaint,
    );

    for (int i = 0; i < 4; i++) {
      double angle = (i * 1.57) + (pulse * 0.5);
      canvas.drawLine(
          Offset(center.dx + (radius - 10) * (angle).toDouble(), center.dy),
          center,
          trackPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}