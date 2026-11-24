import 'package:material_ui/material_ui.dart';
import '../../navigation/presentation/widgets/simple_page.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Study Spaces',
      description: 'Learn together. Create a space or join your friends.',
      icon: Icons.groups_rounded,
    );
  }
}
