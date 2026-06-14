/// FSRS-aligned 4-button rating for card reviews.
///
/// Matches the FSRS specification: 1=Again, 2=Hard, 3=Good, 4=Easy.
enum Rating {
  /// Forgot the card completely.
  again(1),

  /// Recalled with significant difficulty.
  hard(2),

  /// Recalled correctly.
  good(3),

  /// Recalled effortlessly.
  easy(4);

  const Rating(this.value);
  final int value;

  factory Rating.fromValue(int value) {
    switch (value) {
      case 1:
        return Rating.again;
      case 2:
        return Rating.hard;
      case 3:
        return Rating.good;
      case 4:
        return Rating.easy;
      default:
        return Rating.good;
    }
  }
}
