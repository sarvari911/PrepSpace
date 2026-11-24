import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/subject.dart';
import '../../domain/models/study_stats.dart';
import 'seed_data.dart';

class TrackerLocalDataSource {
  static const String _subjectsKey = 'prepspace_subjects_data_v1';
  static const String _statsKey = 'prepspace_study_stats_v1';

  final SharedPreferences? _prefsInstance;

  TrackerLocalDataSource([this._prefsInstance]);

  Future<SharedPreferences> get _prefs async =>
      _prefsInstance ?? await SharedPreferences.getInstance();

  Future<List<Subject>> loadSubjects() async {
    final prefs = await _prefs;
    final rawJson = prefs.getString(_subjectsKey);

    if (rawJson == null || rawJson.trim().isEmpty) {
      // First launch: initialize with realistic seed data and persist
      final defaultList = SeedData.defaultSubjects;
      await saveSubjects(defaultList);
      return defaultList;
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If corrupted, fallback to seed
      return SeedData.defaultSubjects;
    }
  }

  Future<void> saveSubjects(List<Subject> subjects) async {
    final prefs = await _prefs;
    final jsonList = subjects.map((s) => s.toJson()).toList();
    await prefs.setString(_subjectsKey, jsonEncode(jsonList));
  }

  Future<StudyStats> loadStudyStats() async {
    final prefs = await _prefs;
    final rawJson = prefs.getString(_statsKey);

    if (rawJson == null || rawJson.trim().isEmpty) {
      final defaultStats = SeedData.defaultStudyStats;
      await saveStudyStats(defaultStats);
      return defaultStats;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return StudyStats.fromJson(decoded);
    } catch (_) {
      return SeedData.defaultStudyStats;
    }
  }

  Future<void> saveStudyStats(StudyStats stats) async {
    final prefs = await _prefs;
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }
}
