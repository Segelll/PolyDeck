/// Represents the user's self-assessment feedback for a word card.
enum FeedbackType {
  /// Word is difficult (swipe left → red)
  hard(1),

  /// Word is easy (swipe right → green)
  easy(2),

  /// Word is medium (swipe down → yellow)
  medium(3);

  const FeedbackType(this.value);
  final int value;

  /// Creates a [FeedbackType] from its integer database value.
  factory FeedbackType.fromValue(int value) {
    switch (value) {
      case 1:
        return FeedbackType.hard;
      case 2:
        return FeedbackType.easy;
      case 3:
        return FeedbackType.medium;
      default:
        return FeedbackType.hard;
    }
  }
}
