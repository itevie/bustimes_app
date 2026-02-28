import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/vehicle.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/pages/vehicle_images.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

List<PopupMenuItemC> makeVehiclePopup(BuildContext context, Vehicle vehicle) {
  return [
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
            builder: (context) => VehicleImages(tags: vehicle.reg!),
          ),
        );
      },
      icon: Icons.image,
    ),
    (
      name: "Google",
      callback: () {
        openUrl("https://www.google.com/search?q=${vehicle.reg}");
      },
      icon: Icons.search,
    ),
  ];
}
