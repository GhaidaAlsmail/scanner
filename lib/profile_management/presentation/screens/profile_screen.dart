// import 'package:bot_toast/bot_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:news_watch/translation.dart';
// import '../../../auth/application/auth_notifier_provider.dart';
// import '../../../core/application/theme_provider.dart';
// import '../../../core/presentation/components/language_dialog_component.dart';
// import '../../../core/presentation/widgets/settings_card_widget.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, ref) {
//     var currentUser = ref.watch(authNotifierProvider);
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SettingsCardWidget(
//             onTap: () {
//               // TODO
//               BotToast.showText(text: "Soon");
//             },
//             icon: Icon(Icons.person_pin_outlined),
//             title: "Profile",
//           ),
     
//           SettingsCardWidget(
//             onTap: () {
//               // TODO
//               BotToast.showText(text: "Soon");
//             },
//             icon: Icon(Icons.article),
//             title: "Terms & Conditions".i18n,
//           ),
//           SettingsCardWidget(
//             onTap: () {
//               showAboutDialog(
//                 context: context,
//                 applicationName: "Midad",
//                 applicationIcon: Image.asset(
//                   height: 32,
//                   width: 32,
//                   "assets/images/icon.png",
//                 ),
//                 applicationVersion: "1.0.0",
//                 applicationLegalese: "This is news app we built in midad".i18n,
//               );
//             },
//             icon: Icon(Icons.info),
//             title: "About".i18n,
//           ),
         
//           SettingsCardWidget(
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return const LanguageDialogComponent();
//                 },
//               );
//             },
//             icon: Icon(FontAwesomeIcons.language),
//             title: "Language".i18n,
//           ),
//           SettingsCardWidget(
//             onTap: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text("Select Theme".i18n),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SwitchListTile(
//                           title: Text("Light".i18n),
//                           value: ref.watch(themeModeProvider).name == "light",
//                           onChanged: (value) {
//                             ref
//                                 .read(themeModeProvider.notifier)
//                                 .setThemeMode(ThemeMode.light);
//                           },
//                         ),
//                         SwitchListTile(
//                           title: Text("Dark".i18n),
//                           value: ref.watch(themeModeProvider).name == "dark",
//                           onChanged: (value) {
//                             ref
//                                 .read(themeModeProvider.notifier)
//                                 .setThemeMode(ThemeMode.dark);
//                           },
//                         ),
//                         SwitchListTile(
//                           title: Text("System".i18n),
//                           // value: "system",
//                           // groupValue: "",
//                           onChanged: (value) {
//                             ref
//                                 .read(themeModeProvider.notifier)
//                                 .setThemeMode(ThemeMode.system);
//                           },
//                           value: ref.watch(themeModeProvider).name == "system",
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             },
//             icon: Icon(Icons.dark_mode),
//             title: "Theme".i18n,
//           ),
//           SettingsCardWidget(
//             onTap: () {
//               ref.read(authNotifierProvider.notifier).logOut();
//             },
//             icon: Icon(Icons.logout),
//             title: "Log Out".i18n,
//           ),
//         ],
//       ),
//     );
//   }
// }
