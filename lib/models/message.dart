import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lechat/utils/encrypt.dart';
import 'package:lechat/utils/message_enum.dart';

class Message {
  String? userName;
  String? photoURL;
  String? message;
  MessageEnum? type;
  //List<Message>? messages;
  Timestamp? date;

  Message({required this.userName, required this.message, required this.date, required this.photoURL, required this.type});    

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
      type = (json['photoURL'] as String).toEnum();
  }

  Message.fromObject(QueryDocumentSnapshot<Object?> json) {
    //messages = [];
    userName = json['userName'];
    //Text(Encrypt.decrypt(message.toString()),style: const TextStyle(color: Couleurs.white, fontFamily: 'Glass Antiqua', overflow: TextOverflow.visible, fontSize: 16)
    date = json['date'];
    photoURL = json['photoURL'];
    type = (json['type'] as String).toEnum();
    message = Encrypt.decrypt(json['message']);
    //messages!.insert(0,Message(userName: userName, message: Encrypt.decrypt(message.toString()), date: date, photoURL: photoURL, type: type));
  }  
}