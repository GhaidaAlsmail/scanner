// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_watch/core/presentation/widgets/get_base_url.dart';
import '../../application/add_photos_provider.dart';
import '../widgets/convert_to_pdf.dart';

class AllPhotosScreen extends ConsumerWidget {
  const AllPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(allPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Photos'),
        actions: [
          photosAsync.maybeWhen(
            data: (photosList) => IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                if (photosList.isNotEmpty) {
                  final rawBaseUrl = await getDynamicBaseUrl();
                  final imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

                  final List<String> urls = photosList.map((p) {
                    return "$imageBaseUrl${p.profilePictureUrl}";
                  }).toList();

                  createPdfFromImages(urls);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("لا توجد صور لتحويلها")),
                  );
                }
              },
            ),
            orElse: () =>
                const SizedBox.shrink(), // لا يظهر الزر في حالة التحميل أو الخطأ
          ),
        ],
        centerTitle: true,
      ),
      body: photosAsync.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد صور حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          //  1. يفضل جلب الـ BaseUrl مرة واحدة خارج الـ Builder للأداء
          return FutureBuilder<String>(
            future: getDynamicBaseUrl(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              // final baseUrl = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  // في شاشة AllPhotosScreen
                  final String rawBaseUrl = snapshot.data!;
                  final String imageBaseUrl = rawBaseUrl.replaceAll('/api', '');

                  final fullImageUrl =
                      "$imageBaseUrl${photo.profilePictureUrl}";

                  debugPrint("📸 Final Image URL: $fullImageUrl");

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            fullImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stack) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      "404",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            photo.title ?? 'بدون عنوان',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("خطأ: $err")),
      ),
    );
  }
}
