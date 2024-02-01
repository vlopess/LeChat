// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:lottie/lottie.dart';

class LeChatLogo extends StatelessWidget {
  final bool textVisible;
  const LeChatLogo({super.key, this.textVisible = true});

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          child: LottieBuilder.asset('assets/json/lechat.json'),
        ),
        Visibility(
          visible: textVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 180,),
              Text("Le Chat", 
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 30, color: Couleurs.white, fontFamily: 'Glass Antiqua')
                //TextStyle(fontSize: 30, color: Couleurs.white)
              ),
            ],
          ),
        )
      ], 
    );
  }
}