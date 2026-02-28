import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:dawn_ui_flutter/prompts/loading.dart';
import 'package:dawn_ui_flutter/prompts/select.dart';
import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';

Future<void> showAddEntityToListPrompt(
  BuildContext context,
  RouteChecklistType t,
  Operator operator,
) async {
  List<dynamic> entities = await showLoadingPrompt(
    context,
    t == RouteChecklistType.route
        ? operator.getServices(ServiceQuery(), 0, fetchAll: true, refresh: true)
        : operator.getVehicles(
          VehicleQuery(),
          0,
          fetchAll: true,
          refresh: true,
        ),
    title: const Text("Fetching data..."),
  );

  int? id = await showSelectPrompt(
    // ignore: use_build_context_synchronously
    context,
    Text(
      "Add Operator's ${t == RouteChecklistType.route ? "Services" : "Vehicles"}",
    ),
    Map<int, String>.fromEntries(
      RouteChecklist.cache.entries
          .where((x) => x.value.type == t)
          .map((entry) => MapEntry(entry.key, entry.value.name)),
    ),
    notes: Text(
      "Select a list to add ${entities.length} ${t == RouteChecklistType.route ? "services" : "vehicles"} to ",
    ),
  );

  if (id == null) return;

  final result = await showConfirmPrompt(
    // ignore: use_build_context_synchronously
    context,
    const Text("Are you sure?"),
    Text(
      "Are you sure you want to add ${entities.length} ${t == RouteChecklistType.route ? "services" : "vehicles"} to ${RouteChecklist.cache[id]?.name}",
    ),
  );

  if (result) {
    await showLoadingPrompt(context, () async {
      for (final entity in entities) {
        if (t == RouteChecklistType.route) {
          await RouteChecklistItem.insertService(
            id,
            entity,
            isFrom: "op_${operator.noc}",
          );
        } else if (t == RouteChecklistType.vehicle) {
          if ((entity as Vehicle).withdrawn) continue;
          await RouteChecklistItem.insertVehicle(
            id,
            entity,
            isFrom: "op_${operator.noc}",
          );
        }
      }
    }(), title: const Text("Adding to list, please wait..."));

    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          "Added ${t == RouteChecklistType.route ? "services" : "vehicles"} to ${RouteChecklist.cache[id]?.name}",
        ),
      ),
    );
  }
}
