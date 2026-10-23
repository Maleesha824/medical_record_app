class MedicalRecord {
  int? id;
  String title;
  String disease;
  String date;
  String notes;
  String doctor;
  String prescriptionText;
  String? imagePath;

  MedicalRecord({this.id, required this.title, required this.disease, required this.date, this.notes = '', this.doctor = '', this.prescriptionText = '', this.imagePath});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'disease': disease, 'date': date, 'notes': notes, 'doctor': doctor, 'prescriptionText': prescriptionText, 'imagePath': imagePath};
  factory MedicalRecord.fromMap(Map<String, dynamic> m) => MedicalRecord(id: m['id'], title: m['title'] ?? '', disease: m['disease'] ?? '', date: m['date'] ?? '', notes: m['notes'] ?? '', doctor: m['doctor'] ?? '', prescriptionText: m['prescriptionText'] ?? '', imagePath: m['imagePath']);
}

class Medication {
  int? id;
  String name;
  String dosage;
  String disease;
  String startDate;
  String frequency;
  String firstTime;
  int durationDays;
  bool active;
  int stock;
  int lowStockThreshold;
  int customIntervalHours;

  Medication({this.id, required this.name, required this.dosage, this.disease = '', required this.startDate, required this.frequency, required this.firstTime, this.durationDays = 7, this.active = true, this.stock = 0, this.lowStockThreshold = 3, this.customIntervalHours = 6});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'dosage': dosage, 'disease': disease, 'startDate': startDate, 'frequency': frequency, 'firstTime': firstTime, 'durationDays': durationDays, 'active': active ? 1 : 0, 'stock': stock, 'lowStockThreshold': lowStockThreshold, 'customIntervalHours': customIntervalHours};
  factory Medication.fromMap(Map<String, dynamic> m) => Medication(id: m['id'], name: m['name'] ?? '', dosage: m['dosage'] ?? '', disease: m['disease'] ?? '', startDate: m['startDate'] ?? '', frequency: m['frequency'] ?? '', firstTime: m['firstTime'] ?? '08:00', durationDays: m['durationDays'] ?? 7, active: (m['active'] ?? 1) == 1, stock: m['stock'] ?? 0, lowStockThreshold: m['lowStockThreshold'] ?? 3, customIntervalHours: m['customIntervalHours'] ?? 6);
}

class ClinicVisit {
  int? id;
  String clinic;
  String date;
  String time;
  String reason;
  String diagnosis;
  String doctor;
  String prescription;

  ClinicVisit({this.id, required this.clinic, required this.date, required this.time, this.reason = '', this.diagnosis = '', this.doctor = '', this.prescription = ''});
  Map<String, dynamic> toMap() => {'id': id, 'clinic': clinic, 'date': date, 'time': time, 'reason': reason, 'diagnosis': diagnosis, 'doctor': doctor, 'prescription': prescription};
  factory ClinicVisit.fromMap(Map<String, dynamic> m) => ClinicVisit(id: m['id'], clinic: m['clinic'] ?? '', date: m['date'] ?? '', time: m['time'] ?? '', reason: m['reason'] ?? '', diagnosis: m['diagnosis'] ?? '', doctor: m['doctor'] ?? '', prescription: m['prescription'] ?? '');
}

class HealthMeasurement {
  int? id;
  String date;
  double? weight;
  double? sugar;
  String? pressure;
  HealthMeasurement({this.id, required this.date, this.weight, this.sugar, this.pressure});
  Map<String, dynamic> toMap() => {'id': id, 'date': date, 'weight': weight, 'sugar': sugar, 'pressure': pressure};
  factory HealthMeasurement.fromMap(Map<String, dynamic> m) => HealthMeasurement(id: m['id'], date: m['date'] ?? '', weight: m['weight'] == null ? null : (m['weight'] as num).toDouble(), sugar: m['sugar'] == null ? null : (m['sugar'] as num).toDouble(), pressure: m['pressure']);

  double? get systolic => _bpPart(0);
  double? get diastolic => _bpPart(1);
  double? _bpPart(int index) {
    if (pressure == null || !pressure!.contains('/')) return null;
    final parts = pressure!.split('/');
    if (parts.length != 2) return null;
    return double.tryParse(parts[index].trim());
  }
}
