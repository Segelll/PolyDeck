import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poly2/domain/enums/flip_direction.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/presentation/widgets/highlighted_sentence.dart';

/// An animated card that flips on its horizontal or vertical axis
/// to reveal the back side.
class CardFlipAnimation extends StatefulWidget {
  final bool isFlipped;
  final Color frontCardColor;
  final Color backCardColor;
  final String frontText;
  final String backText;
  final String frontSentence;
  final String backSentence;
  final FlipDirection flipDirection;

  const CardFlipAnimation({
    super.key,
    required this.isFlipped,
    required this.frontCardColor,
    required this.backCardColor,
    required this.frontText,
    required this.backText,
    required this.frontSentence,
    required this.backSentence,
    required this.flipDirection,
  });

  @override
  CardFlipAnimationState createState() => CardFlipAnimationState();
}

class CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _flipAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant CardFlipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        unawaited(_controller.forward());
      } else {
        unawaited(_controller.reverse());
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
    final isHorizontalFlip = widget.flipDirection != FlipDirection.topToBottom;
    final isReverse = widget.flipDirection == FlipDirection.rightToLeft;

    final frontFace = _buildFace(
      color: widget.frontCardColor,
      text: widget.frontText,
      sentence: widget.frontSentence,
    );
    final backFace = _buildFace(
      color: widget.backCardColor,
      text: widget.backText,
      sentence: widget.backSentence,
      textRotation: isHorizontalFlip ? (isReverse ? pi : -pi) : pi,
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flipAnimation,
        child: null,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final transform = Matrix4.identity()..setEntry(3, 2, 0.001);

          if (isHorizontalFlip) {
            transform.rotateY(isReverse ? -angle : angle);
          } else {
            transform.rotateX(angle);
          }

          // The text widgets are created once per parent build. Only the
          // transform and the visible face change on animation ticks.
          final face = _flipAnimation.value < 0.5 ? frontFace : backFace;
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: face,
          );
        },
      ),
    );
  }

  Widget _buildFace({
    required Color color,
    required String text,
    required String sentence,
    double textRotation = 0,
  }) {
    Matrix4 buildTextTransform() {
      final m = Matrix4.identity()..setEntry(3, 2, 0.001);
      if (textRotation != 0) {
        if (widget.flipDirection == FlipDirection.topToBottom) {
          m.rotateX(textRotation);
        } else {
          m.rotateY(textRotation);
        }
      }
      return m;
    }

    final content = Center(
      child: Transform(
        alignment: Alignment.center,
        transform: buildTextTransform(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(color: AppPalette.ink, fontSize: 28),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Flexible(
                child: HighlightedSentence(
                  sentence: sentence,
                  word: text,
                  style: const TextStyle(color: AppPalette.ink, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      width: 250,
      height: 350,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: content,
    );
  }
}
