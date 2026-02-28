import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/widgets/util/popup_menu.dart';
import 'package:route_log/widgets/util/popups/service_popup.dart';
import 'package:route_log/widgets/util/popups/vehicle_popup.dart';
import 'package:route_log/widgets/livery_image.dart';
import 'package:route_log/widgets/util/liscence_plate.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/service_number.dart';

class ListItemsItem extends StatefulWidget {
  final CombinedRouteChecklistItem item;

  const ListItemsItem({super.key, required this.item});

  @override
  State<ListItemsItem> createState() => _ListItemsItemState();
}

class _ListItemsItemState extends State<ListItemsItem> {
  bool _hasRode = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _hasRode = RouteChecklistItem.cache[widget.item.item.id]?.done ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    List<PopupMenuItemC> actions = [];

    if (item.item.itemType == ChecklistItemType.service) {
      actions = makeServicePopup(context, item.entity as Service);
    } else if (item.item.itemType == ChecklistItemType.vehicle) {
      actions = makeVehiclePopup(context, item.entity as Vehicle);
    }

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (item.entity case Service service) ...[
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
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (Platform.isAndroid &&
                            item.entity.livery != null) ...[
                          LiveryImageWidget(livery: item.entity.livery!),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          item.entity.name.isNotEmpty
                              ? item.entity.name
                              : "${item.entity.fleetNumber ?? item.entity.slug}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.entity.reg != null) ...[
                          const SizedBox(width: 8),
                          LicencePlate(item.entity.reg!),
                        ],
                        if (item.entity.withdrawn) ...[
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
                    Text(item.entity.vehicleType?.name ?? ""),
                    Text(
                      "Operator: ${item.entity.operator.safeName()}",
                      softWrap: true,
                    ),
                    if (item.entity.branding.isNotEmpty)
                      Text("Branding: ${item.entity.branding}"),
                    if (item.entity.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.entity.notes,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            // const Spacer(),
            Column(
              children: [
                Checkbox(
                  value: _hasRode,
                  onChanged: (value) async {
                    final done = await item.item.toggleComplete();
                    setState(() => _hasRode = done);
                  },
                ),
                PopupMenu(
                  items: [
                    ...actions,
                    (name: "Delete", icon: Icons.delete, callback: () {}),
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


// item.entity is Service
//                   ? [
//                     ServiceNumber(lineName: item.entity.lineName),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.entity.description,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Column(
//                       children: [
//                         Checkbox(
//                           value: _hasRode,
//                           onChanged: (value) async {
//                             final done = await item.item.toggleComplete();

//                             setState(() {
//                               _hasRode = done;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ]
//                   : [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Wrap(
//                           crossAxisAlignment: WrapCrossAlignment.center,
//                           children: [
//                             if (Platform.isAndroid &&
//                                 item.entity.livery != null) ...[
//                               LiveryImageWidget(livery: item.entity.livery!),
//                               const SizedBox(width: 8),
//                             ],
//                             Text(
//                               item.entity.name.isNotEmpty
//                                   ? item.entity.name
//                                   : "${item.entity.fleetNumber ?? item.entity.slug}",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             if (item.entity.reg != null) ...[
//                               const SizedBox(width: 8),
//                               LicencePlate(item.entity.reg!),
//                             ],
//                             if (item.entity.withdrawn) ...[
//                               const SizedBox(width: 8),
//                               const Padding(
//                                 padding: EdgeInsets.only(top: 4),
//                                 child: Text(
//                                   "Withdrawn",
//                                   style: TextStyle(
//                                     color: Colors.redAccent,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),

//                         const SizedBox(height: 4),

//                         Text(item.entity.vehicleType?.name ?? ""),
//                         Text("Operator: ${item.entity.operator.safeName()}"),

//                         if (item.entity.branding.isNotEmpty)
//                           Text("Branding: ${item.entity.branding}"),

//                         if (item.entity.notes.isNotEmpty) ...[
//                           const SizedBox(height: 8),
//                           Text(
//                             item.entity.notes,
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],