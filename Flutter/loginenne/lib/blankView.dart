import 'package:flutter/material.dart';

class DebugWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Title(
        title: "디버그용 공간",
        color: Colors.blue,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}


