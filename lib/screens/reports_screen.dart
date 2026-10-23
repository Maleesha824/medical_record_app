import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime selected;
  bool busy = false;
  @override void initState() { super.initState(); selected = DateTime(DateTime.now().year, DateTime.now().month); }

  Future<void> generate() async {
    setState(() => busy = true);
    final month = DateFormat('yyyy-MM').format(selected);
    final db = DatabaseService.instance;
    final records = await db.records(month: month);
    final visits = await db.visits(month: month);
    final health = await db.health(month: month);
    final allMeds = await db.medications();
    final meds = allMeds.where((m) => m.startDate.startsWith(month)).toList();
    await PdfService.generate(month: month, records: records, medicines: meds, visits: visits, health: health);
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final months = List.generate(13, (i) => DateTime(DateTime.now().year, DateTime.now().month - i));
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Reports')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text('Monthly Medical Report', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Choose a month and create a PDF containing only records, visits and health measurements from that month.'),
          const SizedBox(height: 22),
          DropdownButtonFormField<DateTime>(
            initialValue: selected,
            decoration: const InputDecoration(labelText: 'Report month', prefixIcon: Icon(Icons.calendar_month)),
            items: [for (final d in months) DropdownMenuItem(value: d, child: Text(DateFormat('MMMM yyyy').format(d)))],
            onChanged: (v) { if (v != null) setState(() => selected = v); },
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.picture_as_pdf)),
              title: Text('PDF • ${DateFormat('MMMM yyyy').format(selected)}'),
              subtitle: const Text('Preview, save or share'),
              trailing: busy ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator()) : const Icon(Icons.chevron_right),
              onTap: busy ? null : generate,
            ),
          ),
        ],
      ),
    );
  }
}
