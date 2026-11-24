import 'package:material_ui/material_ui.dart';
import '../../navigation/presentation/widgets/simple_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Your Profile',
      description: 'Your learning identity and coding profiles.',
      icon: Icons.person_rounded,
    );
  }
}
