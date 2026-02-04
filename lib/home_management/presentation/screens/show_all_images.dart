// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../data/photos_repository_provider.dart';

// class AllPhotosScreen extends ConsumerWidget {
//   const AllPhotosScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final photosAsync = ref.watch(allPhotosProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('All Photos')),
//       body: photosAsync.when(
//         data: (photos) {
//           // 👇 حالة عدم وجود صور
//           if (photos.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.photo_library_outlined,
//                     size: 80,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'لا يوجد صور',
//                     style: TextStyle(fontSize: 18, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             );
//           }

//           // 👇 في حال وجود صور
//           return GridView.builder(
//             padding: const EdgeInsets.all(10),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: photos.length,
//             itemBuilder: (_, index) {
//               final photo = photos[index];

//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   photo.profilePictureUrl!,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (c, w, p) => p == null
//                       ? w
//                       : const Center(child: CircularProgressIndicator()),
//                   errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text(e.toString())),
//       ),
//     );
//   }
// }
