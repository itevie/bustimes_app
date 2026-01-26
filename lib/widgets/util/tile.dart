import 'package:flutter/material.dart';
import 'package:route_log/widgets/util/my_card.dart';

Widget Tile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return AspectRatio(
    aspectRatio: 1,
    child: MyCard(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
