import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/util.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/widgets/util/popups/service_popup.dart';
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
      actions: makeServicePopup(context, service),
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
