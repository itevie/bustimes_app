import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/_base_query.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';

class VehicleTripQuery implements BaseQuery {
  String? ticketMachineCode;
  String? vehicleJourneyCode;
  String? block;
  String? operator;
  int? service;
  String? date;

  VehicleTripQuery({
    this.ticketMachineCode,
    this.vehicleJourneyCode,
    this.block,
    this.operator,
    this.service,
    this.date,
  });

  static const List<String> keys = [
    'ticket_machine_code',
    'vehicle_journey_code',
    'block',
    'operator',
    'service',
    'date',
  ];

  @override
  Map<String, String> toMap() {
    final map = <String, String>{};

    if (ticketMachineCode != null) {
      map['ticket_machine_code'] = ticketMachineCode!;
    }
    if (vehicleJourneyCode != null) {
      map['vehicle_journey_code'] = vehicleJourneyCode!;
    }
    if (block != null) map['block'] = block!;
    if (operator != null) map['operator'] = operator!;
    if (service != null) map['service'] = service.toString();
    if (date != null) map['date'] = date!;

    return map;
  }

  @override
  factory VehicleTripQuery.fromMap(Map<String, dynamic> map) {
    return VehicleTripQuery(
      ticketMachineCode: map['ticket_machine_code']?.toString(),
      vehicleJourneyCode: map['vehicle_journey_code']?.toString(),
      block: map['block']?.toString(),
      operator: map['operator']?.toString(),
      service:
          map['service'] != null
              ? int.tryParse(map['service'].toString())
              : null,
      date: map['date']?.toString(),
    );
  }
}

class VehicleTrip implements BaseModel {
  static final String sqlTable = '''
    CREATE TABLE IF NOT EXISTS vehicle_journey (
      id INTEGER PRIMARY KEY,
      vehicle_journey_code TEXT NOT NULL,
      ticket_machine_code TEXT,
      block TEXT,
      start TEXT NOT NULL,
      end TEXT NOT NULL,
      headsign TEXT NOT NULL,
      service_id INTEGER NOT NULL,
      operator_noc TEXT NOT NULL,
      notes TEXT,
      times TEXT
    );
  ''';

  final int id;
  final String vehicleJourneyCode;
  final String ticketMachineCode;
  final String? block;
  final String start;
  final String end;
  final String headsign;
  final Service service;
  final Operator operatorObj;
  final List<String> notes;
  final List<String> times;

  VehicleTrip({
    required this.id,
    required this.vehicleJourneyCode,
    required this.ticketMachineCode,
    this.block,
    required this.start,
    required this.end,
    required this.headsign,
    required this.service,
    required this.operatorObj,
    required this.notes,
    required this.times,
  });

  @override
  factory VehicleTrip.buildFromMap(Map<String, dynamic> json) {
    return VehicleTrip(
      id: json['id'] ?? 0,
      vehicleJourneyCode: json['vehicle_journey_code'] ?? '',
      ticketMachineCode: json['ticket_machine_code'] ?? '',
      block: json['block'],
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      headsign: json['headsign'] ?? '',
      service: Service.buildFromMap(json['service'] ?? {}),
      operatorObj: Operator.buildFromMap(json['operator'] ?? {}),
      notes:
          (json['notes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      times:
          (json['times'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_journey_code': vehicleJourneyCode,
      'ticket_machine_code': ticketMachineCode,
      'block': block,
      'start': start,
      'end': end,
      'headsign': headsign,
      'service_id': service.id,
      'operator_noc': operatorObj.noc,
      'notes': notes.join(','),
      'times': times.join(','),
    };
  }
}
