import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/subject_icons.dart';
import '../../domain/models/subject.dart';

class CustomSubjectDialog extends StatefulWidget {
  final Subject? existingSubject;
  final void Function({
    required String title,
    required String subtitle,
    required int iconCodePoint,
    required int colorValue,
    String? defaultModuleName,
  }) onSave;

  const CustomSubjectDialog({
    super.key,
    this.existingSubject,
    required this.onSave,
  });

  @override
  State<CustomSubjectDialog> createState() => _CustomSubjectDialogState();
}

class _CustomSubjectDialogState extends State<CustomSubjectDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _moduleController;
  final _formKey = GlobalKey<FormState>();

  late int _selectedColor;
  late IconData _selectedIcon;

  final List<int> _colorOptions = const [
    0xFF6558D3, // Purple
    0xFF279D80, // Teal
    0xFFE28C43, // Orange
    0xFF514A86, // Indigo
    0xFFD9485D, // Coral Red
    0xFF2D88D4, // Sky Blue
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingSubject;
    _titleController = TextEditingController(text: s?.title ?? '');
    _subtitleController = TextEditingController(text: s?.subtitle ?? '');
    _moduleController = TextEditingController(text: 'Core Topics');
    _selectedColor = s?.colorValue ?? 0xFF6558D3;
    _selectedIcon = s != null
        ? SubjectIcons.fromCodePoint(s.iconCodePoint)
        : Icons.menu_book_rounded;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _moduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSubject != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Edit Subject' : 'Add New Subject',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g. Computer Networks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(
                  labelText: 'Description / Subtitle',
                  hintText: 'e.g. TCP/IP, OSI model, Routing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a brief description';
                  }
                  return null;
                },
              ),
              if (!isEditing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _moduleController,
                  decoration: InputDecoration(
                    labelText: 'Initial Module Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Color Theme',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _colorOptions.map((c) {
                  final isSelected = _selectedColor == c;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = c),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black87, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Icon',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SubjectIcons.options.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBackground
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade700,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
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
                title: _titleController.text.trim(),
                subtitle: _subtitleController.text.trim(),
                iconCodePoint: _selectedIcon.codePoint,
                colorValue: _selectedColor,
                defaultModuleName: _moduleController.text.trim(),
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? 'Update Subject' : 'Create Subject'),
        ),
      ],
    );
  }
}
