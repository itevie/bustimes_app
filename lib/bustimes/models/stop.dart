import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/api_manager.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/_base_query.dart';

class StopQuery implements BaseQuery {
  String? atcoCode;
  String? atcoCodeIexact;
  String? naptanCode;
  String? naptanCodeIexact;
  String? stopType;
  String? modifiedAtGte;
  bool? active;
  int? service;

  StopQuery({
    this.atcoCode,
    this.atcoCodeIexact,
    this.naptanCode,
    this.naptanCodeIexact,
    this.stopType,
    this.modifiedAtGte,
    this.active,
    this.service,
  });

  static const List<String> keys = [
    'atco_code',
    'atco_code__iexact',
    'naptan_code',
    'naptan_code__iexact',
    'stop_type',
    'modified_at__gte',
    'active',
    'service',
  ];

  @override
  Map<String, String> toMap() {
    final map = <String, String>{};

    if (atcoCode != null) map['atco_code'] = atcoCode!;
    if (atcoCodeIexact != null) {
      map['atco_code__iexact'] = atcoCodeIexact!;
    }
    if (naptanCode != null) map['naptan_code'] = naptanCode!;
    if (naptanCodeIexact != null) {
      map['naptan_code__iexact'] = naptanCodeIexact!;
    }
    if (stopType != null) map['stop_type'] = stopType!;
    if (modifiedAtGte != null) {
      map['modified_at__gte'] = modifiedAtGte!;
    }
    if (active != null) map['active'] = active! ? 'true' : 'false';
    if (service != null) map['service'] = service.toString();

    return map;
  }

  @override
  factory StopQuery.fromMap(Map<String, dynamic> map) {
    bool? parseBool(String key) {
      final v = map[key];
      if (v == null) return null;
      return v.toString() == 'true';
    }

    return StopQuery(
      atcoCode: map['atco_code']?.toString(),
      atcoCodeIexact: map['atco_code__iexact']?.toString(),
      naptanCode: map['naptan_code']?.toString(),
      naptanCodeIexact: map['naptan_code__iexact']?.toString(),
      stopType: map['stop_type']?.toString(),
      modifiedAtGte: map['modified_at__gte']?.toString(),
      active: parseBool('active'),
      service:
          map['service'] != null
              ? int.tryParse(map['service'].toString())
              : null,
    );
  }
}

class Stop implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS stop (
      atco_code TEXT PRIMARY KEY,
      naptan_code TEXT,
      common_name TEXT NOT NULL,
      name TEXT NOT NULL,
      long_name TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      indicator TEXT,
      icon TEXT,
      line_names TEXT,
      bearing TEXT,
      heading TEXT,
      stop_type TEXT,
      bus_stop_type TEXT,
      created_at TEXT,
      modified_at TEXT,
      active INTEGER NOT NULL
    );
  ''';

  final String atcoCode;
  final String? naptanCode;
  final String commonName;
  final String name;
  final String longName;
  final double latitude;
  final double longitude;
  final String indicator;
  final String? icon;
  final List<String>? lineNames;
  final String bearing;
  final String? heading;
  final String stopType;
  final String busStopType;
  final String? createdAt;
  final String? modifiedAt;
  final bool active;

  Stop({
    required this.atcoCode,
    this.naptanCode,
    required this.commonName,
    required this.name,
    required this.longName,
    required this.latitude,
    required this.longitude,
    this.indicator = '',
    this.icon,
    this.lineNames,
    this.bearing = '',
    this.heading,
    this.stopType = '',
    this.busStopType = '',
    this.createdAt,
    this.modifiedAt,
    required this.active,
  });

  @override
  factory Stop.buildFromMap(Map<String, dynamic> json) {
    List<String>? lines;
    if (json['line_names'] != null) {
      if (json['line_names'] is List) {
        lines =
            (json['line_names'] as List<dynamic>)
                .map((e) => e.toString())
                .toList();
      } else if (json['line_names'] is String) {
        lines =
            json['line_names'].isNotEmpty ? json['line_names'].split(',') : [];
      }
    }

    List<dynamic> location = json['location'] ?? [0.0, 0.0];

    return Stop(
      atcoCode: json['atco_code'] ?? '',
      naptanCode: json['naptan_code'],
      commonName: json['common_name'] ?? '',
      name: json['name'] ?? '',
      longName: json['long_name'] ?? '',
      latitude: (location.isNotEmpty ? (location[1] as num).toDouble() : 0.0),
      longitude: (location.isNotEmpty ? (location[0] as num).toDouble() : 0.0),
      indicator: json['indicator'] ?? '',
      icon: json['icon'],
      lineNames: lines,
      bearing: json['bearing'] ?? '',
      heading: json['heading']?.toString(),
      stopType: json['stop_type'] ?? '',
      busStopType: json['bus_stop_type'] ?? '',
      createdAt: json['created_at'],
      modifiedAt: json['modified_at'],
      active: json['active'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'atco_code': atcoCode,
      'naptan_code': naptanCode,
      'common_name': commonName,
      'name': name,
      'long_name': longName,
      'latitude': latitude,
      'longitude': longitude,
      'indicator': indicator,
      'icon': icon,
      'line_names': lineNames?.join(','),
      'bearing': bearing,
      'heading': heading,
      'stop_type': stopType,
      'bus_stop_type': busStopType,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'active': active ? 1 : 0,
    };
  }

  // ----- SQL Functions -----

  static Future<List<Stop>> getAllByService(String line) async {
    final db = await AppDatabase.instance.db;

    final rows = await db.rawQuery(
      "SELECT * FROM stop WHERE ',' || line_names || ',' LIKE ?",
      ['%,$line,%'],
    );

    return rows.map((row) => Stop.buildFromMap(row)).toList();
  }

  // ----- API Functions -----

  static Future<List<Stop>> getAllApi(StopQuery query) async {
    final List<Stop> stops = await ApiManager.getAllPaginated(
      ApiOptions(
        endpoint: 'stops',
        query: query.toMap(),
        fromMap: Stop.buildFromMap,
      ),
    );

    AppDatabase.instance.insertManyInBackground(
      TableKey.stop,
      stops.map((x) => x.toMap()).toList(),
    );

    return stops;
  }
}
