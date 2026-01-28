import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/widgets/objects/list_items_item.dart';
import 'package:route_log/widgets/pages/lists/list_presets.dart';
import 'package:route_log/widgets/view_list.dart';

class ListItemsPage extends StatefulWidget {
  final RouteChecklist list;

  const ListItemsPage({super.key, required this.list});

  @override
  State<ListItemsPage> createState() => ListItemsPageState();
}

class ListItemsPageState extends State<ListItemsPage> {
  Key _listKey = UniqueKey();

  void _refresh() {
    setState(() {
      _listKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List ${widget.list.name}")),
      body: ViewList<CombinedRouteChecklistItem>(
        key: _listKey,
        name: 'checklists',
        loadData:
            (_, _) async =>
                RouteChecklistItem.getAllWithService(widget.list.id),
        itemBuilder: (item, _) {
          return ListItemsItem(
            key: ValueKey(item.checkListItem.id),
            item: item,
          );
        },
      ),
      floatingActionButton: _Fab(
        addOperator: () {},
        addPreset: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ChecklistPresetsPage(
                    list: widget.list,
                    refresh: _refresh,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _Fab extends StatefulWidget {
  final Function() addOperator;
  final Function() addPreset;
  const _Fab({required this.addOperator, required this.addPreset});

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> with SingleTickerProviderStateMixin {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: _open ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton.small(
            heroTag: 'add_operator',
            onPressed: () {
              setState(() {
                _open = false;
              });
            },
            child: const Icon(Icons.business),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedScale(
          scale: _open ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton.small(
            heroTag: 'add_preset',
            onPressed: () {
              widget.addPreset();
              setState(() {
                _open = false;
              });
            },
            child: const Icon(Icons.auto_awesome),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: () {
            setState(() {
              _open = !_open;
            });
          },
          child: Icon(_open ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}
