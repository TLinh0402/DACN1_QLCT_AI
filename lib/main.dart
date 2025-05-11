import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qlmoney/screen/screen_started.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDPJX3zFi737iip5Si5JGimi2cAuGBAZIs",
      appId: "1:1064752535102:android:ef2d195b96926b577ce36f",
      messagingSenderId: "XXX",
      projectId: "quanlychitieu-ccdbf",
      databaseURL:
          'https://quanlychitieu-ccdbf-default-rtdb.asia-southeast1.firebasedatabase.app/',
      storageBucket: 'gs://quanlychitieu-ccdbf.appspot.com',
    ),
  );

  await EasyLocalization.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'Remind_1',
        channelName: 'Remind_Notification',
        channelDescription: "Bạn có 1 nhắc nhở!",
      )
    ],
    debug: true,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations', // Đường dẫn tới tệp JSON
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Money Management',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          locale: context.locale,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          home: SplashScreen(onTap: () {}),
        );
      },
    );
  }
}
