import 'package:flutter/material.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Medication> meds = [];
  Future<void> load() async {
    meds = await DatabaseService.instance.medications();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicines')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
          );
          if (ok == true) load();
        },
        child: const Icon(Icons.add),
      ),
      body: meds.isEmpty
          ? const Center(child: Text('No medicines added.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: meds.length,
              itemBuilder: (_, i) {
                final m = meds[i];
                final low = m.stock <= m.lowStockThreshold;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.medication),
                          ),
                          title: Text(
                            m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${m.dosage.isEmpty ? '' : '${m.dosage} • '}${m.frequency}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Delete medicine',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteMedication(m),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              low ? Icons.warning_amber : Icons.inventory_2,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Stock: ${m.stock}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: low
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _changeStock(m, -1),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            IconButton(
                              onPressed: () => _changeStock(m, 1),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        if (low)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Low stock warning',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _deleteMedication(Medication medication) async {
    final id = medication.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This medicine cannot be deleted because it has no database ID.',
          ),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete medicine?'),
        content: Text('Delete ${medication.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final deleted = await DatabaseService.instance.deleteMedication(id);
      if (!mounted) return;
      if (deleted == 0) {
        await load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medicine was not found and could not be deleted.'),
            ),
          );
        }
        return;
      }
      setState(() => meds.removeWhere((item) => item.id == id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete medicine: $error')),
        );
      }
      return;
    }

    try {
      await NotificationService.cancelMedicine(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Medicine deleted.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medicine deleted, but its reminders could not be cancelled: $error',
            ),
          ),
        );
      }
    }
  }

  Future<void> _changeStock(Medication m, int delta) async {
    await DatabaseService.instance.updateMedicationStock(
      m.id!,
      m.stock + delta,
    );
    load();
  }
}
