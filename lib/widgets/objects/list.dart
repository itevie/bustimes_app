import 'package:flutter/material.dart';
import 'package:route_log/models/favourite_list.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/widgets/pages/lists/list_items.dart';
import "package:dawn_ui_flutter/prompts/prompts.dart";
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

class ListWidget extends StatefulWidget {
  final RouteChecklist list;
  const ListWidget({super.key, required this.list});

  @override
  State<ListWidget> createState() => ListWidgetState();
}

class ListWidgetState extends State<ListWidget> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isFavourite = FavouriteList.cache[widget.list.id] != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<RouteChecklistItem> items =
        RouteChecklistItem.cache.values
            .where((x) => x.checklistId == widget.list.id)
            .toList();

    return MyCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ListItemsPage(list: widget.list),
          ),
        );

        setState(() {});
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
                    widget.list.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${items.where((x) => x.done).length}/${items.length} completed",
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // const Icon(Icons.chevron_right),
                // const SizedBox(height: 8),
                IconButton(
                  onPressed: () async {
                    bool? isFavourite = await FavouriteList.update(
                      widget.list.id,
                    );

                    if (isFavourite == null) {
                      showMessagePrompt(
                        // ignore: use_build_context_synchronously
                        context,
                        const Text("Max Reached"),
                        const Text(
                          "You can only favourite 3 lists, try unfavouriting one.",
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _isFavourite = isFavourite;
                    });
                  },
                  icon: Icon(
                    _isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavourite ? Colors.red : null,
                  ),
                ),
                const SizedBox(height: 8),
                PopupMenu(
                  items: <PopupMenuItemC>[
                    (name: "Delete", callback: () {}, icon: Icons.delete),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
