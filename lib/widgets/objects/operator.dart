import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/favourite_operator.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/pages/lists/service_page.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/prompts/confirm.dart';
import 'package:route_log/widgets/prompts/loader.dart';
import 'package:route_log/widgets/prompts/selector_prompt.dart';
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
                      name: "Add To List",
                      icon: Icons.list,
                      callback: () async {
                        final services = await showLoadingPrompt(
                          context,
                          operator.getServices(ServiceQuery(), refresh: true),
                        );

                        int? id = await showSelectPrompt(
                          // ignore: use_build_context_synchronously
                          context,
                          const Text("Add Operator's Services"),
                          RouteChecklist.cache.map(
                            (key, value) => MapEntry(key, value.name),
                          ),
                          notes: Text(
                            "Select a list to add ${services.length} services to ",
                          ),
                        );

                        if (id == null) return;

                        final result = await showConfirmPrompt(
                          // ignore: use_build_context_synchronously
                          context,
                          const Text("Are you sure?"),
                          Text(
                            "Are you sure you want to add ${services.length} services to ${RouteChecklist.cache[id]?.name}",
                          ),
                        );

                        if (result) {
                          for (final service in services) {
                            await RouteChecklistItem.insertFromOperator(
                              id,
                              service,
                              operator,
                            );
                          }

                          ScaffoldMessenger.of(
                            // ignore: use_build_context_synchronously
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added services to ${RouteChecklist.cache[id]?.name}",
                              ),
                            ),
                          );
                        }
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
