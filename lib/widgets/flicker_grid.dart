import 'package:flutter/material.dart';
import 'package:route_log/util/flicker.dart';
import 'package:route_log/util/other.dart';

class FlickrGrid extends StatelessWidget {
  final String tags;

  const FlickrGrid({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlickrPhoto>>(
      future: fetchFlickrByTags(tags),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final photos = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4 / 3,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];

            return Material(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  openUrl(photo.link);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      photo.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (c, w, p) =>
                              p == null
                                  ? w
                                  : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                        child: Text(
                          photo.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
