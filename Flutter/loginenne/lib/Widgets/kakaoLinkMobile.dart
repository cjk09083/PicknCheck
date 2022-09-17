
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loginenne/utilities/KakaoShareManager.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'CustomToast.dart';

final FToast ftoast = FToast();
late ToastNotification toast;

Widget kakaoLink(String _uid, var context, VoidCallback callBack) {
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: IconButton(
      icon: Image.asset('assets/kakaobtn.png'),
      iconSize: 90,
      onPressed: () {
        print("카톡 공유하기 클릭");

        KakaoShareManager().isKakaotalkInstalled().then((installed) {
          if (installed) {
            print("카톡 API 호출");
            KakaoShareManager().shareMyCode(_uid);
            print("카톡 API 호출 성공");

            dev.log("카톡 API 호출 성공");
            // callBack();

          } else {
            // show alert
            toast = ToastNotification(ftoast.init(context));
            toast.error("카카오톡을 설치해주세요.");
          }
        });
      },
    ),
  );
}


String setUid(){
  var uid ="";

  while (true) {
    var rnd = Random().nextInt(9) + 1;
    uid += rnd.toString();
    if (uid.length == 20) break;
  }

  return uid.toString();
}