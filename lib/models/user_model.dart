import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? name;
  String? uid;
  String? profilePic;

  Usuario({required this.name, required this.uid, required this.profilePic});    

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['uid'] = uid;
    data['profilePic']  = profilePic;
    return data;
  }

  Usuario.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    uid = json['uid'];
    profilePic = json['profilePic'];
  }

  Usuario.fromObject(QueryDocumentSnapshot<Object?>  obj) {
    name = obj['name'];
    uid = obj['uid'];
    profilePic = obj['profilePic'];
  }

  
}