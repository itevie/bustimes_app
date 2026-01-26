import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/_base_model.dart';

class RouteChecklist implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS route_checklist (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  ''';

  final int id;
  final String name;
  final DateTime createdAt;

  RouteChecklist({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  factory RouteChecklist.buildFromMap(Map<String, dynamic> map) {
    return RouteChecklist(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }

  static Map<int, RouteChecklist> cache = {};

  static Future<void> updateCache() async {
    final checklists = await RouteChecklist.getAll();

    cache = {for (final checklist in checklists) checklist.id: checklist};
  }

  RouteChecklist clone() {
    return RouteChecklist.buildFromMap(toMap());
  }

  // ----- SQL Functions -----
  static Future<List<RouteChecklist>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('route_checklist');

    return rows.map((x) => RouteChecklist.buildFromMap(x)).toList();
  }

  static Future<int> makeNew(String name) async {
    final db = await AppDatabase.instance.db;

    final id = await db.insert('route_checklist', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });

    await updateCache();

    return id;
  }
}
