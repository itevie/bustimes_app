import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/service.dart';
import 'package:route_log/widgets/objects/service.dart';
import 'package:route_log/widgets/view_list.dart';

sealed class ServiceSearch {}

class OperatorServices extends ServiceSearch {
  final Operator operator;
  OperatorServices({required this.operator});
}

class AllServices extends ServiceSearch {
  AllServices();
}

class ServicePage extends StatefulWidget {
  final ServiceSearch search;
  final String? preSearch;
  final Map<String, dynamic>? fullSearch;

  const ServicePage({
    super.key,
    required this.search,
    this.preSearch,
    this.fullSearch,
  });

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  @override
  Widget build(BuildContext context) {
    String title = switch (widget.search) {
      OperatorServices(operator: final operator) => "for ${operator.name}",
      AllServices() => "",
    };

    return Scaffold(
      appBar: AppBar(title: Text("Services $title")),
      body: ViewList<Service>(
        name: "services",
        preSearch: widget.preSearch,
        fullSearch: widget.fullSearch,
        allowGrid: true,
        loadData: (refresh, query) async {
          return switch (widget.search) {
            OperatorServices(:final operator) => operator.getServices(
              ServiceQuery.fromMap(query),
              refresh: refresh,
            ),
            AllServices() => Service.getAllApi(
              ServiceQuery.fromMap(query),
              refresh: refresh,
            ),
          };
        },
        queryGroup: 'service',
        itemBuilder:
            (service, options) =>
                ServiceWidget(service: service, isGrid: options.isGrid),
      ),
    );
  }
}
