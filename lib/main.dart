import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PrepSpaceApp(),
    ),
  );
}

class PrepSpaceApp extends StatelessWidget {
  const PrepSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrepSpace',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
