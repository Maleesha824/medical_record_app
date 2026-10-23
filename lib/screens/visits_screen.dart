import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'add_visit_screen.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});
  @override State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<ClinicVisit> visits = [];
  Future<void> load() async {
    visits = await DatabaseService.instance.visits();
    if (mounted) setState(() {});
  }
  @override void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Visits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVisitScreen()));
          if (ok == true) load();
        },
        child: const Icon(Icons.add),
      ),
      body: visits.isEmpty
          ? const Center(child: Text('No clinic visits recorded.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: visits.length,
              itemBuilder: (_, i) {
                final v = visits[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.local_hospital)),
                    title: Text(v.clinic, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${DateFormat('dd MMM yyyy').format(DateTime.parse(v.date))} • ${v.time}'
                      '${v.doctor.isEmpty ? '' : ' • Dr. ${v.doctor}'}'
                      '${v.reason.isEmpty ? '' : '\n${v.reason}'}',
                    ),
                    isThreeLine: true,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(shrinkWrap: true, children: [
                          Text(v.clinic, style: Theme.of(context).textTheme.headlineSmall),
                          Text('${v.date} ${v.time}'),
                          if (v.diagnosis.isNotEmpty) Text('Diagnosis: ${v.diagnosis}'),
                          if (v.prescription.isNotEmpty) Text('Prescription: ${v.prescription}'),
                        ]),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await NotificationService.cancelAppointment(v.id!);
                        await DatabaseService.instance.deleteVisit(v.id!);
                        load();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
