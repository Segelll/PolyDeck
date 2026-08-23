import 'package:flutter/material.dart';
import 'package:poly2/core/theme/app_theme.dart';
import 'package:poly2/domain/enums/rating.dart';

/// Compact FSRS rating controls used by the button review mode.
class ReviewRatingControls extends StatelessWidget {
  final String againLabel;
  final String hardLabel;
  final String goodLabel;
  final String easyLabel;
  final bool disabled;
  final ValueChanged<Rating> onRating;

  const ReviewRatingControls({
    super.key,
    required this.againLabel,
    required this.hardLabel,
    required this.goodLabel,
    required this.easyLabel,
    required this.disabled,
    required this.onRating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _RatingAction(
            label: againLabel,
            color: AppTheme.ratingAgain,
            icon: Icons.replay,
            rating: Rating.again,
            disabled: disabled,
            onRating: onRating,
          ),
        ),
        Expanded(
          child: _RatingAction(
            label: hardLabel,
            color: AppTheme.ratingHard,
            icon: Icons.trending_down,
            rating: Rating.hard,
            disabled: disabled,
            onRating: onRating,
          ),
        ),
        Expanded(
          child: _RatingAction(
            label: goodLabel,
            color: AppTheme.ratingGood,
            icon: Icons.check,
            rating: Rating.good,
            disabled: disabled,
            onRating: onRating,
          ),
        ),
        Expanded(
          child: _RatingAction(
            label: easyLabel,
            color: AppTheme.ratingEasy,
            icon: Icons.thumb_up,
            rating: Rating.easy,
            disabled: disabled,
            onRating: onRating,
          ),
        ),
      ],
    );
  }
}

class _RatingAction extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final Rating rating;
  final bool disabled;
  final ValueChanged<Rating> onRating;

  const _RatingAction({
    required this.label,
    required this.color,
    required this.icon,
    required this.rating,
    required this.disabled,
    required this.onRating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: label,
          onPressed: disabled ? null : () => onRating(rating),
          icon: Icon(icon, size: 19),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 42, height: 42),
          style: IconButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppTheme.ratingOnColor,
            disabledBackgroundColor: color.withAlpha(120),
            disabledForegroundColor: AppTheme.ratingOnColor.withAlpha(150),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
