import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/_base_query.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/api_has_fetched.dart';

class OperatorQuery implements BaseQuery {
  String? nameContains;
  String? name;
  String? slug;
  String? vehicleMode;
  String? region;

  OperatorQuery({
    this.nameContains,
    this.name,
    this.slug,
    this.vehicleMode,
    this.region,
  });

  static const List<String> keys = [
    'name__icontains',
    'name',
    'slug',
    'vehicle_mode',
    'region',
  ];

  @override
  Map<String, String> toMap() {
    final map = <String, String>{};

    if (nameContains != null) map['name__icontains'] = nameContains!;
    if (name != null) map['name'] = name!;
    if (slug != null) map['slug'] = slug!;
    if (vehicleMode != null) map['vehicle_mode'] = vehicleMode!;
    if (region != null) map['region'] = region!;

    return map;
  }

  @override
  factory OperatorQuery.buildFromMap(Map<String, dynamic> map) {
    return OperatorQuery(
      nameContains: map['name__icontains']?.toString(),
      name: map['name']?.toString(),
      slug: map['slug']?.toString(),
      vehicleMode: map['vehicle_mode']?.toString(),
      region: map['region']?.toString(),
    );
  }
}

class Operator implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS operator (
      noc TEXT PRIMARY KEY,
      slug TEXT NOT NULL,
      name TEXT NOT NULL,
      aka TEXT NOT NULL,
      vehicle_mode TEXT NOT NULL,
      region_id TEXT,
      parent TEXT NOT NULL,
      url TEXT NOT NULL,
      twitter TEXT NOT NULL
    );
  ''';

  final String noc;
  final String slug;
  final String name;
  final String aka;
  final String vehicleMode;
  final Region? region;
  final String parent;
  final String url;
  final String twitter;

  Operator({
    required this.noc,
    required this.slug,
    required this.name,
    required this.aka,
    required this.vehicleMode,
    required this.region,
    required this.parent,
    required this.url,
    required this.twitter,
  });

  @override
  factory Operator.buildFromMap(Map<String, dynamic> json) {
    return Operator(
      noc: json['noc'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      aka: json['aka']?.isNotEmpty == true ? json['aka'] : (json['name'] ?? ''),
      vehicleMode: json['vehicle_mode'] ?? '',
      region:
          json['region_id'] == null
              ? null
              : Region.fromString(json['region_id']),
      parent: json['parent'] ?? '',
      url: json['url'] ?? '',
      twitter: json['twitter'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'noc': noc,
      'slug': slug,
      'name': name,
      'aka': aka,
      'vehicle_mode': vehicleMode,
      'region_id': region?.name,
      'parent': parent,
      'url': url,
      'twitter': twitter,
    };
  }

  static Map<String, Operator> cache = {};

  static Future<void> updateCache() async {
    final operators = await Operator.getAll();

    cache = {for (final operator in operators) operator.noc: operator};
  }

  String safeName() {
    List<String> names = [name, aka, slug, noc, "Unknown Operator"];
    return names.firstWhere((x) => x.isNotEmpty);
  }

  // ----- SQL Functions -----

  static Future<List<Operator>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('operator');

    return rows.map((row) => Operator.buildFromMap(row)).toList();
  }

  // ----- API Functions -----

  static Future<List<Operator>> getAllApi({bool refresh = false}) async {
    await Operator.updateCache();
    return ApiHasFetched.full(
      ApiHasFetchedName.operators,
      "",
      () => Operator.getAll(),
      () => ApiManager.getAllPaginated<Operator>(
        ApiOptions(
          endpoint: 'operators',
          query: {'limit': '1000'},
          fromMap: Operator.buildFromMap,
        ),
      ),
      updateCache: Operator.updateCache,
      insertInto: TableKey.operator,
      skip: refresh,
    );
  }

  Future<List<Vehicle>> getVehicles(
    VehicleQuery query,
    int offset, {
    bool refresh = false,
    bool fetchAll = false,
  }) async {
    query.operator = noc;

    return await ApiHasFetched.fullNew(
      ApiHasFetchedName.operatorVehicles,
      "operator_vehicles_${query.toMap().toString()}",
      () async => await Vehicle.getAllByNoc(noc),
      Vehicle.buildFromMap,
      "vehicles",
      offset,
      query: query.toMap(),
      insertInto: TableKey.vehicle,
      refresh: refresh,
      getAll: fetchAll,
    );
  }

  Future<List<Service>> getServices(
    ServiceQuery query,
    int offset, {
    bool refresh = false,
    bool fetchAll = false,
  }) async {
    query.operator = [noc];

    return await ApiHasFetched.fullNew(
      ApiHasFetchedName.operatorRoutes,
      noc,
      () async => await Service.getAllByNoc(noc),
      Service.buildFromMap,
      "services",
      offset,
      query: query.toMap(),
      insertInto: TableKey.service,
      refresh: refresh,
      getAll: fetchAll,
    );
  }
}
