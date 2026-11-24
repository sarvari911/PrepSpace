import 'package:flutter_test/flutter_test.dart';
import 'package:prep_space/features/tracker/domain/models/topic.dart';
import 'package:prep_space/features/tracker/domain/models/topic_status.dart';
import 'package:prep_space/features/tracker/domain/models/module.dart';
import 'package:prep_space/features/tracker/domain/models/subject.dart';
import 'package:prep_space/features/tracker/domain/models/study_stats.dart';

void main() {
  group('Topic Model', () {
    test('toJson and fromJson serializes accurately', () {
      final now = DateTime.now();
      final topic = Topic(
        id: 'top_1',
        title: 'Binary Search',
        description: 'Divide and conquer',
        status: TopicStatus.inProgress,
        createdAt: now,
      );

      final json = topic.toJson();
      final fromJson = Topic.fromJson(json);

      expect(fromJson.id, 'top_1');
      expect(fromJson.title, 'Binary Search');
      expect(fromJson.description, 'Divide and conquer');
      expect(fromJson.status, TopicStatus.inProgress);
      expect(fromJson.isCompleted, false);
    });

    test('TopicStatus displayName and parsing works', () {
      expect(TopicStatus.notStarted.displayName, 'Not Started');
      expect(TopicStatus.inProgress.displayName, 'In Progress');
      expect(TopicStatus.completed.displayName, 'Completed');

      expect(TopicStatus.fromString('in_progress'), TopicStatus.inProgress);
      expect(TopicStatus.fromString('completed'), TopicStatus.completed);
      expect(TopicStatus.fromString('unknown'), TopicStatus.notStarted);
    });
  });

  group('Module and Subject Progress Calculations', () {
    test('Module computes completion ratio and progress correctly', () {
      final now = DateTime.now();
      final module = Module(
        id: 'mod_1',
        title: 'Arrays',
        topics: [
          Topic(
            id: 't1',
            title: 'T1',
            status: TopicStatus.completed,
            createdAt: now,
          ),
          Topic(
            id: 't2',
            title: 'T2',
            status: TopicStatus.inProgress,
            createdAt: now,
          ),
          Topic(
            id: 't3',
            title: 'T3',
            status: TopicStatus.notStarted,
            createdAt: now,
          ),
          Topic(
            id: 't4',
            title: 'T4',
            status: TopicStatus.completed,
            createdAt: now,
          ),
        ],
      );

      expect(module.totalTopics, 4);
      expect(module.completedTopics, 2);
      expect(module.progress, 0.5);
    });

    test('Subject aggregates multiple modules progress accurately', () {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub_1',
        title: 'DSA',
        subtitle: 'Algorithms',
        iconCodePoint: 1234,
        colorValue: 0xFF6558D3,
        modules: [
          Module(
            id: 'm1',
            title: 'M1',
            topics: [
              Topic(
                id: 't1',
                title: 'T1',
                status: TopicStatus.completed,
                createdAt: now,
              ),
              Topic(
                id: 't2',
                title: 'T2',
                status: TopicStatus.completed,
                createdAt: now,
              ),
            ],
          ),
          Module(
            id: 'm2',
            title: 'M2',
            topics: [
              Topic(
                id: 't3',
                title: 'T3',
                status: TopicStatus.completed,
                createdAt: now,
              ),
              Topic(
                id: 't4',
                title: 'T4',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      );

      expect(subject.totalTopics, 4);
      expect(subject.completedTopics, 3);
      expect(subject.progress, 0.75);
    });

    test('Subject immutable mutations work as expected', () {
      final now = DateTime.now();
      final subject = Subject(
        id: 'sub_1',
        title: 'DSA',
        subtitle: 'Algorithms',
        iconCodePoint: 1234,
        colorValue: 0xFF6558D3,
        modules: [
          Module(
            id: 'm1',
            title: 'M1',
            topics: [
              Topic(
                id: 't1',
                title: 'T1',
                status: TopicStatus.notStarted,
                createdAt: now,
              ),
            ],
          ),
        ],
      );

      // Add topic
      final withAdded = subject.withAddedTopic(
        moduleId: 'm1',
        newTopic: Topic(
          id: 't2',
          title: 'T2',
          status: TopicStatus.completed,
          createdAt: now,
        ),
      );
      expect(withAdded.modules.first.topics.length, 2);

      // Update topic
      final withUpdated = withAdded.withUpdatedTopic(
        moduleId: 'm1',
        updatedTopic: Topic(
          id: 't1',
          title: 'T1 Updated',
          status: TopicStatus.completed,
          createdAt: now,
        ),
      );
      expect(withUpdated.modules.first.topics.first.title, 'T1 Updated');
      expect(withUpdated.completedTopics, 2);

      // Delete topic
      final withDeleted = withUpdated.withDeletedTopic(
        moduleId: 'm1',
        topicId: 't1',
      );
      expect(withDeleted.modules.first.topics.length, 1);
      expect(withDeleted.modules.first.topics.first.id, 't2');

      // Module operations
      final withAddedMod = withDeleted.withAddedModule(
        const Module(id: 'm2', title: 'M2', topics: []),
      );
      expect(withAddedMod.modules.length, 2);

      final withUpdatedMod = withAddedMod.withUpdatedModule(
        const Module(id: 'm2', title: 'M2 Updated', topics: []),
      );
      expect(withUpdatedMod.modules.last.title, 'M2 Updated');

      final withDeletedMod = withUpdatedMod.withDeletedModule('m2');
      expect(withDeletedMod.modules.length, 1);
      expect(withDeletedMod.modules.first.id, 'm1');
    });
  });

  group('StudyStats Model', () {
    test('Calculates streaks correctly across consecutive days', () {
      final today = DateTime(2026, 11, 25, 10, 0);
      final yesterday = DateTime(2026, 11, 24, 10, 0);

      var stats = StudyStats(
        dayStreak: 5,
        lastActiveDate: yesterday,
        totalCompletedCount: 20,
      );

      stats = stats.recordActivity(today);
      expect(stats.dayStreak, 6);
      expect(stats.totalCompletedCount, 21);
    });

    test('Resets streak if missed more than 1 day', () {
      final today = DateTime(2026, 11, 25, 10, 0);
      final threeDaysAgo = DateTime(2026, 11, 22, 10, 0);

      var stats = StudyStats(
        dayStreak: 5,
        lastActiveDate: threeDaysAgo,
        totalCompletedCount: 20,
      );

      stats = stats.recordActivity(today);
      expect(stats.dayStreak, 1);
      expect(stats.totalCompletedCount, 21);
    });

    test('currentStreak returns 0 if missed a day, and active streak if studied today or yesterday', () {
      final today = DateTime.now();
      final statsActiveToday = StudyStats(
        dayStreak: 3,
        lastActiveDate: today,
      );
      expect(statsActiveToday.currentStreak, 3);

      final statsActiveYesterday = StudyStats(
        dayStreak: 3,
        lastActiveDate: today.subtract(const Duration(days: 1)),
      );
      expect(statsActiveYesterday.currentStreak, 3);

      final statsExpired = StudyStats(
        dayStreak: 5,
        lastActiveDate: today.subtract(const Duration(days: 3)),
      );
      expect(statsExpired.currentStreak, 0);

      const statsEmpty = StudyStats();
      expect(statsEmpty.currentStreak, 0);
    });
  });
}
