import 'package:flutter/material.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/widgets/util/square_icon.dart';

Future<RouteChecklistType?> showChecklistTypePrompt(
  BuildContext context,
) async {
  return showDialog<RouteChecklistType>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Create Checklist"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                // Route
                InkWell(
                  onTap: () => Navigator.pop(context, RouteChecklistType.route),
                  child: Column(
                    children: [
                      squareIcon(context, Icons.route, size: 80),
                      SizedBox(height: 8),
                      Text("Route"),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Vehicle
                InkWell(
                  onTap:
                      () => Navigator.pop(context, RouteChecklistType.vehicle),
                  child: Column(
                    children: [
                      squareIcon(context, Icons.directions_bus, size: 80),
                      SizedBox(height: 8),
                      Text("Vehicle"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
