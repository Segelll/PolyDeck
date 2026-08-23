import 'package:flutter/material.dart';
import 'package:poly2/core/theme/app_palette.dart';
import 'package:poly2/domain/enums/review_input_mode.dart';

/// Optional card actions for button review mode.
///
/// Swipe mode intentionally has no visible action buttons. The card gesture
/// is the only review control in that mode.
class ReviewUtilityControls extends StatelessWidget {
  final ReviewInputMode inputMode;
  final bool isFlipped;
  final bool showReflip;
  final bool disabled;
  final String reflipLabel;
  final String newCardLabel;
  final VoidCallback onReflip;
  final VoidCallback onNewCard;

  const ReviewUtilityControls({
    super.key,
    required this.inputMode,
    required this.isFlipped,
    required this.showReflip,
    required this.disabled,
    required this.reflipLabel,
    required this.newCardLabel,
    required this.onReflip,
    required this.onNewCard,
  });

  @override
  Widget build(BuildContext context) {
    if (inputMode != ReviewInputMode.buttons || !isFlipped) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showReflip) ...[
          _UtilityAction(
            tooltip: reflipLabel,
            icon: Icons.refresh,
            disabled: disabled,
            onPressed: onReflip,
          ),
          const SizedBox(width: 12),
        ],
        _UtilityAction(
          tooltip: newCardLabel,
          icon: Icons.skip_next,
          disabled: disabled,
          onPressed: onNewCard,
        ),
      ],
    );
  }
}

class _UtilityAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool disabled;
  final VoidCallback onPressed;

  const _UtilityAction({
    required this.tooltip,
    required this.icon,
    required this.disabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: disabled ? null : onPressed,
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      style: IconButton.styleFrom(
        backgroundColor: AppPalette.cloudDancer,
        foregroundColor: AppPalette.mutedInk,
        disabledBackgroundColor: AppPalette.nimbusCloud,
        disabledForegroundColor: AppPalette.outline,
        side: const BorderSide(color: AppPalette.outline),
        shape: const CircleBorder(),
      ),
    );
  }
}
