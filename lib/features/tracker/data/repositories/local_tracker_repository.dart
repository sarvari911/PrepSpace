import '../../domain/models/subject.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/study_stats.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../datasources/tracker_local_datasource.dart';

class LocalTrackerRepository implements TrackerRepository {
  final TrackerLocalDataSource _localDataSource;

  LocalTrackerRepository([TrackerLocalDataSource? dataSource])
      : _localDataSource = dataSource ?? TrackerLocalDataSource();

  @override
  Future<List<Subject>> getSubjects() async {
    return _localDataSource.loadSubjects();
  }

  @override
  Future<void> saveSubjects(List<Subject> subjects) async {
    return _localDataSource.saveSubjects(subjects);
  }

  @override
  Future<void> addSubject(Subject subject) async {
    final list = await getSubjects();
    final updated = [...list, subject];
    await saveSubjects(updated);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final list = await getSubjects();
    final updated = list.map((s) => s.id == subject.id ? subject : s).toList();
    await saveSubjects(updated);
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    final list = await getSubjects();
    final updated = list.where((s) => s.id != subjectId).toList();
    await saveSubjects(updated);
  }

  @override
  Future<void> addTopic({
    required String subjectId,
    required String moduleId,
    required Topic topic,
  }) async {
    final list = await getSubjects();
    final updated = list.map((s) {
      if (s.id != subjectId) return s;
      return s.withAddedTopic(moduleId: moduleId, newTopic: topic);
    }).toList();
    await saveSubjects(updated);
  }

  @override
  Future<void> updateTopic({
    required String subjectId,
    required String moduleId,
    required Topic topic,
  }) async {
    final list = await getSubjects();
    final updated = list.map((s) {
      if (s.id != subjectId) return s;
      return s.withUpdatedTopic(moduleId: moduleId, updatedTopic: topic);
    }).toList();
    await saveSubjects(updated);
  }

  @override
  Future<void> deleteTopic({
    required String subjectId,
    required String moduleId,
    required String topicId,
  }) async {
    final list = await getSubjects();
    final updated = list.map((s) {
      if (s.id != subjectId) return s;
      return s.withDeletedTopic(moduleId: moduleId, topicId: topicId);
    }).toList();
    await saveSubjects(updated);
  }

  @override
  Future<StudyStats> getStudyStats() async {
    return _localDataSource.loadStudyStats();
  }

  @override
  Future<void> saveStudyStats(StudyStats stats) async {
    return _localDataSource.saveStudyStats(stats);
  }

  @override
  Future<StudyStats> recordActivity() async {
    final stats = await getStudyStats();
    final updated = stats.recordActivity(DateTime.now());
    await saveStudyStats(updated);
    return updated;
  }
}
