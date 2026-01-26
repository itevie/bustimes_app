import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/favourite_vehicles.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/livery_image.dart';
import 'package:route_log/widgets/pages/lists/liveries_page.dart';
import 'package:route_log/widgets/pages/lists/operators_page.dart';
import 'package:route_log/widgets/pages/vehicle_images.dart';
import 'package:route_log/widgets/pages/lists/vehicle_types.dart';
import 'package:route_log/widgets/util/liscence_plate.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

class VehicleWidget extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleWidget({super.key, required this.vehicle});

  @override
  State<VehicleWidget> createState() => _VehicleWidgetState();
}

class _VehicleWidgetState extends State<VehicleWidget> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isFavourite = FavouriteVehicles.cache[widget.vehicle.id] != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (Platform.isAndroid && vehicle.livery != null) ...[
                        LiveryImageWidget(livery: vehicle.livery!),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        vehicle.name.isNotEmpty
                            ? vehicle.name
                            : "${vehicle.fleetNumber ?? vehicle.slug}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (vehicle.reg != null) ...[
                        const SizedBox(width: 8),
                        LicencePlate(vehicle.reg!),
                      ],
                      if (vehicle.withdrawn) ...[
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "Withdrawn",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(vehicle.vehicleType?.name ?? ""),
                  Text("Operator: ${vehicle.operator.safeName()}"),

                  if (vehicle.branding.isNotEmpty)
                    Text("Branding: ${vehicle.branding}"),

                  if (vehicle.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      vehicle.notes,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => OperatorsPage(
                                    isPage: true,
                                    preSearch: vehicle.operator.noc,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.business, size: 16),
                        label: const Text("Operator"),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => VehicleTypesPage(
                                    isPage: true,
                                    preSearch: vehicle.vehicleType?.name,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_bus, size: 16),
                        label: const Text("Type"),
                      ),
                      if (vehicle.livery != null)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => LiveriesPage(
                                      isPage: true,
                                      preSearch: vehicle.livery!.name,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.palette, size: 16),
                          label: const Text("Livery"),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    bool isFavourite = await FavouriteVehicles.update(
                      widget.vehicle.id,
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
                const SizedBox(height: 8),
                PopupMenu(
                  items: [
                    (
                      name: "Flickr (External)",
                      callback: () {
                        openUrl(
                          "https://www.flickr.com/search/?text=${vehicle.reg}&sort=date-taken-desc",
                        );
                      },
                      icon: Icons.link,
                    ),
                    (
                      name: "Flickr (Internal)",
                      callback: () {
                        if (vehicle.reg == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => VehicleImages(tags: vehicle.reg!),
                          ),
                        );
                      },
                      icon: Icons.image,
                    ),
                    (
                      name: "Google",
                      callback: () {
                        openUrl(
                          "https://www.google.com/search?q=${vehicle.reg}",
                        );
                      },
                      icon: Icons.search,
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
