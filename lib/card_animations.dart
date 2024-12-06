import 'package:flutter/material.dart';
import 'dart:math';

enum FlipDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
}

class CardFlipAnimation extends StatefulWidget {
  final bool isFlipped;
  final Color frontCardColor;
  final Color backCardColor;
  final String frontText;
  final String backText;
  final String frontSentence;
  final String backSentence;
  final VoidCallback onFlipComplete;
  final int cardNumber;
  final FlipDirection flipDirection;
  final String level;

  const CardFlipAnimation({
    Key? key,
    required this.isFlipped,
    required this.frontCardColor,
    required this.backCardColor,
    required this.frontText,
    required this.backText,
    required this.frontSentence,
    required this.backSentence,
    required this.onFlipComplete,
    required this.cardNumber,
    required this.flipDirection,
    required this.level,
  }) : super(key: key);

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

    bool isHorizontalFlip = widget.flipDirection != FlipDirection.topToBottom;
    bool isReverse = widget.flipDirection == FlipDirection.rightToLeft;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi;
        final transform = Matrix4.identity()..setEntry(3, 2, 0.001);

        if (isHorizontalFlip) {
          transform.rotateY(isReverse ? -angle : angle);
        } else {
          transform.rotateX(angle);
        }

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            width: 250,
            height: 350,
            decoration: BoxDecoration(
              color: widget.isFlipped ? widget.backCardColor : widget.frontCardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            child: _buildCardContent(isHorizontalFlip, isReverse),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(bool isHorizontalFlip, bool isReverse) {
    final isUnder = _flipAnimation.value > 0.5;
    final contentText = isUnder ? widget.backText : widget.frontText;
    final contentSentence=isUnder? widget.backSentence:widget.frontSentence;


    final textRotationAngle = isUnder
        ? (isHorizontalFlip
        ? (isReverse ? pi : -pi)
        : pi)
        : 0.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isHorizontalFlip ? textRotationAngle : 0)
                ..rotateX(isHorizontalFlip ? 0 : textRotationAngle),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(contentText,
                style: const TextStyle(color: Colors.white, fontSize: 28),
                textAlign: TextAlign.center,),
                  const SizedBox(height: 10),
                  Text(contentSentence,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,)
                
                ],
                
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isHorizontalFlip ? textRotationAngle : 0)
              ..rotateX(isHorizontalFlip ? 0 : textRotationAngle),
            child: Text(
              widget.level,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(isHorizontalFlip ? textRotationAngle : 0)
              ..rotateX(isHorizontalFlip ? 0 : textRotationAngle),
            child: Text(
              'Card ${widget.cardNumber}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
