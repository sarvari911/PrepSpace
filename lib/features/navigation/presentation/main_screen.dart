import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../tracker/presentation/tracker_screen.dart';
import '../../spaces/presentation/spaces_screen.dart';
import '../../resources/presentation/resources_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../tracker/presentation/providers/tracker_providers.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const List<Widget> pages = [
    DashboardScreen(),
    TrackerScreen(),
    SpacesScreen(),
    ResourcesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).setIndex(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            label: 'Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Spaces',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
