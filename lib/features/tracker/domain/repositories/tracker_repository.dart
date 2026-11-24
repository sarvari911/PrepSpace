import '../models/subject.dart';
import '../models/topic.dart';
import '../models/study_stats.dart';

/// Repository contract for subject and topic tracking.
///
/// Implementations can be local (SharedPreferences/SQLite) or remote (Supabase).
/// The presentation and state layer depends strictly on this interface.
abstract class TrackerRepository {
  Future<List<Subject>> getSubjects();
  Future<void> saveSubjects(List<Subject> subjects);

  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);

  Future<void> addTopic({
    required String subjectId,
    required String moduleId,
    required Topic topic,
  });

  Future<void> updateTopic({
    required String subjectId,
    required String moduleId,
    required Topic topic,
  });

  Future<void> deleteTopic({
    required String subjectId,
    required String moduleId,
    required String topicId,
  });

  Future<StudyStats> getStudyStats();
  Future<void> saveStudyStats(StudyStats stats);
  Future<StudyStats> recordActivity();
}
