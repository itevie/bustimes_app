import 'package:flutter/material.dart';
import 'package:route_log/widgets/pages/lists/favourite_operators.dart';
import 'package:route_log/widgets/pages/lists/favourite_services.dart';
import 'package:route_log/widgets/pages/lists/favourite_vehicles.dart';
import 'package:route_log/widgets/util/page.dart';
import 'package:route_log/widgets/util/tile.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

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
            label: "Favourite Vehicles",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavouriteVehiclesPage(),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.route,
            label: "Favourite Services",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavouriteServicesPage(),
                ),
              );
            },
          ),
          Tile(
            context,
            icon: Icons.business,
            label: "Favourite Operators",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavouriteOperatorsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
