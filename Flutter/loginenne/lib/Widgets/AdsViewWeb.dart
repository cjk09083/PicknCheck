
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

Widget bottomAdsView(var banner, var context) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(
      'adViewType',
          (int viewID) => html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'adview.html'
        ..style.border = 'none'
        ..style.height = '100%'
        ..style.width = '100%'
  );

  return Container(
    height: 120.0,
    width: 450,
    constraints: const BoxConstraints(
      maxWidth: 450,
    ),
    child: const HtmlElementView(
      viewType: 'adViewType',
    ),
  );
}