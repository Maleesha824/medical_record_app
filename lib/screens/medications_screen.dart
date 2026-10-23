import 'package:flutter/material.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Medication> meds = [];
  Future<void> load() async { meds = await DatabaseService.instance.medications(); if (mounted) setState(() {}); }
  @override void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      floatingActionButton: FloatingActionButton(onPressed: () async { final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationScreen())); if (ok == true) load(); }, child: const Icon(Icons.add)),
      body: meds.isEmpty ? const Center(child: Text('No medicines added.')) : ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: meds.length,
        itemBuilder: (_, i) {
          final m = meds[i];
          final low = m.stock <= m.lowStockThreshold;
          return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.medication)),
              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${m.dosage.isEmpty ? '' : '${m.dosage} • '}${m.frequency}'),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await NotificationService.cancelMedicine(m.id!); await DatabaseService.instance.deleteMedication(m.id!); load(); }),
            ),
            Row(children: [
              Icon(low ? Icons.warning_amber : Icons.inventory_2, size: 18), const SizedBox(width: 6),
              Text('Stock: ${m.stock}', style: TextStyle(fontWeight: FontWeight.w600, color: low ? Theme.of(context).colorScheme.error : null)),
              const Spacer(),
              IconButton(onPressed: () => _changeStock(m, -1), icon: const Icon(Icons.remove_circle_outline)),
              IconButton(onPressed: () => _changeStock(m, 1), icon: const Icon(Icons.add_circle_outline)),
            ]),
            if (low) Align(alignment: Alignment.centerLeft, child: Text('Low stock warning', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600))),
          ])));
        },
      ),
    );
  }
  Future<void> _changeStock(Medication m, int delta) async { await DatabaseService.instance.updateMedicationStock(m.id!, m.stock + delta); load(); }
}
