// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:news_watch/home_management/domain/news.dart';
// import 'package:news_watch/translation.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import '../../application/stream_news_provider.dart';

// class HomeScreen extends ConsumerWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context, ref) {
//     var newsStream = ref.watch(streamNewsProvider);
//     return ReactiveForm(
//       formGroup: FormGroup({
//         "name": FormControl<String>(),
//         "type": FormControl<String>(),
//         "poll": FormControl<String>(value: "Zero"),
//       }),
//       child: newsStream.when(
//         data: (data) {
//           var allNews = data;
//           var politicNews = data
//               .where((element) => element.category == Category.politics)
//               .toList();
//           var techNews = data
//               .where((element) => element.category == Category.tech)
//               .toList();
//           var healthyNews = data
//               .where((element) => element.category == Category.healthy)
//               .toList();
//           var scinceNews = data
//               .where((element) => element.category == Category.science)
//               .toList();
//           return TabBarView(
//             children: [
//               NewsListComponent(news: allNews),
//               NewsListComponent(news: allNews),
//               NewsListComponent(news: politicNews),
//               NewsListComponent(news: techNews),
//               NewsListComponent(news: healthyNews),
//               NewsListComponent(news: scinceNews),
//             ],
//           );
//         },
//         error: (error, stackTrace) {
//           return Text("Something Went Wrong".i18n);
//         },
//         loading: () {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       ),
//     );
//   }
// }
