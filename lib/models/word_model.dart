class WordModel {
  final int id;
  final String word;
  final String sentence;
  final String level;
  final int? isSeen;
  final int? feedback;

  WordModel({
    required this.id,
    required this.word,
    required this.sentence,
    required this.level,
    this.isSeen = 0,
    this.feedback = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'sentence': sentence,
      'level': level,
      'isSeen': isSeen,
      'feedback': feedback,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'],
      sentence: map['sentence'],
      level: map['level'],
      isSeen: map['isSeen'] ?? 0,
      feedback: map['feedback'] ?? 0,
    );
  }
}
