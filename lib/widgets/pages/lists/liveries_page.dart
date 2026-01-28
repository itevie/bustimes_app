import 'dart:io';

import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/widgets/objects/livery.dart';
import 'package:route_log/widgets/view_list.dart';

class LiveriesPage extends StatefulWidget {
  final bool isPage;
  final String? preSearch;
  const LiveriesPage({super.key, required this.isPage, this.preSearch});

  @override
  State<LiveriesPage> createState() => _LiveriesPageState();
}

class _LiveriesPageState extends State<LiveriesPage> {
  @override
  Widget build(BuildContext context) {
    final viewWidget = ViewList<Livery>(
      name: "liveries",
      allowGrid: true,
      loadData: (refresh, query) async => Livery.getAllApi(force: refresh),
      itemBuilder:
          (livery, details) => LiveryWidget(
            key: Key(livery.id.toString()),
            livery: livery,
            isGrid: details.isGrid,
          ),
      preSearch: widget.preSearch,
      note:
          !Platform.isAndroid
              ? const Text(
                "At the moment, livery images can only be viewd on Android.",
              )
              : null,
    );
    return widget.isPage
        ? Scaffold(appBar: AppBar(title: Text("Liveries")), body: viewWidget)
        : viewWidget;
  }
}
