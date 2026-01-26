import 'package:flutter/material.dart';
import 'package:route_log/widgets/flicker_grid.dart';

class VehicleImages extends StatefulWidget {
  final String tags;

  const VehicleImages({super.key, required this.tags});

  @override
  State<VehicleImages> createState() => _VehicleImagesState();
}

class _VehicleImagesState extends State<VehicleImages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.tags} Images")),
      body: FlickrGrid(tags: widget.tags),
    );
  }
}
