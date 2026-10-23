import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import 'add_record_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<MedicalRecord> all = [];
  String query = '';
  Future<void> load() async { all = await DatabaseService.instance.records(); if (mounted) setState(() {}); }
  @override void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final list = all.where((r) {
      final q = query.toLowerCase();
      return r.title.toLowerCase().contains(q) || r.disease.toLowerCase().contains(q) || r.doctor.toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Records')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { final ok = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRecordScreen())); if (ok == true) load(); },
        child: const Icon(Icons.add),
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 10), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search disease, doctor or record'))),
        Expanded(
          child: list.isEmpty ? const Center(child: Text('No medical records yet.')) : ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: r.imagePath != null && File(r.imagePath!).existsSync() ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(r.imagePath!), width: 52, height: 52, fit: BoxFit.cover)) : const CircleAvatar(child: Icon(Icons.medical_information)),
                  title: Text(r.disease.isEmpty ? r.title : r.disease, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${DateFormat('dd MMM yyyy').format(DateTime.parse(r.date))}${r.doctor.isEmpty ? '' : ' • Dr. ${r.doctor}'}'),
                  onTap: () => _details(r),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async { await DatabaseService.instance.deleteRecord(r.id!); load(); }),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _details(MedicalRecord r) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(shrinkWrap: true, children: [
        Text(r.disease.isEmpty ? r.title : r.disease, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(DateFormat('dd MMM yyyy').format(DateTime.parse(r.date))),
        if (r.doctor.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Doctor: ${r.doctor}')),
        if (r.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Notes: ${r.notes}')),
        if (r.prescriptionText.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Prescription: ${r.prescriptionText}')),
        if (r.imagePath != null && File(r.imagePath!).existsSync()) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showDialog(context: context, builder: (_) => Dialog(child: InteractiveViewer(child: Image.file(File(r.imagePath!))))),
            child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(r.imagePath!), height: 260, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 5),
          const Center(child: Text('Tap image to zoom')),
        ],
      ]),
    ),
  );
}
