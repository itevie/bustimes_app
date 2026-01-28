import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/pages/lists/trips.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/util/service_number.dart';
import 'package:route_log/widgets/view_widget.dart';

class ServiceWidget extends StatefulWidget {
  final Service service;
  final bool isGrid;

  const ServiceWidget({super.key, required this.service, this.isGrid = false});

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return ViewWidget(
      model: service,
      leftChild: ServiceNumber(
        lineName: service.lineName,
        operator: service.operator[0],
      ),
      gridChild:
          widget.isGrid
              ? (
                widget: ServiceNumber(
                  lineName: service.lineName,
                  operator: service.operator[0],
                ),
                onTap: null,
              )
              : null,
      favourite: (
        fetch: () => FavouriteService.cache[widget.service.id] != null,
        update: () => FavouriteService.update(widget.service.id),
      ),
      actions: [
        (
          name: "Trips",
          icon: Icons.route_outlined,
          callback: () {
            navigate(
              context,
              TripsPage(search: ServiceTrips(service: service)),
            );
          },
        ),
        if (Platform.isAndroid)
          (
            name: "Map",
            icon: Icons.map,
            callback: () {
              navigate(
                context,
                BustimesMapPage(
                  isPage: true,
                  preSearch:
                      "https://bustimes.org/services/${service.slug}#map",
                ),
              );
            },
          ),
      ],
      children: [
        Text(
          service.description,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      ],
    );
  }
}
