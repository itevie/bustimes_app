import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:sqflite/sqflite.dart';

class RouteChecklistItem implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS route_checklist_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      checklist_id INTEGER NOT NULL,
      service_id INTEGER NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      note TEXT,
      completed_at TEXT,
      is_from TEXT,
      added_at TEXT NOT NULL,
      UNIQUE (checklist_id, service_id)
    );
  ''';

  final int id;
  final int checklistId;
  final int serviceId;
  final bool done;
  final String? note;
  final String? isFrom;
  final DateTime? completedAt;
  final DateTime addedAt;

  RouteChecklistItem({
    required this.id,
    required this.checklistId,
    required this.serviceId,
    required this.done,
    this.note,
    this.isFrom,
    this.completedAt,
    required this.addedAt,
  });

  @override
  factory RouteChecklistItem.buildFromMap(Map<String, dynamic> map) {
    return RouteChecklistItem(
      id: map['id'] ?? 0,
      checklistId: map['checklist_id'] ?? 0,
      serviceId: map['service_id'] ?? 0,
      done: (map['done'] ?? 0) == 1,
      note: map['note'],
      completedAt: DateTime.parse(
        map['completed_at'] ?? DateTime.now().toIso8601String(),
      ),
      addedAt: DateTime.parse(
        map['added_at'] ?? DateTime.now().toIso8601String(),
      ),
      isFrom: map['is_from'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklist_id': checklistId,
      'service_id': serviceId,
      'done': done ? 1 : 0,
      'note': note,
      'completed_at': completedAt?.toIso8601String(),
      'added_at': addedAt.toIso8601String(),
      'is_from': isFrom,
    };
  }

  RouteChecklistItem clone() {
    return RouteChecklistItem.buildFromMap(toMap());
  }

  static Map<int, RouteChecklistItem> cache = {};

  static Future<void> updateCache() async {
    final checklists = await RouteChecklistItem.getAll();

    cache = {for (final checklist in checklists) checklist.id: checklist};
  }

  static Future<List<RouteChecklistItem>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('route_checklist_item');

    return rows.map((x) => RouteChecklistItem.buildFromMap(x)).toList();
  }

  static Future<List<CombinedRouteChecklistItem>> getAllWithService(
    int id,
  ) async {
    final db = await AppDatabase.instance.db;

    final itemRows = await db.query(
      'route_checklist_item',
      where: "checklist_id = ?",
      whereArgs: [id],
    );
    final items =
        itemRows.map((x) => RouteChecklistItem.buildFromMap(x)).toList();

    final serviceIds = items.map((i) => i.serviceId).toSet();

    if (serviceIds.isEmpty) return [];

    final placeholders = List.filled(serviceIds.length, '?').join(',');
    final serviceRows = await db.query(
      'service',
      where: 'id IN ($placeholders)',
      whereArgs: serviceIds.toList(),
    );

    final services = {
      for (final row in serviceRows)
        row['id'] as int: Service.buildFromMap(row),
    };

    return items
        .where((item) => services.containsKey(item.serviceId))
        .map(
          (item) => CombinedRouteChecklistItem(
            checkListItem: item,
            service: services[item.serviceId]!,
          ),
        )
        .toList();
  }

  static Future<void> insertFromOperator(
    int checkList,
    Service service,
    Operator operator,
  ) async {
    final db = await AppDatabase.instance.db;

    await db.insert('route_checklist_item', {
      'checklist_id': checkList,
      'service_id': service.id,
      'added_at': DateTime.now().toIso8601String(),
      'is_from': "op_${operator.noc}",
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await updateCache();
  }

  static Future<void> insertServicesFromOperator(
    int checkList,
    Operator operator, {
    bool Function(Service service)? filter,
  }) async {
    List<Service> services = await Service.getAllApi(
      ServiceQuery(operator: [operator.noc]),
    );

    for (final service in services) {
      if (filter != null && !filter(service)) continue;
      await RouteChecklistItem.insertFromOperator(checkList, service, operator);
    }
  }

  Future<bool> toggleComplete() async {
    final db = await AppDatabase.instance.db;

    final now = DateTime.now();

    final newDone = !RouteChecklistItem.cache[id]!.done;

    await db.update(
      'route_checklist_item',
      {
        'done': newDone ? 1 : 0,
        'completed_at': newDone ? now.toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    await RouteChecklistItem.updateCache();

    return newDone;
  }
}

class CombinedRouteChecklistItem implements BaseModel {
  Service service;
  RouteChecklistItem checkListItem;

  CombinedRouteChecklistItem({
    required this.service,
    required this.checkListItem,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'service': service.toMap(), 'item': checkListItem.toMap()};
  }
}
