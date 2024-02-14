import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lechat/models/connection_chat_model.dart';
import 'package:lechat/repositories/firebase_storage_repository.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/service/firebaseapi.dart';
import 'package:lechat/utils/encrypt.dart';
import 'package:lechat/utils/message_enum.dart';



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

  void sendMessage(String? text, String chatId, MessageEnum message, {String path = ''}) async{
    if(text!.isNotEmpty){
      var date = DateTime.now();
      var messageData = {'userName': ref.read(authentication).getCurrentUser()!.displayName,'message': Encrypt.encrypt(text), 'date' : date, 'photoURL' : ref.read(authentication).getCurrentUser()!.photoURL, 'type' : message.description, 'path' : path};            
      firestore.collection('connections').doc(chatId).collection('messages').doc().set(messageData);
      String msg;
      switch (message) {
        case MessageEnum.image:
          msg = '📷​ Image';
          break;
        case MessageEnum.audio:
          msg = '🎙️ Audio';
          break;
        case MessageEnum.gif:
          msg = '🖼️​ GIF'; 
          break;
        case MessageEnum.video:
          msg = '🎬​ Video';
          break;
        case MessageEnum.text:
          msg = text;
          break;
      }
      firestore.collection('connections').doc(chatId).update({'lastMessage' : Encrypt.encrypt(msg), 'date' : DateFormat('kk:mm').format(date)});
      var connection = await getChatById(chatId);
      var user = ref.read(authentication).getCurrentUser();
      var myself = connection.users!.firstWhere((e) => e.uid == user!.uid);
      connection.users!.remove(myself);
      FirebaseApi().sendPushNotification(connection: connection, message: "${user!.displayName}: $msg");      
    }
  }

  void sendImage(File file, String chatId, MessageEnum message) async{
    var user = ref.read(authentication).getCurrentUser();
    var path = 'connection/$chatId/${message.description}/${user!.uid}/${file.path}';
    String imageURL = await ref.read(firebaseStorageRepository).storeFileToFirebase(path, file);
    sendMessage(imageURL, chatId, message, path: path);
  }

  void sendGIF(String gifUrl, String chatId, MessageEnum message) async{
    int gifUrlPartIndex = gifUrl.lastIndexOf('-') + 1;
    String gifUrlPart = gifUrl.substring(gifUrlPartIndex);
    String newGifUrl = 'https://i.giphy.com/media/$gifUrlPart/200.gif';
    sendMessage(newGifUrl, chatId, message);
  }

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
    if (chat.docs.isEmpty) return { 'value' : 'Connection not found'};    
    var data = await firestore.collection('connections').doc(chat.docs.first.id).get();
    userList = data['users'];
    if (userList!.where((element) => element == user.uid).isNotEmpty ) return { 'value' : "You're already in that connection"};    
    userList!.add(user.uid);
    return {"id" : data.id, 'value': null};
  }

  Future<Connection> enterInChat(String chatId) async {
    var newdata = {'users' : userList};
    await firestore.collection('connections').doc(chatId).update(newdata);
    userList!.clear();
    var obj = await getChatById(chatId);
    return obj; 
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> updateNameConnection(String chatId, String newName) async {
    var newdata = {'roomName' : newName};
    await firestore.collection('connections').doc(chatId).update(newdata);
    var doc = await firestore.collection('connections').doc(chatId).get();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> verificarUser(String chatId) {
    var user = ref.read(authentication).getCurrentUser()!;
    return firestore.collection('connections')    
    .where('users', arrayContains: user.uid)
    .where('chatId', isEqualTo: chatId)
    .snapshots();
  }

  Future<void> removerUser(String chatId, String userId) async {
    try {
      var data = await firestore.collection('connections').doc(chatId).get();
      userList = data['users'];
      userList!.remove(userId);
      var newdata = {'users' : userList};
      await firestore.collection('connections').doc(chatId).update(newdata);
      userList!.clear(); 
    } catch (e) {
      throw "Não foi possível remover";
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      var list = await getAllMessagesFileChat(chatId);
      List listUrlFiles = [];
      for (var element in list.docs) {
        listUrlFiles.add(element['path']);
      }    
      if(listUrlFiles.isNotEmpty){
        ref.read(firebaseStorageRepository).deleteFileToFirebase(listUrlFiles);
      }      
      var documents = await firestore.collection('connections').doc(chatId).collection('messages').get();
      for (DocumentSnapshot doc in documents.docs) {
        await doc.reference.delete();
      }
      await firestore.collection('connections').doc(chatId).delete();
    } catch (e) {
      throw "Não foi possível sair";
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChats() {
    var user = ref.read(authentication).getCurrentUser()!;
    var teste =  firestore.collection('connections').where('users', arrayContains: user.uid.toString()).snapshots();    
    return teste;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllMessagesFileChat(String chatId) {    
    Future<QuerySnapshot<Map<String, dynamic>>> data = firestore.collection('connections')
    .doc(chatId).collection('messages')
    .where("path", isNotEqualTo: "")
    .get();
    return data;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessagesChat(String chatId){ 
    return firestore.collection('connections').doc(chatId).collection('messages').orderBy("date", descending: false).snapshots();
  }

  Future<Connection> getChatById(String chatId) async { 
    var obj = await firestore.collection('connections').doc(chatId).get();   
    var chatData = Connection.fromObject(obj); 
    await ref.read(authentication).getUsers(chatData.userIds!).then((value) async {
      chatData.users = value;                           
    });
    return chatData;
  }
  
  gerarCode() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
  
}