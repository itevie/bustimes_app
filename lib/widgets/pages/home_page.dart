import 'package:flutter/material.dart';
import 'package:route_log/models/favourite_list.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/widgets/objects/list.dart';
import 'package:route_log/widgets/util/page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Favourite Lists",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...FavouriteList.cache.values.map(
            (x) => ListWidget(list: RouteChecklist.cache[x.id]!),
          ),
        ],
      ),
    );
  }
}
