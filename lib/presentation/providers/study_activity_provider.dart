import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monotonic revision used to refresh derived study statistics while the app
/// remains open. Database writes happen outside the home screen's widget tree.
final studyActivityProvider = StateProvider<int>((ref) => 0);
