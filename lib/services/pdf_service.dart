import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/medical_models.dart';

class PdfService {
  static Future<void> generate({required String month, required List<MedicalRecord> records, required List<Medication> medicines, required List<ClinicVisit> visits, required List<HealthMeasurement> health}) async {
    final pdf = pw.Document();
    final titleMonth = DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'));
    final imageWidgets = <pw.Widget>[];
    for (final r in records) {
      if (r.imagePath != null && File(r.imagePath!).existsSync()) {
        imageWidgets.add(pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text('${r.date} - ${r.disease.isEmpty ? r.title : r.disease}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 5), pw.Image(pw.MemoryImage(File(r.imagePath!).readAsBytesSync()), height: 180), pw.SizedBox(height: 10)]));
      }
    }
    pdf.addPage(pw.MultiPage(build: (_) => [
      pw.Header(level: 0, text: 'Personal Medical Report'),
      pw.Text('Month: $titleMonth'), pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}'), pw.SizedBox(height: 15),
      pw.Header(level: 1, text: 'Medical Records'),
      if (records.isEmpty) pw.Text('No records in this month.'),
      ...records.map((r) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Text('${r.date} | ${r.disease.isEmpty ? r.title : r.disease}${r.doctor.isEmpty ? '' : ' | Dr. ${r.doctor}'}\n${r.prescriptionText.isEmpty ? '' : 'Prescription: ${r.prescriptionText}'}\n${r.notes.isEmpty ? '' : 'Notes: ${r.notes}'}'))),
      if (imageWidgets.isNotEmpty) ...[pw.Header(level: 2, text: 'Prescription Images'), ...imageWidgets],
      pw.Header(level: 1, text: 'Medications'),
      if (medicines.isEmpty) pw.Text('No medications started in this month.'),
      ...medicines.map((m) => pw.Text('${m.name} | ${m.dosage} | ${m.frequency} | Stock: ${m.stock}')),
      pw.Header(level: 1, text: 'Clinic Visits'),
      if (visits.isEmpty) pw.Text('No clinic visits in this month.'),
      ...visits.map((v) => pw.Text('${v.date} ${v.time} | ${v.clinic} | ${v.diagnosis} | ${v.doctor}')),
      pw.Header(level: 1, text: 'Health Measurements'),
      if (health.isEmpty) pw.Text('No measurements in this month.'),
      ...health.map((h) => pw.Text('${h.date} | Weight: ${h.weight ?? '-'} kg | Sugar: ${h.sugar ?? '-'} | BP: ${h.pressure ?? '-'}')),
    ]));
    await Printing.layoutPdf(onLayout: (_) async => pdf.save(), name: 'medical_report_$month.pdf');
  }
}
