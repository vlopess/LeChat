import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lechat/service/auth.dart';



final message = Provider(
  (ref) => ChatService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    ref: ref
  )
); 

class ChatService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ProviderRef ref;
  List? userList;


  ChatService({required this.auth, required this.firestore, required this.ref});

  void sendMessage(String? text, String chatId){
    if(text!.isNotEmpty){
      var date = DateTime.now();
      var message = {'userName': ref.read(authentication).getCurrentUser()!.displayName,'message': text, 'date' : date, 'photoURL' : ref.read(authentication).getCurrentUser()!.photoURL};            
      firestore.collection('connections').doc(chatId).collection('messages').doc().set(message);
      firestore.collection('connections').doc(chatId).update({'lastMessage' : text, 'date' : DateFormat('kk:mm').format(date)});
    }
  }

  // Stream<QuerySnapshot>? getAllMessages(){
  //   return firestore.collection('message').orderBy("date", descending: false).snapshots();
  // }

  Future<String> createChat(String roomName) async {
    var user = ref.read(authentication).getCurrentUser()!;
    String code = gerarCode();
    var chatId = "${code}_${user.uid}";
    var data = {'code':code, 'roomName':roomName, 'date' : DateFormat('kk:mm').format(DateTime.now()),'dataCreate' : DateTime.now(), 'chatId' : chatId, 'userCreateID' : user.uid, 'users' : [user.uid], 'lastMessage' : ''};
    await firestore.collection('connections').doc(chatId).set(data);
    return code;
  }

  Future<Map<String, String?>> existsCodeOrUser(String codeChat) async{
    var user = ref.read(authentication).getCurrentUser()!;
    var chat = await firestore.collection('connections').where('code',isEqualTo: codeChat).get();    
    if (chat.docs.isEmpty) return { 'value' : 'There is no connection to this code'};    
    var data = await firestore.collection('connections').doc(chat.docs.first.id).get();
    userList = data['users'];
    if (userList!.where((element) => element == user.uid).isNotEmpty ) return { 'value' : "You're already in that connection"};    
    userList!.add(user.uid);
    return {"id" : data.id, 'value': null};
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> enterInChat(String chatId) async {
    var newdata = {'users' : userList};
    await firestore.collection('connections').doc(chatId).update(newdata);
    var doc = await firestore.collection('connections').doc(chatId).get();
    userList!.clear();
    return doc; 
  }

  Future<void> exitInChat(String chatId) async {
    try {
      var user = ref.read(authentication).getCurrentUser()!;
      var data = await firestore.collection('connections').doc(chatId).get();
      userList = data['users'];
      userList!.remove(user.uid);
      var newdata = {'users' : userList};
      await firestore.collection('connections').doc(chatId).update(newdata);
      userList!.clear(); 
    } catch (e) {
      throw "Não foi possível sair";
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChats() {
    var user = ref.read(authentication).getCurrentUser()!;
    var teste =  firestore.collection('connections').where('users', arrayContains: user.uid.toString()).snapshots();    
    return teste;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesChat(String chatId){        
    return firestore.collection('connections').doc(chatId).collection('messages').orderBy("date", descending: false).snapshots();
  }
  
  gerarCode() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
  
}