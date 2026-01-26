import 'dart:convert';
import 'dart:io';

typedef FromMap<T> = T Function(Map<String, dynamic> map);

final String apiBase = "https://bustimes.org/api";

class ApiOptions<T> {
  String endpoint;
  Map<String, String>? query;
  FromMap<T> fromMap;

  ApiOptions({required this.endpoint, this.query, required this.fromMap});
}

class ApiManager {
  static Future<Map<String, dynamic>> get(ApiOptions options) async {
    final client = HttpClient();

    Uri url = Uri.parse('$apiBase/${options.endpoint}');

    if (options.query?.isNotEmpty ?? false) {
      url = url.replace(queryParameters: options.query);
    }

    print("Get $url");

    final request = await client.getUrl(url);
    final response = await request.close();

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: $url');
    }

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body);

    client.close();

    return json;
  }

  static Future<List<T>> getAllPaginated<T>(ApiOptions options) async {
    final List<T> items = [];

    while (options.endpoint != "") {
      final Map<String, dynamic> response = await get(options);

      final List results = response['results'] as List;

      items.addAll(
        results.map((e) => options.fromMap(e as Map<String, dynamic>)),
      );

      final next = response['next'];

      if (next == null) {
        options.endpoint = "";
      } else {
        final uri = Uri.parse(next);

        options.endpoint = uri.path.replaceFirst('/api/', '');

        options.query = uri.queryParameters;
      }
    }

    return items;
  }
}
