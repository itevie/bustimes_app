import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/util/preset_checklists.dart';
import 'package:route_log/widgets/prompts/loader.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/page.dart';

class AddChecklistPresetPage extends StatefulWidget {
  final ChecklistPreset preset;
  final RouteChecklist list;
  final VoidCallback refresh;

  const AddChecklistPresetPage({
    super.key,
    required this.preset,
    required this.list,
    required this.refresh,
  });

  @override
  State<AddChecklistPresetPage> createState() => AddChecklistPresetPageState();
}

class AddChecklistPresetPageState extends State<AddChecklistPresetPage> {
  Future<void> _addPreset(
    BuildContext context,
    List<Operator> operators,
  ) async {
    final progress = ValueNotifier<String>("Starting…");

    await showLoadingPrompt(
      context,
      () async {
        for (final op in operators) {
          progress.value = "Fetching ${op.name}…";

          await RouteChecklistItem.insertServicesFromOperator(
            widget.list.id,
            op,
            filter: widget.preset.filter,
          );
        }
      }(),
      title: const Text("Adding preset"),
      message: ValueListenableBuilder<String>(
        valueListenable: progress,
        builder: (_, value, __) => Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Operator> operators =
        widget.preset.operators.map((x) => Operator.cache[x]!).toList();

    return Scaffold(
      appBar: AppBar(title: Text("${widget.preset.name} Preset")),
      body: BasePage(
        widget: Column(
          children: [
            // 👇 Scrollable main content
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: MyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.preset.description),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              operators
                                  .map((op) => Chip(label: Text(op.name)))
                                  .toList(),
                        ),
                        if (widget.preset.filter != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(value: false, onChanged: (_) {}),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Ignore filters?"),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Filter: ${widget.preset.filterReason}",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 👇 Fixed bottom button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Preset"),
                onPressed: () async {
                  await _addPreset(context, operators);

                  if (!mounted) return;
                  Navigator.pop(context);
                  widget.refresh();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
