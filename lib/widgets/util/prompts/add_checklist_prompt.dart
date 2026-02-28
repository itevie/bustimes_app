import 'package:dawn_ui_flutter/prompts/input.dart';
import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/widgets/util/prompts/checklist_type_prompt.dart';

Future<void> showAddChecklistPrompt(
  BuildContext context,
  VoidCallback refresh,
) async {
  RouteChecklistType? t = await showChecklistTypePrompt(context);

  if (t == null) return;

  String? name = await showInputPrompt(
    // ignore: use_build_context_synchronously
    context,
    const Text("Name of list"),
    Text(
      "You will be able to add ${t == RouteChecklistType.route ? "services" : "vehicles"} later.",
    ),
  );

  if (name == null || name.isEmpty) return;

  await RouteChecklist.makeNew(name, t);
  refresh();
}
