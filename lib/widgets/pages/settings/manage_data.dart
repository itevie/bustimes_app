import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:route_log/app_database.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/widgets/util/page.dart';

class ManageDataSettingsPage extends StatefulWidget {
  const ManageDataSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => ManageDataSettingsPageState();
}

class ManageDataSettingsPageState extends State<ManageDataSettingsPage> {
  Future<void> delete(String table, dynamic cache) async {
    final db = await AppDatabase.instance.db;

    await db.delete(table);

    if (cache == null) return;

    if (cache is Map) {
      cache.clear();
    } else if (cache is List) {
      cache.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      name: const Text("Settings"),
      body: BasePage(
        widget: Column(
          children: [
            const Text("Delete Data"),
            PageChangeCard(
              icon: Icons.business,
              child: const Text("Delete Operators"),
              onTap: () {
                delete("operator", Operator.cache);
              },
            ),
            PageChangeCard(
              icon: Icons.route,
              child: const Text("Delete Services"),
              onTap: () {
                delete("service", null);
              },
            ),
            PageChangeCard(
              icon: Icons.palette,
              child: const Text("Delete Liveries"),
              onTap: () {
                delete("livery", Livery.cache);
              },
            ),
            PageChangeCard(
              icon: Icons.bus_alert,
              child: const Text("Delete Vehicles"),
              onTap: () {
                delete("vehicle", null);
              },
            ),
            PageChangeCard(
              icon: Icons.bus_alert,
              child: const Text("Delete Vehicle Types"),
              onTap: () {
                delete("vehicle_type", VehicleType.cache);
              },
            ),
            PageChangeCard(
              icon: Icons.route,
              child: const Text("Delete Trips"),
              onTap: () {
                delete("vehicle_journey", null);
              },
            ),
            PageChangeCard(
              icon: Icons.stop,
              child: const Text("Delete Stops"),
              onTap: () {
                delete("stop", null);
              },
            ),
          ],
        ),
      ),
    );
  }
}
