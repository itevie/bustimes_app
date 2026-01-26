import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/widgets/pages/lists/trips.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/service_number.dart';

class ServiceWidget extends StatefulWidget {
  final Service service;

  const ServiceWidget({super.key, required this.service});

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isFavourite = FavouriteService.cache[widget.service.id] != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceNumber(lineName: service.lineName),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Region: ${service.region?.niceName()} • Mode: ${service.mode}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  if (service.operator.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Operator${service.operator.length > 1 ? 's' : ''}: "
                      "${service.operator.join(', ')}",
                    ),
                  ],

                  const SizedBox(height: 8),

                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.place, size: 16),
                        label: const Text("Stops"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => TripsPage(
                                    search: ServiceTrips(service: service),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.route_outlined, size: 16),
                        label: const Text("Trips"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.alt_route, size: 16),
                        label: const Text("Route"),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.directions_bus, size: 16),
                        label: const Text("Vehicles"),
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
                                          "https://bustimes.org/services/${service.slug}#map",
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
                    bool isFavourite = await FavouriteService.update(
                      widget.service.id,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
