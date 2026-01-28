import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/util/preset_checklists.dart';
import 'package:route_log/widgets/pages/add_checklist_preset.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/view_list.dart';

class ChecklistPresetsPage extends StatefulWidget {
  final RouteChecklist list;
  final VoidCallback refresh;
  const ChecklistPresetsPage({
    super.key,
    required this.list,
    required this.refresh,
  });

  @override
  State<ChecklistPresetsPage> createState() => ChecklistPresetsPageState();
}

class ChecklistPresetsPageState extends State<ChecklistPresetsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checklist Presets")),
      body: ViewList<ChecklistPreset>(
        name: 'checklist presets',
        note: const Text(
          "A preset will add all services from the listed operators.",
        ),
        loadData: (refresh, query) async => checklistPresets,
        itemBuilder: (list, _) {
          return MyCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AddChecklistPresetPage(
                        preset: list,
                        list: widget.list,
                        refresh: widget.refresh,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Operators: ${list.operators.join(", ")}"),
                        if (list.filter != null) ...[
                          const SizedBox(height: 4),
                          Text("Has a filter: ${list.filterReason}"),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
