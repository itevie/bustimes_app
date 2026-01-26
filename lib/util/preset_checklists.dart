import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/service.dart';

class ChecklistPreset implements BaseModel {
  String name;
  String description;
  List<String> operators;
  bool Function(Service service)? filter;
  String? filterReason;

  ChecklistPreset({
    required this.name,
    required this.description,
    required this.operators,
    this.filter,
    this.filterReason,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'description': description, 'name': name};
  }
}

final List<ChecklistPreset> checklistPresets = [
  ChecklistPreset(
    name: 'Manchester',
    description: "Every service in Manchester (Bee Network)",
    operators: ["BNSM", "BNML", "BNGN", "BNFM", "BNDB", "METL"],
    filter:
        (service) =>
            (int.tryParse(service.lineName) ?? 1) < 662 ||
            [
              "W1",
              "W2",
              "W3",
              "758C",
              "758B",
              "S350A",
              "S350B",
              "S84",
              "S237",
            ].contains(service.lineName),
    filterReason:
        "Remove services above 700 as they are usually school services.",
  ),
];
