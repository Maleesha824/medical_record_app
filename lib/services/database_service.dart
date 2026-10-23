import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/medical_models.dart';

class DatabaseService {
  static final instance = DatabaseService._();
  DatabaseService._();
  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'medical_records_v2.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async => _create(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE medications ADD COLUMN stock INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE medications ADD COLUMN lowStockThreshold INTEGER NOT NULL DEFAULT 3',
          );
          await db.execute(
            'ALTER TABLE medications ADD COLUMN customIntervalHours INTEGER NOT NULL DEFAULT 6',
          );
        }
      },
    );
  }

  Future<void> _create(Database db) async {
    await db.execute(
      'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT,disease TEXT,date TEXT,notes TEXT,doctor TEXT,prescriptionText TEXT,imagePath TEXT)',
    );
    await db.execute(
      'CREATE TABLE medications(id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT,dosage TEXT,disease TEXT,startDate TEXT,frequency TEXT,firstTime TEXT,durationDays INTEGER,active INTEGER,stock INTEGER NOT NULL DEFAULT 0,lowStockThreshold INTEGER NOT NULL DEFAULT 3,customIntervalHours INTEGER NOT NULL DEFAULT 6)',
    );
    await db.execute(
      'CREATE TABLE visits(id INTEGER PRIMARY KEY AUTOINCREMENT,clinic TEXT,date TEXT,time TEXT,reason TEXT,diagnosis TEXT,doctor TEXT,prescription TEXT)',
    );
    await db.execute(
      'CREATE TABLE health(id INTEGER PRIMARY KEY AUTOINCREMENT,date TEXT,weight REAL,sugar REAL,pressure TEXT)',
    );
  }

  Future<int> addRecord(MedicalRecord x) async =>
      (await db).insert('records', x.toMap());
  Future<int> updateRecord(MedicalRecord x) async {
    final values = x.toMap()..remove('id');
    return (await db).update(
      'records',
      values,
      where: 'id=?',
      whereArgs: [x.id],
    );
  }

  Future<List<MedicalRecord>> records({String? month}) async {
    final rows = await (await db).query(
      'records',
      where: month == null ? null : 'date LIKE ?',
      whereArgs: month == null ? null : ['$month%'],
      orderBy: 'date DESC',
    );
    return rows.map(MedicalRecord.fromMap).toList();
  }

  Future<int> deleteRecord(int id) async =>
      (await db).delete('records', where: 'id=?', whereArgs: [id]);

  Future<int> addMedication(Medication x) async =>
      (await db).insert('medications', x.toMap());
  Future<List<Medication>> medications() async => (await (await db).query(
    'medications',
    orderBy: 'id DESC',
  )).map(Medication.fromMap).toList();
  Future<int> deleteMedication(int id) async =>
      (await db).delete('medications', where: 'id=?', whereArgs: [id]);
  Future<void> updateMedicationStock(int id, int stock) async =>
      (await db).update(
        'medications',
        {'stock': stock < 0 ? 0 : stock},
        where: 'id=?',
        whereArgs: [id],
      );

  Future<int> addVisit(ClinicVisit x) async =>
      (await db).insert('visits', x.toMap());
  Future<List<ClinicVisit>> visits({String? month}) async {
    final rows = await (await db).query(
      'visits',
      where: month == null ? null : 'date LIKE ?',
      whereArgs: month == null ? null : ['$month%'],
      orderBy: 'date DESC,time DESC',
    );
    return rows.map(ClinicVisit.fromMap).toList();
  }

  Future<int> deleteVisit(int id) async =>
      (await db).delete('visits', where: 'id=?', whereArgs: [id]);

  Future<int> addHealth(HealthMeasurement x) async =>
      (await db).insert('health', x.toMap());
  Future<List<HealthMeasurement>> health({String? month}) async {
    final rows = await (await db).query(
      'health',
      where: month == null ? null : 'date LIKE ?',
      whereArgs: month == null ? null : ['$month%'],
      orderBy: 'date ASC',
    );
    return rows.map(HealthMeasurement.fromMap).toList();
  }
}
