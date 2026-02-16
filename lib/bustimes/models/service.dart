import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/_base_query.dart';
import 'package:route_log/bustimes/models/trip.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/api_has_fetched.dart';

class ServiceQuery implements BaseQuery {
  String? publicUse;
  String? mode;
  List<String>? modes; // mode__in
  String? slug;
  List<String>? slugs; // slug__in
  String? modifiedSince; // modified_at__gte
  List<String>? operator; // operator=NOC
  String? search;
  List<String>? stops;

  ServiceQuery({
    this.publicUse,
    this.mode,
    this.modes,
    this.slug,
    this.slugs,
    this.modifiedSince,
    this.operator,
    this.search,
    this.stops,
  });

  static const List<String> keys = [
    'public_use',
    'mode',
    'mode__in',
    'slug',
    'slug__in',
    'modified_at__gte',
    'operator',
    'search',
    'stops',
  ];

  @override
  Map<String, String> toMap() {
    final map = <String, String>{};
    if (publicUse != null) map['public_use'] = publicUse!;
    if (mode != null) map['mode'] = mode!;
    if (modes != null && modes!.isNotEmpty) map['mode__in'] = modes!.join(',');
    if (slug != null) map['slug'] = slug!;
    if (slugs != null && slugs!.isNotEmpty) map['slug__in'] = slugs!.join(',');
    if (modifiedSince != null) map['modified_at__gte'] = modifiedSince!;
    if (operator != null && operator!.isNotEmpty) {
      map['operator'] = operator!.join(',');
    }
    if (search != null) map['search'] = search!;
    if (stops != null && stops!.isNotEmpty) map['stops'] = stops!.join(',');
    return map;
  }

  @override
  factory ServiceQuery.fromMap(Map<String, dynamic> map) {
    List<String>? split(String key) {
      final value = map[key];
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return value.toString().split(',');
    }

    return ServiceQuery(
      publicUse: map['public_use']?.toString(),
      mode: map['mode']?.toString(),
      modes: split('mode__in'),
      slug: map['slug']?.toString(),
      slugs: split('slug__in'),
      modifiedSince: map['modified_at__gte']?.toString(),
      operator: split('operator'),
      search: map['search']?.toString(),
      stops: split('stops'),
    );
  }
}

class Service implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS service (
      id INTEGER PRIMARY KEY,
      slug TEXT NOT NULL,
      line_name TEXT NOT NULL,
      description TEXT NOT NULL,
      region_id TEXT,
      mode TEXT NOT NULL,
      operator TEXT NOT NULL,
      modified_at TEXT NOT NULL
    );
  ''';

  final int id;
  final String slug;
  final String lineName;
  final String description;
  final Region? region;
  final String mode;
  final List<String> operator;
  final String modifiedAt;

  Service({
    required this.id,
    required this.slug,
    required this.lineName,
    required this.description,
    required this.region,
    required this.mode,
    required this.operator,
    required this.modifiedAt,
  });

  @override
  factory Service.buildFromMap(Map<String, dynamic> json) {
    dynamic operatorsRaw = json['operator'];

    List<String> operatorsList;

    if (operatorsRaw is List) {
      operatorsList = operatorsRaw.map((e) => e.toString()).toList();
    } else if (operatorsRaw is String) {
      operatorsList = operatorsRaw.isNotEmpty ? operatorsRaw.split(',') : [];
    } else {
      operatorsList = [];
    }

    return Service(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      lineName: json['line_name'] ?? '',
      description: json['description'] ?? '',
      region:
          json['region_id'] == null
              ? null
              : Region.fromString(json['region_id']),
      mode: json['mode'] ?? '',
      operator: operatorsList,
      modifiedAt: json['modified_at'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slug': slug,
      'line_name': lineName,
      'description': description,
      'region_id': region?.name,
      'mode': mode,
      'operator': operator.join(','),
      'modified_at': modifiedAt,
    };
  }

  // ----- SQL Functions -----

  static Future<List<Service>> getAll() async {
    final db = await AppDatabase.instance.db;

    final rows = await db.query('service');

    return rows.map((row) => Service.buildFromMap(row)).toList();
  }

  static Future<List<Service>> getAllByNoc(String noc) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery(
      "SELECT * FROM service WHERE ',' || operator || ',' LIKE ?",
      ['%,$noc,%'],
    );

    return rows.map((row) => Service.buildFromMap(row)).toList();
  }

  // ----- API Functions -----

  static Future<List<Service>> getAllApi(
    ServiceQuery query,
    int offset, {
    bool refresh = false,
    bool fetchAll = false,
  }) async {
    return await ApiHasFetched.fullNew<Service>(
      ApiHasFetchedName.serviceQuery,
      "service_query_${query.toMap().toString()}",
      () async => await Service.getAll(),
      Service.buildFromMap,
      "services",
      offset,
      refresh: refresh,
      query: query.toMap(),
      insertInto: TableKey.service,
      getAll: fetchAll,
    );
  }

  Future<List<VehicleTrip>> getTrips(
    VehicleTripQuery query, {
    bool refresh = false,
  }) async {
    query.service = id;
    return await ApiManager.getAllPaginated(
      ApiOptions(
        endpoint: 'trips',
        fromMap: VehicleTrip.buildFromMap,
        query: {...query.toMap(), 'limit': '1000'},
      ),
    );
  }
}
