// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lechat/models/user_model.dart';

class Connection{
  String? chatId;
  String? userCreateID;
  String? roomName;
  String? lastMessage;
  String? date;
  Timestamp? dataCreate;
  List<Usuario>? users;
  List<dynamic>? userIds;

  Connection({required this.roomName, required this.lastMessage, required this.dataCreate}); 

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomName'] = roomName;
    data['lastMessage'] = lastMessage;
    data['userCreateID'] = userCreateID;
    data['dataCreate']  = dataCreate;
    data['chatId']  = chatId;
    data['date']  = date;
    return data;
  }

  Connection.fromJson(Map<String, dynamic> json) {
    roomName = json['roomName'];
    lastMessage = json['lastMessage'];
    dataCreate = json['dataCreate'];
    chatId = json['chatId'];
    userCreateID = json['userCreateID'];
    date = json['date'];
  }

  Connection.fromObject(DocumentSnapshot<Object?> obj)  {
    roomName = obj['roomName'];
    lastMessage = obj['lastMessage'] ?? '';
    chatId = obj['chatId'];
    dataCreate = obj['dataCreate'];
    userCreateID = obj['userCreateID'];
    date = obj['date'];
    userIds = obj['users'] ?? [];
  }
}
