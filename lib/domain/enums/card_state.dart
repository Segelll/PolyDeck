/// Represents the state of a card in the FSRS scheduling system.
///
/// Values match the FSRS specification: 0=New, 1=Learning, 2=Review, 3=Relearning.
enum CardState {
  /// Never reviewed — the initial state.
  new_(0),

  /// Being learned with short-interval steps.
  learning(1),

  /// Graduated to long-term scheduling.
  review(2),

  /// Forgotten and re-entering the learning phase.
  relearning(3);

  const CardState(this.value);
  final int value;

  factory CardState.fromValue(int value) {
    switch (value) {
      case 0:
        return CardState.new_;
      case 1:
        return CardState.learning;
      case 2:
        return CardState.review;
      case 3:
        return CardState.relearning;
      default:
        return CardState.new_;
    }
  }
}
