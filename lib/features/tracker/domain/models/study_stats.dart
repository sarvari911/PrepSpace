class StudyStats {
  final int dayStreak;
  final DateTime? lastActiveDate;
  final int totalCompletedCount;

  const StudyStats({
    this.dayStreak = 0,
    this.lastActiveDate,
    this.totalCompletedCount = 0,
  });

  /// Returns the current active streak.
  ///
  /// If more than 1 calendar day has passed since last recorded study activity,
  /// the active streak is broken and returns 0 until new activity is recorded.
  int get currentStreak {
    if (lastActiveDate == null || dayStreak <= 0) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    final diff = today.difference(lastDay).inDays;
    if (diff > 1) {
      // Missed at least one calendar day (broken streak)
      return 0;
    }
    return dayStreak;
  }

  /// Records study activity (e.g. topic completion).
  StudyStats recordActivity(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    if (lastActiveDate == null) {
      return StudyStats(
        dayStreak: 1,
        lastActiveDate: now,
        totalCompletedCount: totalCompletedCount + 1,
      );
    }

    final lastDay = DateTime(
      lastActiveDate!.year,
      lastActiveDate!.month,
      lastActiveDate!.day,
    );
    final diff = today.difference(lastDay).inDays;

    int newStreak;
    if (diff == 0) {
      // Multiple completions on the same day: maintain current streak
      newStreak = dayStreak > 0 ? dayStreak : 1;
    } else if (diff == 1) {
      // Studied yesterday: increment streak by 1
      newStreak = dayStreak + 1;
    } else {
      // Missed one or more days: reset streak to 1 today
      newStreak = 1;
    }

    return StudyStats(
      dayStreak: newStreak,
      lastActiveDate: now,
      totalCompletedCount: totalCompletedCount + 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayStreak': dayStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'totalCompletedCount': totalCompletedCount,
    };
  }

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    return StudyStats(
      dayStreak: json['dayStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate'] as String)
          : null,
      totalCompletedCount: json['totalCompletedCount'] as int? ?? 0,
    );
  }
}
