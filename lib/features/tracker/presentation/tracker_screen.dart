import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/subject_icons.dart';
import '../domain/models/module.dart';
import '../domain/models/subject.dart';
import '../domain/models/topic.dart';
import 'providers/tracker_providers.dart';
import 'widgets/custom_subject_dialog.dart';
import 'widgets/topic_dialog.dart';
import 'widgets/topic_item_tile.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(trackerNotifierProvider);
    final selectedSubjectId = ref.watch(selectedSubjectIdProvider);

    return SafeArea(
      child: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return _buildEmptyState(context);
          }

          // Pick the selected subject or fallback to the first one
          final currentSubject = subjects.firstWhere(
            (s) => s.id == selectedSubjectId,
            orElse: () => subjects.first,
          );

          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Color(currentSubject.colorValue),
              foregroundColor: Colors.white,
              onPressed: () => _openAddTopicDialog(
                context,
                currentSubject,
                currentSubject.modules.isNotEmpty
                    ? currentSubject.modules.first.id
                    : null,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Topic'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title matching original smoke test expectation
                  const Text(
                    'Preparation Tracker',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Organize your subjects, concepts and practical skills.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 18),

                  // Subject Selector Horizontal Chips
                  _buildSubjectSelector(context, subjects, currentSubject),

                  const SizedBox(height: 18),

                  // Active Subject Summary Card
                  _buildSubjectHeaderCard(context, currentSubject),

                  const SizedBox(height: 20),

                  // Modules and Topics list
                  if (currentSubject.modules.isEmpty)
                    _buildNoModulesCard(context, currentSubject)
                  else
                    ...currentSubject.modules.map(
                      (module) => _buildModuleSection(
                        context,
                        currentSubject,
                        module,
                      ),
                    ),

                  const SizedBox(height: 70), // Padding for FAB
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error loading tracker: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSelector(
    BuildContext context,
    List<Subject> subjects,
    Subject activeSubject,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...subjects.map((subject) {
            final isSelected = subject.id == activeSubject.id;
            final color = Color(subject.colorValue);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: isSelected,
                selectedColor: color.withValues(alpha: 0.15),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? color : AppColors.cardBorder,
                  width: isSelected ? 1.5 : 1.0,
                ),
                avatar: Icon(
                  SubjectIcons.fromCodePoint(subject.iconCodePoint),
                  size: 17,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
                label: Text(
                  subject.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                onSelected: (_) {
                  ref.read(selectedSubjectIdProvider.notifier).setSelectedId(
                        subject.id,
                      );
                },
              ),
            );
          }),

          // Button to add a new custom subject
          ActionChip(
            avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: const Text(
              'New Subject',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
            backgroundColor: AppColors.primaryBackground,
            side: BorderSide.none,
            onPressed: () => _openAddSubjectDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectHeaderCard(BuildContext context, Subject subject) {
    final color = Color(subject.colorValue);
    final percent = (subject.progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.14),
                radius: 22,
                child: Icon(
                  SubjectIcons.fromCodePoint(subject.iconCodePoint),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subject.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (val) {
                  if (val == 'edit_subject') {
                    _openEditSubjectDialog(context, subject);
                  } else if (val == 'add_module') {
                    _openAddModuleDialog(context, subject);
                  } else if (val == 'delete_subject') {
                    _confirmDeleteSubject(context, subject);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit_subject',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Subject'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_module',
                    child: Row(
                      children: [
                        Icon(Icons.folder_open_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Add Module'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_subject',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Subject', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: subject.progress,
                  minHeight: 7,
                  backgroundColor: AppColors.progressTrack,
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subject.completedTopics} of ${subject.totalTopics} topics completed',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                '${subject.modules.length} modules',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSection(
    BuildContext context,
    Subject subject,
    Module module,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (module.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          module.description!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    '${module.completedTopics}/${module.totalTopics}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Add Topic to this module',
                  onPressed: () =>
                      _openAddTopicDialog(context, subject, module.id),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  onSelected: (val) {
                    if (val == 'edit_module') {
                      _openEditModuleDialog(context, subject, module);
                    } else if (val == 'delete_module') {
                      _confirmDeleteModule(context, subject, module);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit_module',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Module'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete_module',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Module', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.cardBorder),

          // Topics list inside module
          if (module.topics.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () =>
                      _openAddTopicDialog(context, subject, module.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add first topic'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: module.topics.map((topic) {
                  return TopicItemTile(
                    topic: topic,
                    onToggleStatus: () {
                      ref.read(trackerNotifierProvider.notifier).toggleTopicStatus(
                            subjectId: subject.id,
                            moduleId: module.id,
                            topicId: topic.id,
                          );
                    },
                    onSelectStatus: (status) {
                      ref.read(trackerNotifierProvider.notifier).setTopicStatus(
                            subjectId: subject.id,
                            moduleId: module.id,
                            topicId: topic.id,
                            status: status,
                          );
                    },
                    onEdit: () =>
                        _openEditTopicDialog(context, subject, module, topic),
                    onDelete: () => _confirmDeleteTopic(
                      context,
                      subject.id,
                      module.id,
                      topic,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoModulesCard(BuildContext context, Subject subject) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'No modules yet in this subject',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create a module to start adding practice topics.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () => _openAddModuleDialog(context, subject),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Module'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist_rounded,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 18),
            const Text(
              'Preparation Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'No subjects yet. Create your first preparation track!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => _openAddSubjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddTopicDialog(
    BuildContext context,
    Subject subject,
    String? defaultModuleId,
  ) {
    if (subject.modules.isEmpty) {
      _openAddModuleDialog(context, subject);
      return;
    }

    final targetModuleId = defaultModuleId ?? subject.modules.first.id;

    showDialog(
      context: context,
      builder: (ctx) => TopicDialog(
        titleText: 'Add Preparation Topic',
        availableModules: subject.modules,
        selectedModuleId: targetModuleId,
        onSave: ({required moduleId, required title, description}) {
          ref.read(trackerNotifierProvider.notifier).addTopic(
                subjectId: subject.id,
                moduleId: moduleId,
                title: title,
                description: description,
              );
        },
      ),
    );
  }

  void _openEditTopicDialog(
    BuildContext context,
    Subject subject,
    Module module,
    Topic topic,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => TopicDialog(
        titleText: 'Edit Topic',
        existingTopic: topic,
        availableModules: [module],
        selectedModuleId: module.id,
        onSave: ({required moduleId, required title, description}) {
          ref.read(trackerNotifierProvider.notifier).editTopic(
                subjectId: subject.id,
                moduleId: moduleId,
                topicId: topic.id,
                newTitle: title,
                newDescription: description,
              );
        },
      ),
    );
  }

  void _confirmDeleteTopic(
    BuildContext context,
    String subjectId,
    String moduleId,
    Topic topic,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text('Are you sure you want to delete "${topic.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(trackerNotifierProvider.notifier).deleteTopic(
                    subjectId: subjectId,
                    moduleId: moduleId,
                    topicId: topic.id,
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomSubjectDialog(
        onSave: ({
          required title,
          required subtitle,
          required iconCodePoint,
          required colorValue,
          defaultModuleName,
        }) {
          ref.read(trackerNotifierProvider.notifier).addSubject(
                title: title,
                subtitle: subtitle,
                iconCodePoint: iconCodePoint,
                colorValue: colorValue,
                defaultModuleName: defaultModuleName,
              );
        },
      ),
    );
  }

  void _openAddModuleDialog(BuildContext context, Subject subject) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Module to ${subject.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Module Title',
                hintText: 'e.g. Dynamic Programming',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g. 1D & 2D memoization',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref.read(trackerNotifierProvider.notifier).addModule(
                      subjectId: subject.id,
                      title: title,
                      description: descController.text.trim(),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add Module'),
          ),
        ],
      ),
    );
  }

  void _openEditSubjectDialog(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => CustomSubjectDialog(
        existingSubject: subject,
        onSave: ({
          required title,
          required subtitle,
          required iconCodePoint,
          required colorValue,
          defaultModuleName,
        }) {
          ref.read(trackerNotifierProvider.notifier).editSubject(
                subjectId: subject.id,
                newTitle: title,
                newSubtitle: subtitle,
                newIconCodePoint: iconCodePoint,
                newColorValue: colorValue,
              );
        },
      ),
    );
  }

  void _openEditModuleDialog(
    BuildContext context,
    Subject subject,
    Module module,
  ) {
    final titleController = TextEditingController(text: module.title);
    final descController = TextEditingController(text: module.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Module'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Module Title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref.read(trackerNotifierProvider.notifier).editModule(
                      subjectId: subject.id,
                      moduleId: module.id,
                      newTitle: title,
                      newDescription: descController.text.trim(),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteModule(
    BuildContext context,
    Subject subject,
    Module module,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Module'),
        content: Text(
          'Are you sure you want to delete "${module.title}"? All ${module.topics.length} child topics inside it will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(trackerNotifierProvider.notifier).deleteModule(
                    subjectId: subject.id,
                    moduleId: module.id,
                  );
            },
            child: const Text('Delete Module'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSubject(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${subject.title}" and all its topics?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(trackerNotifierProvider.notifier)
                  .deleteSubject(subject.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
