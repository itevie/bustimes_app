import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/widgets/objects/list.dart';
import 'package:route_log/widgets/view_list.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => ListsPageState();
}

class ListsPageState extends State<ListsPage> {
  List<RouteChecklist> lists = RouteChecklist.cache.values.toList();
  Key _key = UniqueKey();

  void refresh() async {
    final fetched = await RouteChecklist.getAll();

    setState(() {
      lists = fetched;
      _key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewList<RouteChecklist>(
      key: _key,
      name: 'checklists',
      loadData: (refresh, query) async => lists,
      itemBuilder: (list, _) {
        return ListWidget(key: Key(list.id.toString()), list: list);
      },
    );
  }
}
