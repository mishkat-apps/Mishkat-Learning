import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIRepository {
  final FirebaseFunctions _functions;

  AIRepository(this._functions);

  Future<String> generateTranscript({
    required String courseId,
    required String lessonId,
    required String partId,
    required String videoUrl,
  }) async {
    try {
      final result = await _functions.httpsCallable('generateLessonTranscript').call({
        'courseId': courseId,
        'lessonId': lessonId,
        'partId': partId,
        'videoUrl': videoUrl,
      });
      return result.data['transcript'] as String;
    } catch (e) {
      debugPrint('Error generating transcript: $e');
      rethrow;
    }
  }
}

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(FirebaseFunctions.instanceFor(region: 'us-central1'));
});
