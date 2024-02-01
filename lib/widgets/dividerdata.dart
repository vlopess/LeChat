import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lechat/utils/couleurs.dart';

class DividerData extends StatelessWidget {  
  final Timestamp? date;
  const DividerData({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Couleurs.greyVeryLight, endIndent: 10,indent: 10)),          
        Text(DateFormat('dd/MM/yyyy').format(date!.toDate()), style: const TextStyle(color: Couleurs.primaryColor, fontFamily: 'Glass Antiqua', fontSize: 16)),
        const Expanded(child: Divider(color: Couleurs.greyVeryLight, endIndent: 10,indent: 10))
      ],
    );
  }
}