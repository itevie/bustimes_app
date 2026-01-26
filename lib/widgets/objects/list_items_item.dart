import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/service_number.dart';

class ListItemsItem extends StatefulWidget {
  final CombinedRouteChecklistItem item;

  const ListItemsItem({super.key, required this.item});

  @override
  State<ListItemsItem> createState() => _ListItemsItemState();
}

class _ListItemsItemState extends State<ListItemsItem> {
  bool _hasRode = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _hasRode =
          RouteChecklistItem.cache[widget.item.checkListItem.id]?.done ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ServiceNumber(lineName: item.service.lineName),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.service.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Checkbox(
                  value: _hasRode,
                  onChanged: (value) async {
                    final done = await item.checkListItem.toggleComplete();

                    setState(() {
                      _hasRode = done;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
