import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/api_has_fetched.dart';

class Livery implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS livery (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      left_css TEXT NOT NULL,
      right_css TEXT NOT NULL,
      white_text INTEGER NOT NULL,
      text_colour TEXT NOT NULL,
      stroke_colour TEXT NOT NULL
    );
  ''';

  final int id;
  final String name;
  final String leftCss;
  final String rightCss;
  final bool whiteText;
  final String textColour;
  final String strokeColour;

  Livery({
    required this.id,
    required this.name,
    required this.leftCss,
    required this.rightCss,
    required this.whiteText,
    required this.textColour,
    required this.strokeColour,
  });

  @override
  factory Livery.buildFromMap(Map<String, dynamic> json) {
    return Livery(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      leftCss: json['left_css'] ?? '',
      rightCss: json['right_css'] ?? '',
      whiteText:
          json['white_text'] is bool
              ? json['white_text']
              : (json['white_text'] ?? 0) == 1,
      textColour: json['text_colour'] ?? '',
      strokeColour: json['stroke_colour'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'left_css': leftCss,
      'right_css': rightCss,
      'white_text': whiteText ? 1 : 0,
      'text_colour': textColour,
      'stroke_colour': strokeColour,
    };
  }

  static Map<int, Livery> cache = {};

  static Future<void> updateCache() async {
    final liveries = await Livery.getAll();

    cache = {for (final livery in liveries) livery.id: livery};
  }

  static Future<List<Livery>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('livery');

    return rows.map((row) => Livery.buildFromMap(row)).toList();
  }

  static Future<List<Livery>> getAllApi({bool force = false}) async {
    await Livery.updateCache();
    return ApiHasFetched.full(
      ApiHasFetchedName.liveries,
      "",
      () => Livery.getAll(),
      () => ApiManager.getAllPaginated<Livery>(
        ApiOptions(
          endpoint: 'liveries',
          query: {'limit': '1000'},
          fromMap: Livery.buildFromMap,
        ),
      ),
      updateCache: Livery.updateCache,
      insertInto: TableKey.livery,
      skip: force,
    );
  }

  Future<List<Vehicle>> getVehicles(
    VehicleQuery query, {
    bool refresh = false,
  }) async {
    query.livery = id;
    return await ApiHasFetched.full(
      ApiHasFetchedName.operatorVehicles,
      id.toString(),
      () async =>
          (await Vehicle.getAll()).where((v) => v.livery?.id == id).toList(),
      () async => await Vehicle.getAllApi(query),
      skip: refresh,
      insertInto: TableKey.vehicle,
    );
  }
}
