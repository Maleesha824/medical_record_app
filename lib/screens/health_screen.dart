import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_models.dart';
import '../services/database_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  List<HealthMeasurement> data = [];
  final weight = TextEditingController();
  final sugar = TextEditingController();
  final pressure = TextEditingController();
  DateTime date = DateTime.now();
  Future<void> load() async { data = await DatabaseService.instance.health(); if (mounted) setState(() {}); }
  @override void initState() { super.initState(); load(); }

  Future<void> add() async {
    if (weight.text.isEmpty && sugar.text.isEmpty && pressure.text.isEmpty) return;
    await DatabaseService.instance.addHealth(HealthMeasurement(date: DateFormat('yyyy-MM-dd').format(date), weight: double.tryParse(weight.text), sugar: double.tryParse(sugar.text), pressure: pressure.text.trim().isEmpty ? null : pressure.text.trim()));
    weight.clear(); sugar.clear(); pressure.clear(); load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            ListTile(contentPadding: EdgeInsets.zero, title: const Text('Measurement date'), subtitle: Text(DateFormat('dd MMM yyyy').format(date)), leading: const Icon(Icons.calendar_today), onTap: () async { final d = await showDatePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100), initialDate: date); if (d != null) setState(() => date = d); }),
            _f(weight, 'Weight (kg)', Icons.monitor_weight_outlined),
            _f(sugar, 'Blood sugar', Icons.bloodtype_outlined),
            _f(pressure, 'Blood pressure (e.g. 120/80)', Icons.favorite_border),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: add, icon: const Icon(Icons.add), label: const Text('Save Measurement'))),
          ]))),
          if (data.isNotEmpty) ...[
            _chart('Weight (kg)', data.where((x) => x.weight != null).toList(), (x) => x.weight!),
            _chart('Blood Sugar', data.where((x) => x.sugar != null).toList(), (x) => x.sugar!),
            _bpChart(),
          ],
        ],
      ),
    );
  }

  Widget _f(TextEditingController c, String l, IconData i) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i))));

  Widget _chart(String title, List<HealthMeasurement> list, double Function(HealthMeasurement) value) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      SizedBox(height: 210, child: LineChart(LineChartData(
        minX: 0, maxX: list.length < 2 ? 1 : (list.length - 1).toDouble(),
        lineBarsData: [LineChartBarData(isCurved: true, spots: [for (int i = 0; i < list.length; i++) FlSpot(i.toDouble(), value(list[i]))])],
        titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      )))
    ])));
  }

  Widget _bpChart() {
    final list = data.where((x) => x.systolic != null && x.diastolic != null).toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Blood Pressure', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      SizedBox(height: 230, child: LineChart(LineChartData(
        minX: 0, maxX: list.length < 2 ? 1 : (list.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(isCurved: true, spots: [for (int i = 0; i < list.length; i++) FlSpot(i.toDouble(), list[i].systolic!)]),
          LineChartBarData(isCurved: true, spots: [for (int i = 0; i < list.length; i++) FlSpot(i.toDouble(), list[i].diastolic!)]),
        ],
        titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      )))
    ])));
  }
}
