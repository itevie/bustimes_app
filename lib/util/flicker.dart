import 'dart:convert';

import 'package:http/http.dart' as http;

class FlickrPhoto {
  final String title;
  final String imageUrl;
  final String link;

  FlickrPhoto({
    required this.title,
    required this.imageUrl,
    required this.link,
  });

  factory FlickrPhoto.fromJson(Map<String, dynamic> json) {
    return FlickrPhoto(
      title: json['title'] ?? '',
      imageUrl: json['media']['m'],
      link: json['link'],
    );
  }
}

Future<List<FlickrPhoto>> fetchFlickrByTags(String tags) async {
  final uri = Uri.parse(
    'https://www.flickr.com/services/feeds/photos_public.gne'
    '?tags=$tags'
    '&format=json'
    '&nojsoncallback=1',
  );

  final res = await http.get(uri);

  if (res.statusCode != 200) {
    throw Exception('Failed to load Flickr feed');
  }

  final data = jsonDecode(res.body);
  final items = data['items'] as List;

  return items.map((e) => FlickrPhoto.fromJson(e)).toList();
}
