
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loginenne/PicknCheck.dart';

Widget bottomAdsView(var banner, var context) {
  return Column(
    children: [
      Container(
        height: 50.0,
        width: 320,
        child: AdWidget( ad: banner, ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 20),
        height: 50.0,
        width: 320,
        child: AdFitBanner(
<<<<<<< HEAD
          adId: Platform.isIOS ? 'SECRET' 
=======
          adId: Platform.isIOS ? 'SECRET'
>>>>>>> b543acdacb43ac37c2935d8d11d58466629af09c
              : 'SECRET',
          adSize: AdFitBannerSize.SMALL_BANNER,
          listener: (AdFitEvent event, AdFitEventData data) {
            log(event.toString()+", adId: "+data.adId.toString()+", msg: "+data.message.toString());
            switch (event) {
              case AdFitEvent.AdReceived:
                break;
              case AdFitEvent.AdClicked:
                PicknCheckState.viewText = true;

                // PicknCheckState stateObject = context.findAncestorStateOfType<PicknCheckState>();
                //
                // stateObject.setState(() {
                //   PicknCheckState.viewText = true;
                // });

                break;
              case AdFitEvent.AdReceiveFailed:
                break;
              case AdFitEvent.OnError:
                break;
            }
          },
        ),
      ),


    ],
  );
}