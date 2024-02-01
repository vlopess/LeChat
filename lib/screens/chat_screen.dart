// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lechat/components/customsnackbar.dart';
import 'package:lechat/models/connection_chat_model.dart';
import 'package:lechat/models/message.dart';
import 'package:lechat/models/user_model.dart';
import 'package:lechat/screens/home_screen.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/service/message.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:lechat/widgets/bubblemessage.dart';
import 'package:lechat/widgets/containeruser.dart';
import 'package:lechat/widgets/dividerdata.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static String id = 'Chat_screen';  
  final Connection? contactChat;
  const ChatScreen( {super.key, this.contactChat});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  TextEditingController controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ChatScreen; 
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Couleurs.greyDark,
      appBar: AppBar(
         foregroundColor: Colors.grey,          
          elevation: 0,
          backgroundColor: Couleurs.greyVeryLight,
          centerTitle: false,
          title: SizedBox(
            width: width,
            child: TextButton(
              onPressed: () async {
                Usuario? user;
                await ref.read(authentication).getUsers(args.contactChat!.userIds!).then((value) async {
                  args.contactChat!.users = value;
                  user = await ref.read(authentication).getUserById(args.contactChat!.userCreateID);
                }).then((value) => showModalBottomSheet(
                    barrierColor: Colors.black.withOpacity(0.5),
                    useRootNavigator: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                    return modalBottomContent(height, width, args.contactChat, user!);
                  })
                );                
              },
              child: Column(
                children: [
                  Text(
                    args.contactChat!.roomName!,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Barlow'
                    ),
                  ),
                  const Text(
                    'Tap to see group informations',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Barlow'
                    ),
                  ),
                ],
              ),
            ),
          ),
          // actions: [
          //   PopupMenuButton(
          //     tooltip: '',
          //     itemBuilder: (BuildContext context)  => [ 
          //       PopupMenuItem(
          //         value: '',
          //         child: TextButton(
          //           onPressed: () async { 
          //             var code = args.contactChat!.chatId?.split('_');
          //             await Clipboard.setData(ClipboardData(text: code![0].toString()));
          //           }, 
          //           child: const Row(
          //             children: [
          //               Icon(Icons.copy),
          //               Text("Copy Code", style: TextStyle(color: Couleurs.greyVeryLight,fontWeight: FontWeight.bold,fontFamily: 'Barlow'),),
          //             ],
          //           ),
          //         )
          //       ),                    
          //     ],
          //   )
          // ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: ref.read(message).getAllMessagesChat(args.contactChat!.chatId!), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  var messages = snapshot.data!.docs.reversed;
                  List<Widget> historicChat = [];
                  List<Text>? list = [];
                  Message? last;
                  for (var message in messages) {
                    var bubbleMessage = Message.fromObject(message);   
                    if (last?.userName != null){                      
                      if (last?.userName == bubbleMessage.userName && last!.date!.toDate().day == bubbleMessage.date!.toDate().day) {
                        list.add(Text(bubbleMessage.message.toString(), style: const TextStyle(color: Couleurs.white, fontFamily: 'Glass Antiqua', overflow: TextOverflow.visible, fontSize: 16)));  
                      }else {
                        for (var element in list) {
                          last!.messages!.insert(0,element);                        
                        }                        
                        historicChat.add(BubbleMessage(message: last!));    
                        if(last.date!.toDate().day != bubbleMessage.date!.toDate().day) historicChat.add(DividerData(date: last.date,)); 
                        list.clear(); 
                        last = bubbleMessage; 
                      }
                    }else{
                      last = bubbleMessage;
                    }
                    if(messages.last == message) {
                      for (var element in list) {
                        last.messages!.insert(0,element);                        
                      }
                      if(last.date!.toDate().day != bubbleMessage.date!.toDate().day) historicChat.add(DividerData(date: last.date,)); 
                      historicChat.add(BubbleMessage(message: last));    
                      historicChat.add(DividerData(date: bubbleMessage.date,)); 
                    }
                                    
                  }
                  return Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(), 
                      children: historicChat.reversed.toList(),
                    ),
                  );
                }
                return Container();
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [                
                Expanded(
                  child: TextFormField(
                    maxLines: 10,
                    minLines: 1,
                    style: const TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter the messagem',
                      hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),  
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: Material(
                    color: Couleurs.greyVeryLight,                
                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),                    
                    child: MaterialButton(
                      height: 50,
                      onPressed: () => sendMessage(args.contactChat!.chatId!),
                      child: const Icon(Icons.send, color: Couleurs.white,),
                      )
                    )
                )          
              ],
            )
          ],
        )
      ),
    );
  }

  Container modalBottomContent(double height, double width, Connection? contactChat,Usuario userCreate) {    
    return Container(
      decoration: const BoxDecoration(
        color: Couleurs.greyVeryLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25)
        )
      ),
      height: height * 0.65,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
                child: Text(contactChat!.roomName!,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Glass Antiqua'
                  ),
                ),
              ),
              TextButton(
                onPressed: () async { 
                  var code = contactChat.chatId?.split('_');
                  await Clipboard.setData(ClipboardData(text: code![0].toString()));
                }, 
                child: const Row(
                  children: [
                    Icon(Icons.copy, color: Couleurs.blackCat),
                    Text("Copy Code", style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua'),),
                  ],
                ),
              )
            ],
          ),     
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text('${contactChat.users?.length} members', style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua'),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text('Created by ${userCreate.name} , ${DateFormat('dd/MM/yy').format(contactChat.dataCreate!.toDate())}', style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: 'Barlow'),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Members', 
                      style: TextStyle(
                        color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 22
                      )
                    ),
                    Container(
                      height: height * 0.32,
                      decoration: BoxDecoration(
                        color: Couleurs.greyMedium,
                        borderRadius: BorderRadius.circular(25)
                      ),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(), 
                        shrinkWrap: true,
                        itemCount: contactChat.users!.length,
                        itemBuilder: (context, index) {
                          return ContainerUser(user: contactChat.users![index], isCreater: contactChat.users![index].uid == contactChat.userCreateID,);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        color: Colors.redAccent,                
                        borderRadius: const BorderRadius.all(Radius.circular(50.0)),                    
                        child: MaterialButton(
                          height: 50,
                          minWidth: double.infinity,
                          onPressed: () async{
                            try {
                              await ref.read(message).exitInChat(contactChat.chatId!).then((_) => Navigator.pushReplacementNamed(context, HomeScreen.id));                                                        
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                                                          
                            }
                          },
                          child: const Text('Exit',
                              style: TextStyle(
                                color: Colors.grey,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 22
                              )
                            ),
                          )
                        ),
                    )  
                  ],
                ),
              )
            ],
          )                   
        ],
      ),
    );
  }

  void sendMessage(String chatId) {
    ref.read(message).sendMessage(controller.text.trim(), chatId);
    controller.clear();
  }
}

