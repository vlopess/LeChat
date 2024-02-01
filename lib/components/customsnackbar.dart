// ignore_for_file: file_names

import 'package:flutter/material.dart';

class SnackBarCustom extends StatelessWidget {
  final String title;
  final Color cor;
  const SnackBarCustom({
    super.key, 
    required this.title, 
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 40,
      decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(                
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                    ,fontFamily: 'Glass Antiqua'
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}