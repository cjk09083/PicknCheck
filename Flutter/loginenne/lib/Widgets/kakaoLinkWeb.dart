@JS()
library main;

import 'dart:developer';

import 'package:js/js.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;


@JS('getUid')
external String getUid();

@JS('chkUid')
external String chkUid();

Widget kakaoLink(String _uid, var context, VoidCallback callback) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
      'kakaoLinkType',
          (int viewID) => html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'kakaolink.html?uid=342594737'
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
  );
  callback();

  return Container(
    height: 90,
    width: 90,
    child: const HtmlElementView(
      viewType: 'kakaoLinkType',
    ),
  );
}

String setUid(){
  // chkUid();
  String uuid = getUid();
  return uuid;
}
