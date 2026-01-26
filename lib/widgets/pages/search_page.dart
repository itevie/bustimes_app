import 'package:flutter/material.dart';
import 'package:route_log/widgets/pages/lists/liveries_page.dart';
import 'package:route_log/widgets/pages/lists/operators_page.dart';
import 'package:route_log/widgets/pages/lists/service_page.dart';
import 'package:route_log/widgets/pages/lists/vehicle_types.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/util/page.dart';
import 'package:route_log/widgets/util/tile.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      widget: GridView.count(
        padding: const EdgeInsets.all(10),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          Tile(
            context,
            icon: Icons.directions_bus,
            label: "Vehicles",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VehiclesPage(search: AllVehicles()),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.route,
            label: "Services",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServicePage(search: AllServices()),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.business,
            label: "Operators",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OperatorsPage(isPage: true),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.palette,
            label: "Liveries",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LiveriesPage(isPage: true),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.car_crash,
            label: "Vehicle Types",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VehicleTypesPage(isPage: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
