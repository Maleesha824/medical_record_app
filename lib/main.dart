import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/records_screen.dart';
import 'screens/health_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final p = await SharedPreferences.getInstance();
  final dark = p.getBool('dark_mode') ?? false;
  runApp(MedicalApp(initialDark: dark));
}

class MedicalApp extends StatefulWidget {
  final bool initialDark;
  const MedicalApp({super.key, required this.initialDark});
  @override
  State<MedicalApp> createState() => _MedicalAppState();
}

class _MedicalAppState extends State<MedicalApp> with WidgetsBindingObserver {
  late bool dark;
  bool locked = false;
  @override
  void initState() {
    super.initState();
    dark = widget.initialDark;
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLock() async {
    if (await AuthService.enabled()) {
      setState(() => locked = true);
      final ok = await AuthService.authenticate();
      if (mounted && ok) setState(() => locked = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !locked) _checkLock();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My Health',
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: locked
        ? LockScreen(
            onUnlock: () {
              setState(() => locked = false);
            },
          )
        : AppShell(onThemeChanged: (v) => setState(() => dark = v)),
  );
  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xFFF7F9FC)
          : null,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}

class LockScreen extends StatelessWidget {
  final VoidCallback onUnlock;
  const LockScreen({super.key, required this.onUnlock});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 70),
            const SizedBox(height: 20),
            const Text(
              'Medical records locked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use your device PIN, pattern or biometrics to continue.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            FilledButton.icon(
              onPressed: () async {
                if (await AuthService.authenticate()) onUnlock();
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AppShell extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  const AppShell({super.key, required this.onThemeChanged});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final homeKey = GlobalKey<HomeScreenState>();
  late final List<Widget> screens;
  @override
  void initState() {
    super.initState();
    screens = [
      HomeScreen(key: homeKey),
      const MedicationsScreen(),
      const RecordsScreen(),
      const HealthScreen(),
      ProfileScreen(onDarkModeChanged: widget.onThemeChanged),
    ];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: index, children: screens),
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        setState(() => index = i);
        if (i == 0) homeKey.currentState?.load();
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.medication_outlined),
          selectedIcon: Icon(Icons.medication),
          label: 'Meds',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Records',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_heart_outlined),
          selectedIcon: Icon(Icons.monitor_heart),
          label: 'Health',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
    floatingActionButton: index == 0
        ? FloatingActionButton.small(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
            child: const Icon(Icons.picture_as_pdf),
          )
        : null,
  );
}
