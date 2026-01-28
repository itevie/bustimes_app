import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/widgets/objects/service.dart';
import 'package:route_log/widgets/view_list.dart';

class FavouriteServicesPage extends StatefulWidget {
  const FavouriteServicesPage({super.key});

  @override
  State<FavouriteServicesPage> createState() => _FavouriteServicesPageState();
}

class _FavouriteServicesPageState extends State<FavouriteServicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Services")),
      body: ViewList<Service>(
        name: "favourite services",
        loadData: (refresh, query) async => FavouriteService.getAllAsObject(),
        itemBuilder: (service, _) => ServiceWidget(service: service),
      ),
    );
  }
}
