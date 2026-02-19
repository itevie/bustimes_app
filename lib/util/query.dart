import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/util.dart';

enum ObjectQueryType { string, bool, selector }

typedef ObjectQuery =
    ({
      String name,
      String queryName,
      String dbName,
      ObjectQueryType t,
      bool Function(String value)? inputValidator,
      Future<List<String>> Function()? getPossibleValues,
    });

final Map<String, List<ObjectQuery>> objectQuries = {
  'service': [
    (
      name: "Search",
      queryName: "search",
      dbName: "?",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Operator (NOC)",
      queryName: "operator",
      dbName: "operator",
      t: ObjectQueryType.string,
      inputValidator:
          (value) =>
              Operator.cache.values.where((x) => x.noc == value).isNotEmpty,
      getPossibleValues: null,
    ),
    (
      name: "Slug",
      queryName: "slug",
      dbName: "slug",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Region (Local Search)",
      queryName: "region_id",
      dbName: "region_id",
      t: ObjectQueryType.selector,
      inputValidator: null,
      getPossibleValues: () async => Region.values.map((r) => r.name).toList(),
    ),
    (
      name: "Mode",
      queryName: "mode",
      dbName: "mode",
      t: ObjectQueryType.selector,
      inputValidator: null,
      getPossibleValues: () async => ["bus", "coach", "tram"],
    ),
    (
      name: "Public Use",
      queryName: "public_use",
      dbName: "public_use",
      t: ObjectQueryType.bool,
      inputValidator: null,
      getPossibleValues: null,
    ),
  ],
  'vehicle': [
    (
      name: "Search",
      queryName: "search",
      dbName: "?",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Operator (NOC)",
      queryName: "operator",
      dbName: "operator_noc",
      t: ObjectQueryType.string,
      inputValidator:
          (value) =>
              Operator.cache.values.where((x) => x.noc == value).isNotEmpty,
      getPossibleValues: null,
    ),
    (
      name: "Fleet Number",
      queryName: "fleet_code",
      dbName: "fleet_code",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Slug",
      queryName: "slug",
      dbName: "slug",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Registration",
      queryName: "reg",
      dbName: "reg",
      t: ObjectQueryType.string,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "Livery",
      queryName: "livery",
      dbName: "livery_id",
      t: ObjectQueryType.string,
      inputValidator:
          (value) =>
              Livery.cache.values
                  .where((x) => x.id.toString() == value)
                  .isNotEmpty,
      getPossibleValues: null,
    ),
    (
      name: "Withdrawn",
      queryName: "withdrawn",
      dbName: "withdrawn",
      t: ObjectQueryType.bool,
      inputValidator: null,
      getPossibleValues: null,
    ),
    (
      name: "unique",
      queryName: "unique",
      dbName: "unique",
      t: ObjectQueryType.selector,
      inputValidator: null,
      getPossibleValues: () async => ["livery_id", "vehicle_type_id"],
    ),
  ],
};

List<T> queryViaObjectQuery<T extends BaseModel>(
  List<T> values,
  Map<String, dynamic> filter,
) {
  String? unique = filter["unique"];

  if (filter.isEmpty && unique == null) return values;

  if (filter.length == 1 &&
      filter.containsKey("search") &&
      (filter["search"] == null || filter["search"].isEmpty)) {
    return values;
  }

  final search = filter["search"]?.toString().toLowerCase();

  final filtered =
      values.where((value) {
        final map = value.toMap();

        for (final f in filter.entries) {
          String key = f.key;

          if (key == "operator") key = "operator_noc";
          if (key == "search") continue;
          if (key == "unique") continue;
          if (!map.containsKey(key)) return false;

          final v = map[key];

          if (f.value is bool) {
            if (!(f.value == true && v == 1)) return false;
          } else {
            if (f.value.toString().toLowerCase() !=
                v.toString().toLowerCase()) {
              return false;
            }
          }
        }

        if (search != null && search.isNotEmpty) {
          final matches = map.values.any(
            (v) => v.toString().toLowerCase().contains(search),
          );

          if (!matches) return false;
        }

        return true;
      }).toList();

  if (search != null && search.isNotEmpty) {
    filtered.sort((a, b) {
      final aMap = a.toMap();
      final bMap = b.toMap();

      bool aExact = aMap.values.any(
        (v) => v.toString().toLowerCase() == search,
      );
      bool bExact = bMap.values.any(
        (v) => v.toString().toLowerCase() == search,
      );

      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;
      return 0;
    });
  }

  if (unique != null) {
    List<String> found = [];
    filtered.removeWhere((x) {
      final map = x.toMap();
      if (!found.contains(map[unique].toString())) {
        found.insert(0, map[unique].toString());
        return false;
      } else {
        return true;
      }
    });
  }

  return filtered;
}

Future<Map<String, dynamic>?> showObjectQueryPrompt(
  BuildContext context,
  List<ObjectQuery> queries, {
  Map<String, dynamic>? prefill,
}) async {
  final Map<String, dynamic> values = {};
  final Map<String, TextEditingController> textControllers = {};
  final Map<String, bool?> boolValues = {};
  final Map<String, String?> selectorValues = {};

  for (final q in queries) {
    if (q.queryName == "search") continue;

    if (q.t == ObjectQueryType.string) {
      textControllers[q.queryName] = TextEditingController();
    } else if (q.t == ObjectQueryType.bool) {
      boolValues[q.queryName] = null;
    } else if (q.t == ObjectQueryType.selector) {
      selectorValues[q.queryName] = null;
    }
  }

  if (prefill != null) {
    for (final obj in prefill.entries) {
      if (obj.key == "search") continue;

      final t = queries.firstWhere((x) => x.queryName == obj.key);

      if (t.t == ObjectQueryType.string) {
        textControllers[t.queryName]!.text = obj.value as String? ?? "";
      } else if (t.t == ObjectQueryType.bool) {
        boolValues[t.queryName] = obj.value as bool?;
      } else if (t.t == ObjectQueryType.selector) {
        selectorValues[t.queryName] = obj.value as String?;
      }
    }
  }

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Search filters"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    queries.where((x) => x.queryName != "search").map((q) {
                      switch (q.t) {
                        case ObjectQueryType.string:
                          return TextField(
                            controller: textControllers[q.queryName],
                            decoration: InputDecoration(labelText: q.name),
                          );

                        case ObjectQueryType.bool:
                          return CheckboxListTile(
                            title: Text(q.name),
                            value: boolValues[q.queryName],
                            tristate: true,
                            onChanged: (v) {
                              setState(() {
                                boolValues[q.queryName] = v;
                              });
                            },
                          );

                        case ObjectQueryType.selector:
                          return FutureBuilder<List<String>>(
                            future: q.getPossibleValues?.call(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: q.name),
                                value: selectorValues[q.queryName],
                                items: [
                                  DropdownMenuItem(
                                    value: "special-none",
                                    child: Text("None"),
                                  ),
                                  ...snapshot.data!.map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ),
                                  ),
                                ],

                                onChanged: (v) {
                                  setState(() {
                                    selectorValues[q.queryName] = v;
                                  });
                                },
                              );
                            },
                          );
                      }
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  for (final q in queries) {
                    if (q.queryName == "search") continue;

                    dynamic value;

                    switch (q.t) {
                      case ObjectQueryType.string:
                        value = textControllers[q.queryName]!.text.trim();
                        if (value.isEmpty) continue;
                        if (q.inputValidator != null &&
                            !q.inputValidator!(value)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Invalid value for ${q.name}"),
                            ),
                          );
                          return;
                        }
                        break;

                      case ObjectQueryType.bool:
                        if (boolValues[q.queryName] == null) continue;
                        value = boolValues[q.queryName];
                        break;

                      case ObjectQueryType.selector:
                        value = selectorValues[q.queryName];
                        if (value == null || value == "special-none") continue;
                        break;
                    }

                    values[q.queryName] = value;
                  }

                  Navigator.pop(context, values);
                },
                child: const Text("Apply"),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}
