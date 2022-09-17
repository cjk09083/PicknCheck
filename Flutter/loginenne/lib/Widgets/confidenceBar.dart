import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:loginenne/Widgets/StrokeText.dart';

class ConfidenceBar extends StatelessWidget {
  final String content;
  final Color barColor;
  final Color textColor;
  final double progress;

  ConfidenceBar({required this.content, required this.barColor,
      required this.progress, required this.textColor});
  @override
  Widget build(BuildContext context) {
    String percent = (progress*100).toStringAsFixed(1);
    double progressSet = double.parse(percent)/100;
    // log("textColor.toString():"+textColor.toString());

    if (progressSet < 0.07 && progressSet >= 0.001){
      progressSet = 0.07;
    }
    return Container(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25,right: 25,top: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(content,
                style: TextStyle(fontWeight: FontWeight.bold,
                color: textColor, fontSize: 18),),
              flex: 1,
            ),
            Expanded(
              child: LinearPercentIndicator(
                animation: true,
                lineHeight: 25.0,
                animationDuration: 1000,
                percent: progressSet,
                center: StrokeText(text: percent+"%", fontSize: 15,),
                barRadius: const Radius.circular(20),
                // linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: barColor,
                backgroundColor: (textColor.toString()=="Color(0xff000000)")?
                const Color(0xffcccccc):const Color(0xff999999),
              ),
              flex: 4,
            ),
          ],
        ),
      ),
    );
  }
}


