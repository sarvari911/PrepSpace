import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/module.dart';
import '../../domain/models/study_stats.dart';
import '../../domain/models/subject.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/topic_status.dart';
import '../../domain/repositories/tracker_repository.dart';
import '../../data/repositories/local_tracker_repository.dart';

/// Provider for the [TrackerRepository] interface.
/// Allows swapping to a Supabase or Remote implementation seamlessly.
final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  return LocalTrackerRepository();
});

/// Bottom navigation tab index notifier.
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final navigationIndexProvider =
    NotifierProvider<NavigationIndexNotifier, int>(
  NavigationIndexNotifier.new,
);

/// Currently selected subject ID inside the Tracker screen.
class SelectedSubjectIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setSelectedId(String? id) => state = id;
}

final selectedSubjectIdProvider =
    NotifierProvider<SelectedSubjectIdNotifier, String?>(
  SelectedSubjectIdNotifier.new,
);

/// Manages study statistics such as day streaks and activity records.
class StudyStatsNotifier extends AsyncNotifier<StudyStats> {
  @override
  Future<StudyStats> build() async {
    final repo = ref.read(trackerRepositoryProvider);
    return repo.getStudyStats();
  }

  Future<void> recordActivity() async {
    final repo = ref.read(trackerRepositoryProvider);
    final updated = await repo.recordActivity();
    state = AsyncData(updated);
  }
}

final studyStatsNotifierProvider =
    AsyncNotifierProvider<StudyStatsNotifier, StudyStats>(
  StudyStatsNotifier.new,
);

/// Primary state notifier managing the reactive list of subjects, modules, and topics.
class TrackerNotifier extends AsyncNotifier<List<Subject>> {
  @override
  Future<List<Subject>> build() async {
    final repo = ref.read(trackerRepositoryProvider);
    return repo.getSubjects();
  }

  TrackerRepository get _repo => ref.read(trackerRepositoryProvider);

  /// Toggles a topic's status in a cyclic manner:
  /// notStarted -> inProgress -> completed -> notStarted.
  Future<void> toggleTopicStatus({
    required String subjectId,
    required String moduleId,
    required String topicId,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final subject = currentList.firstWhere((s) => s.id == subjectId);
    final module = subject.modules.firstWhere((m) => m.id == moduleId);
    final topic = module.topics.firstWhere((t) => t.id == topicId);

    final TopicStatus nextStatus;
    DateTime? completedAt;

    switch (topic.status) {
      case TopicStatus.notStarted:
        nextStatus = TopicStatus.inProgress;
        break;
      case TopicStatus.inProgress:
        nextStatus = TopicStatus.completed;
        completedAt = DateTime.now();
        break;
      case TopicStatus.completed:
        nextStatus = TopicStatus.notStarted;
        break;
    }

    final updatedTopic = topic.copyWith(
      status: nextStatus,
      completedAt: completedAt,
    );

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withUpdatedTopic(moduleId: moduleId, updatedTopic: updatedTopic);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.updateTopic(
      subjectId: subjectId,
      moduleId: moduleId,
      topic: updatedTopic,
    );

    if (nextStatus == TopicStatus.completed) {
      await ref.read(studyStatsNotifierProvider.notifier).recordActivity();
    }
  }

  /// Sets a topic's status directly.
  Future<void> setTopicStatus({
    required String subjectId,
    required String moduleId,
    required String topicId,
    required TopicStatus status,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final subject = currentList.firstWhere((s) => s.id == subjectId);
    final module = subject.modules.firstWhere((m) => m.id == moduleId);
    final topic = module.topics.firstWhere((t) => t.id == topicId);

    final updatedTopic = topic.copyWith(
      status: status,
      completedAt: status == TopicStatus.completed ? DateTime.now() : null,
    );

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withUpdatedTopic(moduleId: moduleId, updatedTopic: updatedTopic);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.updateTopic(
      subjectId: subjectId,
      moduleId: moduleId,
      topic: updatedTopic,
    );

    if (status == TopicStatus.completed) {
      await ref.read(studyStatsNotifierProvider.notifier).recordActivity();
    }
  }

  /// Adds a new topic to a given module and subject.
  Future<void> addTopic({
    required String subjectId,
    required String moduleId,
    required String title,
    String? description,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final newTopic = Topic(
      id: 'top_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description:
          description?.trim().isEmpty == true ? null : description?.trim(),
      status: TopicStatus.notStarted,
      createdAt: DateTime.now(),
    );

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withAddedTopic(moduleId: moduleId, newTopic: newTopic);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.addTopic(
      subjectId: subjectId,
      moduleId: moduleId,
      topic: newTopic,
    );
  }

  /// Edits an existing topic.
  Future<void> editTopic({
    required String subjectId,
    required String moduleId,
    required String topicId,
    required String newTitle,
    String? newDescription,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final subject = currentList.firstWhere((s) => s.id == subjectId);
    final module = subject.modules.firstWhere((m) => m.id == moduleId);
    final topic = module.topics.firstWhere((t) => t.id == topicId);

    final updatedTopic = topic.copyWith(
      title: newTitle.trim(),
      description:
          newDescription?.trim().isEmpty == true ? null : newDescription?.trim(),
    );

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withUpdatedTopic(moduleId: moduleId, updatedTopic: updatedTopic);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.updateTopic(
      subjectId: subjectId,
      moduleId: moduleId,
      topic: updatedTopic,
    );
  }

  /// Deletes a topic.
  Future<void> deleteTopic({
    required String subjectId,
    required String moduleId,
    required String topicId,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withDeletedTopic(moduleId: moduleId, topicId: topicId);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.deleteTopic(
      subjectId: subjectId,
      moduleId: moduleId,
      topicId: topicId,
    );
  }

  /// Adds a new module to a subject.
  Future<void> addModule({
    required String subjectId,
    required String title,
    String? description,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final newModule = Module(
      id: 'mod_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description:
          description?.trim().isEmpty == true ? null : description?.trim(),
      topics: const [],
    );

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.copyWith(modules: [...s.modules, newModule]);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.saveSubjects(updatedSubjects);
  }

  /// Adds a new subject.
  Future<void> addSubject({
    required String title,
    required String subtitle,
    required int iconCodePoint,
    required int colorValue,
    String? defaultModuleName,
  }) async {
    final currentList = state.value ?? [];

    final initialModule = Module(
      id: 'mod_${DateTime.now().microsecondsSinceEpoch}',
      title: defaultModuleName ?? 'Core Concepts',
      description: 'Foundational topics for $title',
      topics: const [],
    );

    final newSubject = Subject(
      id: 'sub_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      subtitle: subtitle.trim(),
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      modules: [initialModule],
    );

    final updated = [...currentList, newSubject];
    state = AsyncData(updated);
    await _repo.addSubject(newSubject);
  }

  /// Edits an existing module.
  Future<void> editModule({
    required String subjectId,
    required String moduleId,
    required String newTitle,
    String? newDescription,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      final updatedModules = s.modules.map((m) {
        if (m.id != moduleId) return m;
        return m.copyWith(
          title: newTitle.trim(),
          description:
              newDescription?.trim().isEmpty == true ? null : newDescription?.trim(),
        );
      }).toList();
      return s.copyWith(modules: updatedModules);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.saveSubjects(updatedSubjects);
  }

  /// Deletes a module and all its child topics.
  Future<void> deleteModule({
    required String subjectId,
    required String moduleId,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.withDeletedModule(moduleId);
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.saveSubjects(updatedSubjects);
  }

  /// Edits an existing subject.
  Future<void> editSubject({
    required String subjectId,
    required String newTitle,
    required String newSubtitle,
    required int newIconCodePoint,
    required int newColorValue,
  }) async {
    final currentList = state.value;
    if (currentList == null) return;

    final updatedSubjects = currentList.map((s) {
      if (s.id != subjectId) return s;
      return s.copyWith(
        title: newTitle.trim(),
        subtitle: newSubtitle.trim(),
        iconCodePoint: newIconCodePoint,
        colorValue: newColorValue,
      );
    }).toList();

    state = AsyncData(updatedSubjects);
    await _repo.saveSubjects(updatedSubjects);
  }

  /// Deletes a subject.
  Future<void> deleteSubject(String subjectId) async {
    final currentList = state.value;
    if (currentList == null) return;

    final updated = currentList.where((s) => s.id != subjectId).toList();
    state = AsyncData(updated);
    await _repo.deleteSubject(subjectId);
  }
}

final trackerNotifierProvider =
    AsyncNotifierProvider<TrackerNotifier, List<Subject>>(
  TrackerNotifier.new,
);

/// Computed Providers for the Dashboard and Tracker screens.

final overallProgressProvider = Provider<double>((ref) {
  final subjectsAsync = ref.watch(trackerNotifierProvider);
  return subjectsAsync.maybeWhen(
    data: (subjects) {
      final total = subjects.fold(0, (sum, s) => sum + s.totalTopics);
      final completed = subjects.fold(0, (sum, s) => sum + s.completedTopics);
      if (total == 0) return 0.0;
      return (completed / total).clamp(0.0, 1.0);
    },
    orElse: () => 0.0,
  );
});

final overallProgressPercentageProvider = Provider<int>((ref) {
  final progress = ref.watch(overallProgressProvider);
  return (progress * 100).round();
});

final totalCompletedTopicsCountProvider = Provider<int>((ref) {
  final subjectsAsync = ref.watch(trackerNotifierProvider);
  return subjectsAsync.maybeWhen(
    data: (subjects) =>
        subjects.fold(0, (sum, s) => sum + s.completedTopics),
    orElse: () => 0,
  );
});

final totalSubjectsCountProvider = Provider<int>((ref) {
  final subjectsAsync = ref.watch(trackerNotifierProvider);
  return subjectsAsync.maybeWhen(
    data: (subjects) => subjects.length,
    orElse: () => 0,
  );
});

final dayStreakProvider = Provider<int>((ref) {
  final statsAsync = ref.watch(studyStatsNotifierProvider);
  return statsAsync.maybeWhen(
    data: (stats) => stats.currentStreak,
    orElse: () => 0,
  );
});
