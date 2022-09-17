import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  StrokeText({required this.text, required this.fontSize,});

  final String text;
  final double fontSize;
  
  final List<double> sWidth = [0.7,-0.7];

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(color: Colors.black,
          fontSize: fontSize,
          inherit: true,
          shadows: [
            Shadow(  offset: Offset(sWidth[1], sWidth[1]),color: Colors.white),
            Shadow(  offset: Offset(sWidth[1], sWidth[0]),color: Colors.white),
            Shadow(  offset: Offset(sWidth[0], sWidth[1]),color: Colors.white),
            Shadow(  offset: Offset(sWidth[0], sWidth[0]),color: Colors.white),
          ]
      ),
    );
  }
}


