import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/module.dart';
import '../../domain/models/topic.dart';

class TopicDialog extends StatefulWidget {
  final String titleText;
  final Topic? existingTopic;
  final List<Module> availableModules;
  final String selectedModuleId;
  final void Function({
    required String moduleId,
    required String title,
    String? description,
  }) onSave;

  const TopicDialog({
    super.key,
    required this.titleText,
    this.existingTopic,
    required this.availableModules,
    required this.selectedModuleId,
    required this.onSave,
  });

  @override
  State<TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<TopicDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _currentModuleId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingTopic?.title ?? '');
    _descController =
        TextEditingController(text: widget.existingTopic?.description ?? '');
    _currentModuleId = widget.selectedModuleId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.titleText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.availableModules.length > 1) ...[
                const Text(
                  'Module',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _currentModuleId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  items: widget.availableModules.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text(m.title, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _currentModuleId = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Topic Title',
                  hintText: 'e.g. Binary Search in Rotated Array',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a topic title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description / Notes (Optional)',
                  hintText: 'Key concepts, hints, or algorithm strategy',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              widget.onSave(
                moduleId: _currentModuleId,
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
