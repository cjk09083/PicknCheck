import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:loginenne/blankView.dart';
import 'package:loginenne/PicknCheck.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

Future<void> main() async {
  log("앱 초기화 kIsWeb:"+kIsWeb.toString()+", kReleaseMode: "+kReleaseMode.toString());

  // 앱 상단 Status bar 색상변경
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    // systemNavigationBarColor: Colors.amber, // navigation bar color
    // statusBarColor: Colors.white, // status bar color
    // statusBarIconBrightness: Brightness.light, // status bar icon color
    // systemNavigationBarIconBrightness: Brightness.light, // color of navigation controlsdark
  ));
  WidgetsFlutterBinding.ensureInitialized();
  log("앱 초기화1 : Widget Binding ");

  // Web URI 연결
  setPathUrlStrategy();
  log("앱 초기화2 : Path");

  if(!kIsWeb) {
    KakaoSdk.init(nativeAppKey: 'ef9450ecafdee177e81ec948d4908c8c');
    log("앱 초기화3 : KakaoLink");

    MobileAds.instance.initialize();
    log("앱 초기화4 : Google Admob");
  }
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loginsoft Enne',
      theme: ThemeData.light(),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const PicknCheck(),
    );
  }


}



class AppColors {
  static Color successBgColor = const Color.fromRGBO(202, 237, 220, 1);
  static Color successTextColor = const Color.fromRGBO(6, 95, 70, 1);

  static Color errorBgColor = const Color.fromRGBO(254, 242, 242, 1);
  static Color errorTextColor = const Color.fromRGBO(156, 34, 34, 1);

  static Color infoBgColor = const Color.fromRGBO(239, 246, 255, 1);
  static Color infoTextColor = const Color.fromRGBO(88, 145, 255, 1);

  static Color warnBgColor = const Color.fromRGBO(255, 251, 235, 1);
  static Color warnTextColor = const Color.fromRGBO(180, 83, 9, 1);
}

