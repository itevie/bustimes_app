import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/bustimes/models/trip.dart';
import 'package:route_log/widgets/pages/lists/service_page.dart';

sealed class TripsSearch {}

// class OperatorTrips extends TripsSearch {
//   final Operator operator;
//   OperatorTrips({required this.operator});
// }

class ServiceTrips extends TripsSearch {
  final Service service;
  ServiceTrips({required this.service});
}

// class AllTrips extends TripsSearch {
//   AllTrips();
// }

class TripsPage extends StatefulWidget {
  final TripsSearch search;

  const TripsPage({super.key, required this.search});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  late final Future<List<VehicleTrip>> _tripsFuture;

  @override
  void initState() {
    super.initState();

    _tripsFuture = switch (widget.search) {
      ServiceTrips(:final service) => service.getTrips(
        VehicleTripQuery(date: "23/01/2026"),
        refresh: false,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trips")),
      body: FutureBuilder<List<VehicleTrip>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading trips\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final trips = snapshot.data ?? [];

          trips.sort((a, b) {
            final aDate = parseTimeOnly(a.start);
            final bDate = parseTimeOnly(b.start);
            return bDate.compareTo(aDate);
          });

          if (trips.isEmpty) {
            return const Center(child: Text("No trips found"));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FixedColumnWidth(80),
                        2: FixedColumnWidth(90),
                        3: FlexColumnWidth(4),
                      },
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        _headerRow(),
                        ...trips.map((trip) => _tripRow(context, trip)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

TableRow _headerRow() => const TableRow(
  children: [
    Padding(padding: EdgeInsets.all(8), child: Text("Service")),
    Padding(padding: EdgeInsets.all(8), child: Text("Trip")),
    Padding(padding: EdgeInsets.all(8), child: Text("Time")),
    Padding(padding: EdgeInsets.all(8), child: Text("To")),
  ],
);

TableRow _tripRow(BuildContext context, VehicleTrip trip) => TableRow(
  children: [
    Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => ServicePage(
                    search: AllServices(),
                    preSearch: trip.service.lineName,
                  ),
            ),
          );
        },
        child: Text(
          trip.service.lineName,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8),
      child: Text(trip.vehicleJourneyCode),
    ),
    Padding(
      padding: const EdgeInsets.all(8),
      child: Builder(
        builder: (context) {
          final tripTime = parseTimeOnly(trip.start);

          final now = DateTime(
            2026,
            1,
            23,
            TimeOfDay.now().hour,
            TimeOfDay.now().minute,
          );

          final isFuture = tripTime.isAfter(now);

          return Text(
            trip.start.contains(" ") ? trip.start.split(" ")[1] : trip.start,
            style: TextStyle(color: isFuture ? Colors.grey : null),
          );
        },
      ),
    ),

    Padding(padding: const EdgeInsets.all(8), child: Text(trip.headsign)),
  ],
);

DateTime parseTimeOnly(String time) {
  if (time.contains(" ")) time = time.split(" ")[1];
  final parts = time.split(':');
  return DateTime(
    2026,
    1,
    23,
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
