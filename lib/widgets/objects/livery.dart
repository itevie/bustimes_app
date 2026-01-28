import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/livery_image.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/view_widget.dart';

class LiveryWidget extends StatefulWidget {
  final Livery livery;
  final bool isGrid;

  const LiveryWidget({super.key, required this.livery, this.isGrid = false});

  @override
  State<LiveryWidget> createState() => _LiveryWidgetState();
}

class _LiveryWidgetState extends State<LiveryWidget> {
  @override
  Widget build(BuildContext context) {
    return ViewWidget(
      model: widget.livery,

      actions: [
        (
          name: "Vehicles",
          icon: Icons.bus_alert,
          callback: () {
            navigate(
              context,
              VehiclesPage(search: LiveryVehicles(livery: widget.livery)),
            );
          },
        ),
      ],
      gridChild:
          widget.isGrid
              ? (
                widget:
                    Platform.isAndroid
                        ? LiveryImageWidget(livery: widget.livery)
                        : SizedBox(),
                onTap: null,
                // onTap: () {
                //   navigate(
                //     context,
                //     VehiclesPage(search: LiveryVehicles(livery: widget.livery)),
                //   );
                // },
              )
              : null,
      children: [
        if (Platform.isAndroid) ...[
          LiveryImageWidget(livery: widget.livery),
          if (!widget.isGrid) const SizedBox(width: 16),
        ],
        Text(
          widget.livery.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );

    // if (widget.isGrid) {
    //   return MyCard(
    //     onTap: () {
    //       print("test");
    //       Navigator.of(context).push(
    //         MaterialPageRoute(
    //           builder:
    //               (context) => VehiclesPage(
    //                 search: LiveryVehicles(livery: widget.livery),
    //               ),
    //         ),
    //       );
    //     },
    //     child: Center(
    //       child:
    //           Platform.isAndroid
    //               ? LiveryImageWidget(livery: widget.livery)
    //               : SizedBox(),
    //     ),
    //   );
    // }

    // return MyCard(
    //   child: Padding(
    //     padding: EdgeInsets.all(16),
    //     child: Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         if (Platform.isAndroid) ...[
    //           LiveryImageWidget(livery: widget.livery),
    //           if (!widget.isGrid) const SizedBox(width: 16),
    //         ],

    //         if (!widget.isGrid) ...[
    //           Expanded(
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   widget.livery.name,
    //                   style: const TextStyle(
    //                     fontSize: 16,
    //                     fontWeight: FontWeight.bold,
    //                   ),
    //                 ),
    //                 Wrap(
    //                   children: [
    //                     TextButton.icon(
    //                       onPressed:
    //                           () => Navigator.of(context).push(
    //                             MaterialPageRoute(
    //                               builder:
    //                                   (context) => VehiclesPage(
    //                                     search: LiveryVehicles(
    //                                       livery: widget.livery,
    //                                     ),
    //                                   ),
    //                             ),
    //                           ),
    //                       icon: const Icon(Icons.bus_alert, size: 16),
    //                       label: const Text("Vehicles"),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ],
    //     ),
    //   ),
    // );
  }
}
