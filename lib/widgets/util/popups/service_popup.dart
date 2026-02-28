import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/pages/lists/trips.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

List<PopupMenuItemC> makeServicePopup(BuildContext context, Service service) {
  return [
    (
      name: "Trips",
      icon: Icons.route_outlined,
      callback: () {
        navigate(context, TripsPage(search: ServiceTrips(service: service)));
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
              preSearch: "https://bustimes.org/services/${service.slug}#map",
            ),
          );
        },
      ),
  ];
}
