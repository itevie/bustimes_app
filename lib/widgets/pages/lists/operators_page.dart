import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/widgets/objects/operator.dart';
import 'package:route_log/widgets/view_list.dart';

class OperatorsPage extends StatefulWidget {
  final bool isPage;
  final String? preSearch;
  const OperatorsPage({super.key, required this.isPage, this.preSearch});

  @override
  State<OperatorsPage> createState() => _OperatorsPageState();
}

class _OperatorsPageState extends State<OperatorsPage> {
  @override
  Widget build(BuildContext context) {
    final viewWidget = ViewList<Operator>(
      name: "operators",
      loadData: (refresh, query) async {
        return Operator.getAllApi(refresh: refresh);
      },
      preSearch: widget.preSearch,
      itemBuilder: (operator, _) => OperatorWidget(operator: operator),
    );
    return widget.isPage
        ? Scaffold(appBar: AppBar(title: Text("Operators")), body: viewWidget)
        : viewWidget;
  }
}
