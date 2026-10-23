import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/section_card.dart';
import 'medications_screen.dart';
import 'records_screen.dart';
import 'visits_screen.dart';
import 'health_screen.dart';
import 'reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int records = 0, meds = 0, visits = 0, health = 0;
  Future<void> load() async {
    final db = DatabaseService.instance;
    records = (await db.records()).length;
    meds = (await db.medications()).length;
    visits = (await db.visits()).length;
    health = (await db.health()).length;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('MediNest'),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportsScreen()),
          ),
          icon: const Icon(Icons.picture_as_pdf),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Personal Medical Record',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep your medical history, medicines, appointments and measurements in one place.',
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _stat('Records', records, Icons.folder),
              _stat('Medicines', meds, Icons.medication),
              _stat('Visits', visits, Icons.local_hospital),
              _stat('Measurements', health, Icons.monitor_heart),
            ],
          ),
          const SizedBox(height: 14),
          SectionCard(
            title: 'Medical records',
            subtitle: 'Diseases, doctors, prescriptions and images',
            icon: Icons.medical_information,
            onTap: () => _openScreen(const RecordsScreen()),
          ),
          SectionCard(
            title: 'Medicine reminders',
            subtitle: 'Exact-time reminders and stock warnings',
            icon: Icons.alarm,
            onTap: () => _openScreen(const MedicationsScreen()),
          ),
          SectionCard(
            title: 'Clinic appointments',
            subtitle: '24-hour and appointment-time notifications',
            icon: Icons.event_available,
            onTap: () => _openScreen(const VisitsScreen()),
          ),
          SectionCard(
            title: 'Health graphs',
            subtitle: 'Weight, sugar and blood-pressure trends',
            icon: Icons.show_chart,
            onTap: () => _openScreen(const HealthScreen()),
          ),
          SectionCard(
            title: 'Monthly PDF report',
            subtitle: 'Filter a month and export a report',
            icon: Icons.picture_as_pdf,
            onTap: () => _openScreen(const ReportsScreen()),
          ),
        ],
      ),
    ),
  );

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) await load();
  }

  Widget _stat(String t, int n, IconData i) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(i, size: 28),
          const SizedBox(height: 10),
          Text(
            '$n',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(t),
        ],
      ),
    ),
  );
}
