import 'package:material_ui/material_ui.dart';
import '../../navigation/presentation/widgets/simple_page.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Resources',
      description: 'Keep your notes and learning materials organized.',
      icon: Icons.folder_rounded,
    );
  }
}
