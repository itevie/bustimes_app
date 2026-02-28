import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:sqflite/sqflite.dart';

enum ChecklistItemType {
  service, // 0
  vehicle, // 1
}

extension ChecklistItemTypeExt on ChecklistItemType {
  int get value => index;

  static ChecklistItemType fromInt(int value) {
    if (value < 0 || value >= ChecklistItemType.values.length) {
      return ChecklistItemType.service;
    }
    return ChecklistItemType.values[value];
  }
}

class RouteChecklistItem implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS route_checklist_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      checklist_id INTEGER NOT NULL,
      entity_id INTEGER NOT NULL,
      item_type INTEGER NOT NULL, -- 0 = Service, 1 = Vehicle
      done INTEGER NOT NULL DEFAULT 0,
      note TEXT,
      completed_at TEXT,
      is_from TEXT,
      added_at TEXT NOT NULL,
      UNIQUE (checklist_id, entity_id, item_type)
    );
  ''';

  final int id;
  final int checklistId;
  final int entityId;
  final ChecklistItemType itemType;
  final bool done;
  final String? note;
  final String? isFrom;
  final DateTime? completedAt;
  final DateTime addedAt;

  RouteChecklistItem({
    required this.id,
    required this.checklistId,
    required this.entityId,
    required this.itemType,
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
      entityId: map['entity_id'] ?? 0,
      itemType: ChecklistItemTypeExt.fromInt(map['item_type'] ?? 0),
      done: (map['done'] ?? 0) == 1,
      note: map['note'],
      completedAt:
          map['completed_at'] != null
              ? DateTime.parse(map['completed_at'])
              : null,
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
      'entity_id': entityId,
      'item_type': itemType.value,
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
    final items = await RouteChecklistItem.getAll();
    cache = {for (final item in items) item.id: item};
  }

  // -----------------------------
  // Basic Queries
  // -----------------------------

  static Future<List<RouteChecklistItem>> getAll() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('route_checklist_item');
    return rows.map((x) => RouteChecklistItem.buildFromMap(x)).toList();
  }

  static Future<List<RouteChecklistItem>> getAllForChecklist(
    int checklistId,
  ) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query(
      'route_checklist_item',
      where: "checklist_id = ?",
      whereArgs: [checklistId],
    );

    return rows.map((x) => RouteChecklistItem.buildFromMap(x)).toList();
  }

  // -----------------------------
  // Insert Helpers
  // -----------------------------

  static Future<void> insertService(
    int checklistId,
    Service service, {
    String? isFrom,
  }) async {
    final db = await AppDatabase.instance.db;

    await db.insert('route_checklist_item', {
      'checklist_id': checklistId,
      'entity_id': service.id,
      'item_type': ChecklistItemType.service.value,
      'added_at': DateTime.now().toIso8601String(),
      'is_from': isFrom,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await updateCache();
  }

  static Future<void> insertVehicle(
    int checklistId,
    Vehicle vehicle, {
    String? isFrom,
  }) async {
    final db = await AppDatabase.instance.db;

    await db.insert('route_checklist_item', {
      'checklist_id': checklistId,
      'entity_id': vehicle.id,
      'item_type': ChecklistItemType.vehicle.value,
      'added_at': DateTime.now().toIso8601String(),
      'is_from': isFrom,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await updateCache();
  }

  static Future<void> insertServicesFromOperator(
    int checklistId,
    Operator operator, {
    bool Function(Service service)? filter,
  }) async {
    final services = await Service.getAllApi(
      ServiceQuery(operator: [operator.noc]),
      0,
      fetchAll: true,
    );

    for (final service in services) {
      if (filter != null && !filter(service)) continue;

      await insertService(checklistId, service, isFrom: "op_${operator.noc}");
    }
  }

  // -----------------------------
  // Completion Toggle
  // -----------------------------

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

  Future<CombinedRouteChecklistItem> getCombined() async {
    return CombinedRouteChecklistItem(
      item: this,
      entity: await resolveEntity(),
    );
  }

  Future<dynamic> resolveEntity() async {
    switch (itemType) {
      case ChecklistItemType.service:
        return await Service.getById(entityId);
      case ChecklistItemType.vehicle:
        return await Vehicle.getById(entityId);
    }
  }
}

class CombinedRouteChecklistItem implements BaseModel {
  final RouteChecklistItem item;
  final dynamic entity; // Service or Vehicle

  CombinedRouteChecklistItem({required this.item, required this.entity});

  @override
  Map<String, dynamic> toMap() {
    return {'item': item.toMap(), 'entity': entity.toMap()};
  }
}
