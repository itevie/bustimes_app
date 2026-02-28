import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/favourite_operator.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/util/prompts/add_entity_to_list.dart';
import 'package:route_log/widgets/pages/lists/service_page.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

class OperatorWidget extends StatefulWidget {
  final Operator operator;

  const OperatorWidget({super.key, required this.operator});

  @override
  State<OperatorWidget> createState() => _OperatorWidgetState();
}

class _OperatorWidgetState extends State<OperatorWidget> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isFavourite = FavouriteOperator.cache[widget.operator.noc] != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final operator = widget.operator;

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${operator.name} [${operator.noc}]",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (operator.aka.isNotEmpty)
                    Text(
                      "Also known as: ${operator.aka}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 4),
                  Text("Vehicle Mode: ${operator.vehicleMode}"),
                  Text("Region: ${operator.region?.niceName()}"),
                  if (operator.parent.isNotEmpty)
                    Text("Parent Company: ${operator.parent}"),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => VehiclesPage(
                                    search: OperatorVehicles(
                                      operator: operator,
                                    ),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_bus, size: 16),
                        label: const Text("Vehicles"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => ServicePage(
                                    search: OperatorServices(
                                      operator: operator,
                                    ),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.route, size: 16),
                        label: const Text("Routes"),
                      ),
                      if (operator.url.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => openUrl(operator.url),
                          icon: const Icon(Icons.link, size: 16),
                          label: const Text("Website"),
                        ),
                      if (operator.twitter.isNotEmpty)
                        TextButton.icon(
                          onPressed:
                              () => openUrl(
                                "https://twitter.com/@${operator.twitter}",
                              ),
                          icon: const Icon(Icons.alternate_email, size: 16),
                          label: const Text("Twitter"),
                        ),
                      if (Platform.isAndroid)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => BustimesMapPage(
                                      isPage: true,
                                      preSearch:
                                          "https://bustimes.org/operators/${operator.slug}/map",
                                    ),
                              ),
                            );
                          },
                          label: const Text("Map"),
                          icon: const Icon(Icons.map),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    bool isFavourite = await FavouriteOperator.update(
                      widget.operator.noc,
                    );
                    setState(() {
                      _isFavourite = isFavourite;
                    });
                  },
                  icon: Icon(
                    _isFavourite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavourite ? Colors.red : null,
                  ),
                ),
                const SizedBox(height: 4),
                PopupMenu(
                  items: <PopupMenuItemC>[
                    (
                      name: "Add Services To List",
                      icon: Icons.list,
                      callback: () async {
                        showAddEntityToListPrompt(
                          context,
                          RouteChecklistType.route,
                          operator,
                        );
                      },
                    ),
                    (
                      name: "Add Vehicles To List",
                      icon: Icons.list,
                      callback: () async {
                        showAddEntityToListPrompt(
                          context,
                          RouteChecklistType.vehicle,
                          operator,
                        );
                      },
                    ),
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
