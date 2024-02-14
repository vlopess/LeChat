import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? name;
  String? uid;
  String? token;
  String? profilePic;

  Usuario({required this.name, required this.uid, required this.profilePic, required this.token});    

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['uid'] = uid;
    data['profilePic']  = profilePic;
    data['token']  = token;
    return data;
  }

  Usuario.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uid = json['uid'];
    profilePic = json['profilePic'];
    token = json['token'];
  }

  Usuario.fromObject(QueryDocumentSnapshot<Object?>  obj) {
    name = obj['name'];
    uid = obj['uid'];
    profilePic = obj['profilePic'];
    token = obj['token'];
  }

  
}