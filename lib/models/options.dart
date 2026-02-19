import 'package:route_log/app_database.dart';

class RouteLogOptions {
  static String sqlTable = '''
    CREATE TABLE IF NOT EXISTS options (
      redirect_from_map INTEGER NOT NULL DEFAULT 1,
      remember_grid_views INTEGER NOT NULL DEFAULT 0,
      default_page INTEGER NOT NULL DEFAULT 0
    );
  ''';

  bool redirectFromMap;
  bool rememberGridViews;
  int defaultPage;

  RouteLogOptions({
    required this.redirectFromMap,
    required this.rememberGridViews,
    required this.defaultPage,
  });

  factory RouteLogOptions.fromMap(Map<String, dynamic> map) {
    return RouteLogOptions(
      redirectFromMap: map['redirect_from_map'] == 1,
      rememberGridViews: map['remember_grid_views'] == 1,
      defaultPage: map['default_page'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'redirect_from_map': redirectFromMap ? 1 : 0,
      'remember_grid_views': rememberGridViews ? 1 : 0,
      'default_page': defaultPage,
    };
  }

  static late RouteLogOptions cache;

  // ---- SQL ----

  static Future<RouteLogOptions> get() async {
    final db = await AppDatabase.instance.db;

    var rows = await db.query('options', limit: 1);

    if (rows.isEmpty) {
      await db.insert('options', {
        'redirect_from_map': 1,
        'remember_grid_views': 0,
        'default_page': 0,
      });

      rows = await db.query('options', limit: 1);
    }

    final options = RouteLogOptions.fromMap(rows.first);
    RouteLogOptions.cache = options;

    return options;
  }

  static Future<void> update(RouteLogOptions options) async {
    final db = await AppDatabase.instance.db;

    await db.update('options', options.toMap());

    cache = options;
  }

  static Future<void> updateCache() async {
    cache = await get();
  }
}
