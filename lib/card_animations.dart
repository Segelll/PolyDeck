import 'package:flutter/material.dart';

class CardFlipAnimation extends StatefulWidget {
  final bool isFlipped;
  final Color frontCardColor;
  final Color backCardColor;
  final String frontText;
  final String backText;
  final VoidCallback onFlipComplete;
  final int cardNumber;

  const CardFlipAnimation({
    super.key,
    required this.isFlipped,
    required this.frontCardColor,
    required this.backCardColor,
    required this.frontText,
    required this.backText,
    required this.onFlipComplete,
    required this.cardNumber,
  });

  @override
  CardFlipAnimationState createState() => CardFlipAnimationState();
}

class CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  AnimationStatusListener? _statusListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addStatusListener((status) {
        if (_statusListener != null) {
          _statusListener!(status);
        }
      });

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CardFlipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void addStatusListener(AnimationStatusListener listener) {
    _statusListener = listener;
  }

  void removeStatusListener() {
    _statusListener = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * 3.1415;
        final isUnder = (angle > 3.1415 / 2.0);
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            width: 250,
            height: 350,
            decoration: BoxDecoration(
              color: isUnder ? widget.backCardColor : widget.frontCardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Text(
                    'Card ${widget.cardNumber}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                Center(
                  child: isUnder
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.1415),
                          child: Text(
                            widget.backText,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 28),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Text(
                          widget.frontText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 28),
                          textAlign: TextAlign.center,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
