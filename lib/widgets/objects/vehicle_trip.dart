import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/trip.dart';

class VehicleTripWidget extends StatefulWidget {
  final VehicleTrip trip;

  const VehicleTripWidget({super.key, required this.trip});

  @override
  State<VehicleTripWidget> createState() => _VehicleTripWidgetState();
}

class _VehicleTripWidgetState extends State<VehicleTripWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Row(
      children: [
        Text(trip.headsign, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
