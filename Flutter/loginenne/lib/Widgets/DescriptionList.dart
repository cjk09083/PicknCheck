import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:word_break_text/word_break_text.dart';

class TextData {
  String data;

  TextData(this.data,);
}

class TextDataTile extends StatelessWidget {
  TextDataTile(this._textData, this._index, this.viewText, this.textColor, this.descriptIndex);
  final int _index;
  final String _textData;
  final bool viewText;
  final Color textColor;
  final int descriptIndex;

  @override
  Widget build(BuildContext context) {
    return  (_textData.isNotEmpty)?Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ((viewText || _index <= 0) && !(descriptIndex==3 && !viewText))?
      WordBreakText(_textData,
        style: TextStyle(
            color: textColor, fontSize: 16),):
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Text(_textData,
          style: TextStyle(
              color: textColor, fontSize: 16),),
      ),
    ):const SizedBox(height: 0,);

  }
}



class TextDataBuilder extends StatelessWidget {
  final List<String> data;
  final bool viewText;
  final Color textColor;
  final int descriptIndex;


  TextDataBuilder({required this.data, required this.viewText,
  required this.textColor, required this.descriptIndex});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      itemCount: data.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index < data.length) {
          return TextDataTile(data[index],index,viewText,textColor,descriptIndex);
        } else {
          return const SizedBox(height: 0,);
        }
      },
      // separatorBuilder: (context, index) {
      //   return const Divider();
      // },
    );
  }
}
