import 'package:flutter/material.dart';

class CircleBar extends StatelessWidget {
  final AnimationController controller;
  final double size;
  final String msg;

  CircleBar({required this.controller, required this.size,
    this.msg = ""});
  @override
  Widget build(BuildContext context) {

    return  SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: size,
              height: size,

              child: CircularProgressIndicator(
                strokeWidth: 15,
                value: controller.value,

                semanticsLabel: 'Linear progress indicator',
              ),
            ),
          ),
          Center(
            child: Text(msg,
              style: const TextStyle(fontWeight: FontWeight.bold,
                  color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
