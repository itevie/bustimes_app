import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/models/favourite_operator.dart';
import 'package:route_log/widgets/objects/operator.dart';
import 'package:route_log/widgets/view_list.dart';

class FavouriteOperatorsPage extends StatefulWidget {
  const FavouriteOperatorsPage({super.key});

  @override
  State<FavouriteOperatorsPage> createState() => _FavouriteOperatorsPageState();
}

class _FavouriteOperatorsPageState extends State<FavouriteOperatorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favourite Operators")),
      body: ViewList<Operator>(
        name: "favourite operators",
        loadData: (options) async => FavouriteOperator.getAllAsObject(),
        itemBuilder: (operator, _) => OperatorWidget(operator: operator),
        noConfirmReload: true,
      ),
    );
  }
}
