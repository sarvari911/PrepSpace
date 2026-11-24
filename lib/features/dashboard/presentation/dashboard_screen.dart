import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/subject_icons.dart';
import '../../tracker/presentation/providers/tracker_providers.dart';
import 'widgets/stat_card.dart';
import 'widgets/subject_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamic Riverpod reactive data
    final overallProgress = ref.watch(overallProgressProvider);
    final overallPercent = ref.watch(overallProgressPercentageProvider);
    final subjectsCount = ref.watch(totalSubjectsCountProvider);
    final completedCount = ref.watch(totalCompletedTopicsCountProvider);
    final dayStreak = ref.watch(dayStreakProvider);
    final subjectsAsync = ref.watch(trackerNotifierProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PREPSPACE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Your preparation,',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'your progress.',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryBackground,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Dynamic Journey Progress Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR LEARNING JOURNEY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Keep showing up.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Every topic you complete brings you closer to your goals.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: overallProgress,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$overallPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 27),

            const Text(
              'Your overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Dynamic Overview Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.menu_book_rounded,
                    value: subjectsCount < 10
                        ? '0$subjectsCount'
                        : '$subjectsCount',
                    label: 'Subjects',
                    color: AppColors.primaryBackground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.task_alt_rounded,
                    value: completedCount < 10
                        ? '0$completedCount'
                        : '$completedCount',
                    label: 'Completed',
                    color: AppColors.greenBackground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: dayStreak < 10 ? '0$dayStreak' : '$dayStreak',
                    label: 'Day streak',
                    color: AppColors.orangeBackground,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your preparation',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate directly to Tracker tab
                    ref.read(navigationIndexProvider.notifier).setIndex(1);
                  },
                  child: const Text('View all'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Dynamic Subject Cards List
            subjectsAsync.when(
              data: (subjects) {
                if (subjects.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text(
                      'No subjects added yet. Tap Tracker to add one!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return Column(
                  children: subjects.map((subject) {
                    return SubjectCard(
                      icon: SubjectIcons.fromCodePoint(subject.iconCodePoint),
                      title: subject.title,
                      subtitle: subject.subtitle,
                      progress: subject.progress,
                      color: Color(subject.colorValue),
                      onTap: () {
                        ref.read(selectedSubjectIdProvider.notifier).setSelectedId(
                              subject.id,
                            );
                        ref.read(navigationIndexProvider.notifier).setIndex(1);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Error loading subjects: $err'),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Your study spaces',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () {
                // Navigate to Spaces tab
                ref.read(navigationIndexProvider.notifier).setIndex(2);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryBackground,
                      child: Icon(
                        Icons.groups_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DSA Study Group',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your collaborative learning space',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
