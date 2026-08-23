/// How the learner submits a rating after revealing a card.
enum ReviewInputMode {
  buttons,
  swipe;

  String get storageValue => name;

  static ReviewInputMode fromStorage(String? value) {
    return value == 'swipe' ? ReviewInputMode.swipe : ReviewInputMode.buttons;
  }
}
