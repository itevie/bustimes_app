import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/widgets/objects/vehicle_type.dart';
import 'package:route_log/widgets/view_list.dart';

class VehicleTypesPage extends StatefulWidget {
  final bool isPage;
  final String? preSearch;
  const VehicleTypesPage({super.key, required this.isPage, this.preSearch});

  @override
  State<VehicleTypesPage> createState() => _VehicleTypesPageState();
}

class _VehicleTypesPageState extends State<VehicleTypesPage> {
  @override
  Widget build(BuildContext context) {
    final viewWidget = ViewList<VehicleType>(
      name: "vehicle types",
      loadData:
          (options) async => VehicleType.getAllApi(force: options.refresh),
      itemBuilder:
          (vehicleType, _) => VehicleTypeWidget(vehicleType: vehicleType),
      preSearch: widget.preSearch,
    );
    return widget.isPage
        ? Scaffold(
          appBar: AppBar(title: Text("Vehicle Types")),
          body: viewWidget,
        )
        : viewWidget;
  }
}
