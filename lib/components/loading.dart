import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_html/flutter_html.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText(
              "Loading...",
              textStyle: TextStyle(
                fontSize: FontSize.xxLarge.size
              )
            )
          ],
          isRepeatingAnimation: true,
        ),
      ),
    );
  }
}
