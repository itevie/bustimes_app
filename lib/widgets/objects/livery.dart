import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/widgets/livery_image.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/util/my_card.dart';

class LiveryWidget extends StatefulWidget {
  final Livery livery;

  const LiveryWidget({super.key, required this.livery});

  @override
  State<LiveryWidget> createState() => _LiveryWidgetState();
}

class _LiveryWidgetState extends State<LiveryWidget> {
  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Platform.isAndroid) ...[
              LiveryImageWidget(livery: widget.livery),
              const SizedBox(width: 16),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.livery.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => VehiclesPage(
                                      search: LiveryVehicles(
                                        livery: widget.livery,
                                      ),
                                    ),
                              ),
                            ),
                        icon: const Icon(Icons.bus_alert, size: 16),
                        label: const Text("Vehicles"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
