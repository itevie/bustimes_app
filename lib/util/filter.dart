import 'package:route_log/bustimes/models/_base_model.dart';

List<T> filterObjects<T extends BaseModel>(
  List<T> objects, {
  String? search,
  Map<String, dynamic>? query,
}) {
  if ((search == null || search.isEmpty) && (query == null || query.isEmpty)) {
    return objects;
  }

  if (objects.isEmpty) return objects;

  List<String> keys = objects[0].toMap().keys.toList();

  return objects.where((obj) {
    final mapped = obj.toMap();
    for (final key in keys) {
      if (mapped.containsKey(key)) {
        if (mapped[key] is BaseModel) {
          return filterObjects(
            [mapped[key] as BaseModel],
            search: search,
            query: query,
          ).isNotEmpty;
        }

        if (search != null) {
          if (mapped[key].toString().toLowerCase().contains(
            search.toLowerCase(),
          )) {
            return true;
          }
        }

        if (query != null) {
          if (query.containsKey(key) &&
              mapped[key].toString().toLowerCase().contains(
                query[key].toString().toLowerCase(),
              )) {
            return true;
          }
        }
      }
    }

    return false;
  }).toList();
}
