import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lechat/utils/couleurs.dart';

class Message {
  String? userName;
  String? photoURL;
  String? message;
  List<Text>? messages;
  Timestamp? date;

  Message({required this.userName, required this.message, required this.date, required this.photoURL});    

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['message'] = message;
    data['date']  = date;
    data['photoURL']  = photoURL;
    return data;
  }

  Message.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    message = json['message'];
    date = json['date'];
    photoURL = json['photoURL'];
  }

  Message.fromObject(QueryDocumentSnapshot<Object?> json) {
    messages = [];
    userName = json['userName'];
    message = json['message'];
    messages!.insert(0,Text(message.toString(),style: const TextStyle(color: Couleurs.white, fontFamily: 'Glass Antiqua', overflow: TextOverflow.visible, fontSize: 16)));
    date = json['date'];
    photoURL = json['photoURL'];
  }  
}