import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/topic.dart';
import '../../domain/models/topic_status.dart';

class TopicItemTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback onToggleStatus;
  final ValueChanged<TopicStatus> onSelectStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TopicItemTile({
    super.key,
    required this.topic,
    required this.onToggleStatus,
    required this.onSelectStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: topic.isCompleted
              ? AppColors.greenAccent.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status cycle toggle button
          InkWell(
            onTap: onToggleStatus,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildStatusIcon(),
            ),
          ),
          const SizedBox(width: 12),

          // Topic details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: topic.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: topic.isCompleted
                        ? Colors.grey.shade500
                        : AppColors.textPrimary,
                  ),
                ),
                if (topic.description != null &&
                    topic.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    topic.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                _buildStatusChip(),
              ],
            ),
          ),

          // Action menu (Edit / Delete / Set status directly)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              } else if (value == 'not_started') {
                onSelectStatus(TopicStatus.notStarted);
              } else if (value == 'in_progress') {
                onSelectStatus(TopicStatus.inProgress);
              } else if (value == 'completed') {
                onSelectStatus(TopicStatus.completed);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit Topic'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'in_progress',
                child: Row(
                  children: [
                    Icon(Icons.timelapse, size: 18, color: AppColors.orangeAccent),
                    SizedBox(width: 10),
                    Text('Mark In Progress'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: AppColors.greenAccent),
                    SizedBox(width: 10),
                    Text('Mark Completed'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete Topic', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (topic.status) {
      case TopicStatus.completed:
        return const Icon(
          Icons.check_circle_rounded,
          color: AppColors.greenAccent,
          size: 24,
        );
      case TopicStatus.inProgress:
        return const Icon(
          Icons.timelapse_rounded,
          color: AppColors.orangeAccent,
          size: 24,
        );
      case TopicStatus.notStarted:
        return Icon(
          Icons.radio_button_unchecked_rounded,
          color: Colors.grey.shade400,
          size: 24,
        );
    }
  }

  Widget _buildStatusChip() {
    Color bg;
    Color fg;
    String text;

    switch (topic.status) {
      case TopicStatus.completed:
        bg = AppColors.greenBackground;
        fg = AppColors.greenAccent;
        text = 'Completed';
        break;
      case TopicStatus.inProgress:
        bg = AppColors.orangeBackground;
        fg = AppColors.orangeAccent;
        text = 'In Progress';
        break;
      case TopicStatus.notStarted:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        text = 'To Do';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
