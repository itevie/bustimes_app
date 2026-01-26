import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/favourite_vehicles.dart';
import 'package:route_log/widgets/objects/vehicle.dart';
import 'package:route_log/widgets/view_list.dart';

class FavouriteVehiclesPage extends StatefulWidget {
  const FavouriteVehiclesPage({super.key});

  @override
  State<FavouriteVehiclesPage> createState() => _FavouriteVehiclesPageState();
}

class _FavouriteVehiclesPageState extends State<FavouriteVehiclesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Vehicles")),
      body: ViewList<Vehicle>(
        name: "favourite vehicles",
        loadData: (refresh, query) async => FavouriteVehicles.getAllAsObject(),
        itemBuilder: (vehicle) => VehicleWidget(vehicle: vehicle),
      ),
    );
  }
}
