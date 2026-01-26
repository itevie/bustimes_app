import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/operator.dart';

class FavouriteOperator {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS favourite_operator (
      noc TEXT PRIMARY KEY REFERENCES operator(noc),
      added_at TEXT NOT NULL
    );
  ''';

  String noc;
  DateTime addedAt;

  FavouriteOperator({required this.noc, required this.addedAt});

  factory FavouriteOperator.fromMap(Map<String, dynamic> map) {
    return FavouriteOperator(
      noc: map['noc'],
      addedAt:
          map['added_at'] != null
              ? DateTime.parse(map['added_at'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'noc': noc, 'added_at': addedAt.toIso8601String()};
  }

  static Map<String, FavouriteOperator> cache = {};

  static Future<void> updateCache() async {
    final operators = await FavouriteOperator.getAll();

    cache = {for (final operator in operators) operator.noc: operator};
  }

  // ----- SQL Functions -----
  static Future<List<FavouriteOperator>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('favourite_operator');

    return rows.map((row) => FavouriteOperator.fromMap(row)).toList();
  }

  static Future<List<Operator>> getAllAsObject() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery('''
      SELECT * FROM operator WHERE noc IN (SELECT noc FROM favourite_operator)
    ''');

    return rows.map((row) => Operator.buildFromMap(row)).toList();
  }

  static Future<bool> update(String noc) async {
    final db = await AppDatabase.instance.db;

    if (FavouriteOperator.cache.containsKey(noc)) {
      await db.delete('favourite_operator', where: 'noc = ?', whereArgs: [noc]);
      await FavouriteOperator.updateCache();
      return false;
    } else {
      await db.insert('favourite_operator', {
        'noc': noc,
        'added_at': DateTime.now().toIso8601String(),
      });
      await FavouriteOperator.updateCache();
      return true;
    }
  }
}
