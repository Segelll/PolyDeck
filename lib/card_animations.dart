import 'package:flutter/material.dart';

class CardFlipAnimation extends StatefulWidget {
  final bool isFlipped;
  final Color cardColor;
  final String frontText;
  final String backText;
  final VoidCallback onFlipComplete;

  const CardFlipAnimation({
    super.key,
    required this.isFlipped,
    required this.cardColor,
    required this.frontText,
    required this.backText,
    required this.onFlipComplete,
  });

  @override
  _CardFlipAnimationState createState() => _CardFlipAnimationState();
}

class _CardFlipAnimationState extends State<CardFlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
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
        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              color: widget.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _flipAnimation.value > 0.5 ? widget.backText : widget.frontText,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}

class CardDropAnimation extends StatelessWidget {
  final Widget child;

  const CardDropAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0),
        end: const Offset(0, 1),
      ).animate(
        CurvedAnimation(
          parent: AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: Navigator.of(context),
          ),
          curve: Curves.easeIn,
        ),
      ),
      child: child,
    );
  }
}

class NewCardAnimation extends StatefulWidget {
  final Widget child;

  const NewCardAnimation({super.key, required this.child});

  @override
  _NewCardAnimationState createState() => _NewCardAnimationState();
}

class _NewCardAnimationState extends State<NewCardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(_controller);
    
    _controller.forward(); 
  }

  void reset() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
