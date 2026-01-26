import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/widgets/objects/vehicle.dart';
import 'package:route_log/widgets/view_list.dart';

sealed class VehicleSearch {}

class OperatorVehicles extends VehicleSearch {
  final Operator operator;
  OperatorVehicles({required this.operator});
}

class LiveryVehicles extends VehicleSearch {
  final Livery livery;
  LiveryVehicles({required this.livery});
}

class VehicleTypeVehicles extends VehicleSearch {
  final VehicleType vehicleType;
  VehicleTypeVehicles({required this.vehicleType});
}

class AllVehicles extends VehicleSearch {
  AllVehicles();
}

class VehiclesPage extends StatefulWidget {
  final VehicleSearch search;
  final String? preSearch;
  final Map<String, dynamic>? fullSearch;

  const VehiclesPage({
    super.key,
    required this.search,
    this.preSearch,
    this.fullSearch,
  });

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicles for Test")),
      body: ViewList<Vehicle>(
        name: "vehicles",
        preSearch: widget.preSearch,
        fullSearch: widget.fullSearch,
        queryGroup: "vehicle",
        loadData: (refresh, query) {
          return switch (widget.search) {
            OperatorVehicles(:final operator) => operator.getVehicles(
              VehicleQuery.buildFromMap(query),
              refresh: refresh,
            ),
            LiveryVehicles(:final livery) => livery.getVehicles(
              VehicleQuery.buildFromMap(query),
              refresh: refresh,
            ),
            VehicleTypeVehicles(:final vehicleType) => vehicleType.getVehicles(
              VehicleQuery.buildFromMap(query),
              refresh: refresh,
            ),
            VehicleSearch() => Vehicle.getAllApi(
              VehicleQuery.buildFromMap(query),
              refresh: refresh,
            ),
          };
        },
        itemBuilder: (vehicle) => VehicleWidget(vehicle: vehicle),
      ),
    );
  }
}
