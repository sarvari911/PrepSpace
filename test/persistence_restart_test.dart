import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prep_space/features/tracker/data/datasources/tracker_local_datasource.dart';
import 'package:prep_space/features/tracker/data/repositories/local_tracker_repository.dart';
import 'package:prep_space/features/tracker/domain/models/module.dart';
import 'package:prep_space/features/tracker/domain/models/subject.dart';
import 'package:prep_space/features/tracker/domain/models/topic.dart';
import 'package:prep_space/features/tracker/domain/models/topic_status.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Full Application Restart & Persistence Verification', () {
    test(
        'All tracker data (subjects, modules, topics, statuses) survives complete repository/datasource recreation',
        () async {
      // -------------------------------------------------------------
      // SESSION 1: Before Application Restart
      // -------------------------------------------------------------
      var session1DataSource = TrackerLocalDataSource();
      var session1Repository = LocalTrackerRepository(session1DataSource);

      // Initial load loads and seeds data
      final initialSubjects = await session1Repository.getSubjects();
      expect(initialSubjects.isNotEmpty, true);

      // 1. Add a custom subject
      final customSubject = Subject(
        id: 'sub_custom_restart_test',
        title: 'Advanced Computer Networks',
        subtitle: 'BGP, OSPF and SDN Architecture',
        iconCodePoint: 58828,
        colorValue: 0xFF2D88D4,
        modules: [
          Module(
            id: 'mod_routing_1',
            title: 'Dynamic Routing Protocols',
            description: 'Link-state and distance-vector protocols',
            topics: [
              Topic(
                id: 'top_bgp_1',
                title: 'BGP Path Vector & AS Path',
                description: 'Autonomous systems and peering',
                status: TopicStatus.completed,
                createdAt: DateTime.now(),
                completedAt: DateTime.now(),
              ),
              Topic(
                id: 'top_ospf_1',
                title: 'OSPF Dijkstra SPF Algorithm',
                description: 'Area 0 backbone and LSA flooding',
                status: TopicStatus.inProgress,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
      );

      await session1Repository.addSubject(customSubject);

      // 2. Modify an existing seeded topic's status
      final dsaSubject =
          initialSubjects.firstWhere((s) => s.id == 'subject_dsa');
      final targetModule = dsaSubject.modules.first;
      final targetTopic = targetModule.topics.first;

      await session1Repository.updateTopic(
        subjectId: dsaSubject.id,
        moduleId: targetModule.id,
        topic: targetTopic.copyWith(status: TopicStatus.notStarted),
      );

      // 3. Record study activity to log streak
      await session1Repository.recordActivity();

      // -------------------------------------------------------------
      // SIMULATE APP TERMINATION / PROCESS EXIT
      // Completely discard session 1 instances
      // -------------------------------------------------------------
      // (session1DataSource and session1Repository fall out of scope)

      // -------------------------------------------------------------
      // SESSION 2: After Application Restart
      // Brand new instances reading from the persistent store
      // -------------------------------------------------------------
      final session2DataSource = TrackerLocalDataSource();
      final session2Repository = LocalTrackerRepository(session2DataSource);

      final recoveredSubjects = await session2Repository.getSubjects();

      // Verify custom subject recovered
      final recoveredCustom = recoveredSubjects.firstWhere(
        (s) => s.id == 'sub_custom_restart_test',
      );
      expect(recoveredCustom.title, 'Advanced Computer Networks');
      expect(recoveredCustom.modules.length, 1);

      // Verify module and topics recovered with correct statuses
      final recoveredModule = recoveredCustom.modules.first;
      expect(recoveredModule.title, 'Dynamic Routing Protocols');
      expect(recoveredModule.topics.length, 2);

      final topicBgp =
          recoveredModule.topics.firstWhere((t) => t.id == 'top_bgp_1');
      expect(topicBgp.title, 'BGP Path Vector & AS Path');
      expect(topicBgp.status, TopicStatus.completed);

      final topicOspf =
          recoveredModule.topics.firstWhere((t) => t.id == 'top_ospf_1');
      expect(topicOspf.title, 'OSPF Dijkstra SPF Algorithm');
      expect(topicOspf.status, TopicStatus.inProgress);

      // Verify modified seeded topic maintained its change
      final recoveredDsa =
          recoveredSubjects.firstWhere((s) => s.id == 'subject_dsa');
      final recoveredTargetTopic =
          recoveredDsa.modules.first.topics.firstWhere((t) => t.id == targetTopic.id);
      expect(recoveredTargetTopic.status, TopicStatus.notStarted);

      // Verify study streak recovered
      final recoveredStats = await session2Repository.getStudyStats();
      expect(recoveredStats.dayStreak >= 1, true);
      expect(recoveredStats.currentStreak >= 1, true);
    });

    test('Module deletion completely cascades and removes child topics',
        () async {
      final dataSource = TrackerLocalDataSource();
      final repository = LocalTrackerRepository(dataSource);

      final subjects = await repository.getSubjects();
      final subject = subjects.first;
      final initialModuleCount = subject.modules.length;
      final moduleToDelete = subject.modules.first;

      // Delete module
      final updatedSubject = subject.withDeletedModule(moduleToDelete.id);
      await repository.updateSubject(updatedSubject);

      // Restart / reload
      final restartRepo = LocalTrackerRepository(TrackerLocalDataSource());
      final reloadedSubjects = await restartRepo.getSubjects();
      final reloadedSubject =
          reloadedSubjects.firstWhere((s) => s.id == subject.id);

      expect(reloadedSubject.modules.length, initialModuleCount - 1);
      expect(
        reloadedSubject.modules.any((m) => m.id == moduleToDelete.id),
        false,
      );
      // Ensure all child topics of that module are gone
      for (final topic in moduleToDelete.topics) {
        final topicStillExists = reloadedSubject.modules
            .any((m) => m.topics.any((t) => t.id == topic.id));
        expect(topicStillExists, false);
      }
    });

    test('Empty subjects and zero-topic modules do not cause errors or NaN',
        () async {
      final emptySubject = const Subject(
        id: 'sub_empty_test',
        title: 'Empty Track',
        subtitle: 'No topics added',
        iconCodePoint: 1234,
        colorValue: 0xFF6558D3,
        modules: [
          Module(id: 'mod_empty_1', title: 'Empty Module', topics: []),
        ],
      );

      expect(emptySubject.totalTopics, 0);
      expect(emptySubject.completedTopics, 0);
      expect(emptySubject.progress, 0.0);
      expect(emptySubject.progress.isNaN, false);

      final completelyEmptySubject = const Subject(
        id: 'sub_completely_empty',
        title: 'Completely Empty',
        subtitle: 'No modules',
        iconCodePoint: 1234,
        colorValue: 0xFF6558D3,
        modules: [],
      );

      expect(completelyEmptySubject.totalTopics, 0);
      expect(completelyEmptySubject.completedTopics, 0);
      expect(completelyEmptySubject.progress, 0.0);
      expect(completelyEmptySubject.progress.isNaN, false);
    });
  });
}
