/// Configuration for a single deck level, controlling FSRS scheduling
/// and daily card limits.
class DeckConfig {
  final String level;
  final int maxNewPerDay;
  final int maxReviewsPerDay;
  final List<int> learningSteps;
  final bool enableFuzz;
  final double requestRetention;
  final List<double>? w;

  const DeckConfig({
    required this.level,
    this.maxNewPerDay = 10,
    this.maxReviewsPerDay = 20,
    this.learningSteps = const [1, 10],
    this.enableFuzz = true,
    this.requestRetention = 0.9,
    this.w,
  });

  factory DeckConfig.defaults() {
    return const DeckConfig(level: 'default');
  }

  factory DeckConfig.fromMap(Map<String, dynamic> map) {
    return DeckConfig(
      level: map['level'] as String,
      maxNewPerDay: map['max_new_per_day'] as int? ?? 10,
      maxReviewsPerDay: map['max_reviews_per_day'] as int? ?? 20,
      learningSteps: _parseJsonList(map['learning_steps'] as String?),
      enableFuzz: map['enable_fuzz'] == 1,
      requestRetention: (map['request_retention'] as num?)?.toDouble() ?? 0.9,
      w: map['w'] != null ? _parseDoubleList(map['w'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'max_new_per_day': maxNewPerDay,
      'max_reviews_per_day': maxReviewsPerDay,
      'learning_steps': learningSteps.toString(),
      'enable_fuzz': enableFuzz ? 1 : 0,
      'request_retention': requestRetention,
      'w': w?.toString(),
    };
  }

  static List<int> _parseJsonList(String? json) {
    if (json == null || json.isEmpty) return [1, 10];
    try {
      final cleaned = json.replaceAll(RegExp(r'[\[\]\s]'), '');
      return cleaned.split(',').map((s) => int.parse(s)).toList();
    } catch (_) {
      return [1, 10];
    }
  }

  static List<double> _parseDoubleList(String json) {
    try {
      final cleaned = json.replaceAll(RegExp(r'[\[\]\s]'), '');
      return cleaned.split(',').map((s) => double.parse(s)).toList();
    } catch (_) {
      return [];
    }
  }
}
