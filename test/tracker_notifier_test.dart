import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prep_space/features/tracker/domain/models/topic_status.dart';
import 'package:prep_space/features/tracker/presentation/providers/tracker_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('TrackerNotifier loads default subjects and toggles topic status',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial load
    final subjects = await container.read(trackerNotifierProvider.future);
    expect(subjects.isNotEmpty, true);

    final firstSubject = subjects.first;
    final firstModule = firstSubject.modules.first;
    final firstTopic = firstModule.topics.first;

    final initialStatus = firstTopic.status;

    // Toggle status
    await container.read(trackerNotifierProvider.notifier).toggleTopicStatus(
          subjectId: firstSubject.id,
          moduleId: firstModule.id,
          topicId: firstTopic.id,
        );

    final updatedSubjects =
        await container.read(trackerNotifierProvider.future);
    final updatedTopic = updatedSubjects.first.modules.first.topics.first;

    if (initialStatus == TopicStatus.completed) {
      expect(updatedTopic.status, TopicStatus.notStarted);
    } else if (initialStatus == TopicStatus.notStarted) {
      expect(updatedTopic.status, TopicStatus.inProgress);
    } else {
      expect(updatedTopic.status, TopicStatus.completed);
    }
  });

  test('TrackerNotifier adds, edits and deletes topics dynamically', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final subjects = await container.read(trackerNotifierProvider.future);
    final firstSubject = subjects.first;
    final firstModule = firstSubject.modules.first;
    final initialCount = firstModule.topics.length;

    // Add topic
    await container.read(trackerNotifierProvider.notifier).addTopic(
          subjectId: firstSubject.id,
          moduleId: firstModule.id,
          title: 'New Dynamic Topic',
          description: 'A test topic',
        );

    var currentSubjects = await container.read(trackerNotifierProvider.future);
    var updatedModule = currentSubjects.first.modules.first;
    expect(updatedModule.topics.length, initialCount + 1);

    final addedTopic = updatedModule.topics.last;
    expect(addedTopic.title, 'New Dynamic Topic');

    // Edit topic
    await container.read(trackerNotifierProvider.notifier).editTopic(
          subjectId: firstSubject.id,
          moduleId: firstModule.id,
          topicId: addedTopic.id,
          newTitle: 'Renamed Dynamic Topic',
          newDescription: 'Updated notes',
        );

    currentSubjects = await container.read(trackerNotifierProvider.future);
    updatedModule = currentSubjects.first.modules.first;
    final editedTopic =
        updatedModule.topics.firstWhere((t) => t.id == addedTopic.id);
    expect(editedTopic.title, 'Renamed Dynamic Topic');

    // Delete topic
    await container.read(trackerNotifierProvider.notifier).deleteTopic(
          subjectId: firstSubject.id,
          moduleId: firstModule.id,
          topicId: addedTopic.id,
        );

    currentSubjects = await container.read(trackerNotifierProvider.future);
    updatedModule = currentSubjects.first.modules.first;
    expect(updatedModule.topics.length, initialCount);
  });
}
