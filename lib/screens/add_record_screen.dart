import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';
import '../services/image_service.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key, this.record});
  final MedicalRecord? record;
  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final title = TextEditingController(),
      disease = TextEditingController(),
      doctor = TextEditingController(),
      notes = TextEditingController(),
      prescription = TextEditingController();
  late DateTime date;
  String? imagePath;
  @override
  void initState() {
    super.initState();
    final record = widget.record;
    date = DateTime.tryParse(record?.date ?? '') ?? DateTime.now();
    if (record != null) {
      title.text = record.title;
      disease.text = record.disease;
      doctor.text = record.doctor;
      notes.text = record.notes;
      prescription.text = record.prescriptionText;
      imagePath = record.imagePath;
    }
  }

  @override
  void dispose() {
    title.dispose();
    disease.dispose();
    doctor.dispose();
    notes.dispose();
    prescription.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (disease.text.trim().isEmpty && title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a record title or disease / condition.'),
        ),
      );
      return;
    }
    final record = MedicalRecord(
      id: widget.record?.id,
      title: title.text.trim().isEmpty ? 'Medical Record' : title.text.trim(),
      disease: disease.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(date),
      doctor: doctor.text.trim(),
      notes: notes.text.trim(),
      prescriptionText: prescription.text.trim(),
      imagePath: imagePath,
    );
    try {
      if (widget.record == null) {
        await DatabaseService.instance.addRecord(record);
      } else {
        await DatabaseService.instance.updateRecord(record);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save medical record: $error')),
        );
      }
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.record == null ? 'Add Medical Record' : 'Edit Medical Record',
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _f(title, 'Record title', Icons.description),
        _f(disease, 'Disease / condition', Icons.healing),
        _f(doctor, 'Doctor name (optional)', Icons.person),
        _f(notes, 'Notes', Icons.notes, max: 4),
        _f(
          prescription,
          'Prescription / receipt text',
          Icons.receipt_long,
          max: 5,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: const Text('Record date'),
          subtitle: Text(DateFormat('dd MMM yyyy').format(date)),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: date,
            );
            if (d != null) setState(() => date = d);
          },
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: () async {
            final path = await ImageService.pickPrescriptionImage();
            if (path != null) setState(() => imagePath = path);
          },
          icon: const Icon(Icons.image_outlined),
          label: Text(
            imagePath == null
                ? 'Attach prescription image'
                : 'Change prescription image',
          ),
        ),
        if (imagePath != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(File(imagePath!), height: 220, fit: BoxFit.cover),
          ),
          TextButton.icon(
            onPressed: () => setState(() => imagePath = null),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove image'),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: save,
          icon: const Icon(Icons.save),
          label: Text(
            widget.record == null ? 'Save Medical Record' : 'Save Changes',
          ),
        ),
      ],
    ),
  );
  Widget _f(TextEditingController c, String l, IconData i, {int max = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: max,
          decoration: InputDecoration(labelText: l, prefixIcon: Icon(i)),
        ),
      );
}
