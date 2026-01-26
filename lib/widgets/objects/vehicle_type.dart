import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';
import 'package:route_log/widgets/util/my_card.dart';

class VehicleTypeWidget extends StatelessWidget {
  final VehicleType vehicleType;

  const VehicleTypeWidget({super.key, required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    final vt = vehicleType;

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconForVehicleType(vt),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vt.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (vt.electric) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (vt.doubleDecker) _chip(Icons.layers, "Double decker"),
                      if (vt.coach)
                        _chip(Icons.airline_seat_recline_extra, "Coach"),
                      if (vt.electric) _chip(Icons.bolt, "Electric"),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => VehiclesPage(
                                    search: VehicleTypeVehicles(
                                      vehicleType: vt,
                                    ),
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions_bus, size: 16),
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

  /// Pick a reasonable icon based on flags
  IconData _iconForVehicleType(VehicleType vt) {
    if (vt.coach) return Icons.airport_shuttle;
    if (vt.doubleDecker) return Icons.directions_bus_filled;
    return Icons.directions_bus;
  }

  Widget _chip(IconData icon, String label) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
