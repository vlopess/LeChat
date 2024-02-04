// ignore_for_file: use_build_context_synchronously
import 'dart:io';
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
import 'package:lechat/utils/image_picker.dart';
import 'package:lechat/utils/message_enum.dart';
import 'package:lechat/widgets/bubblemessagetext.dart';
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
                await ref.read(authentication).getUserById(args.contactChat!.userCreateID).then((value) async {
                  user = value;                  
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
              stream: ref.read(message).verificarUser(args.contactChat!.chatId!), 
              builder: (context, snapshot) {                
                if (snapshot.hasData) {          
                  var doc =  snapshot.data!.docs;
                  return doc.isEmpty? const DialogRemovedUser() : StreamBuilder(
                    stream: ref.read(message).getAllMessagesChat(args.contactChat!.chatId!),
                    builder: (context, snapshot) {                                         
                      if (snapshot.hasData) {
                        var messages = snapshot.data!.docs.reversed;
                        List<Widget> historicChat = [];
                        List<Message>? list = [];
                        Message? last;
                        for (var message in messages) {
                          var bubbleMessage = Message.fromObject(message);   
                          if (last?.userName != null){                      
                            if (last?.userName == bubbleMessage.userName && last!.date!.toDate().day == bubbleMessage.date!.toDate().day) {
                              historicChat.add(BubbleMessageText(message: bubbleMessage,isSameUser: false,));    
                              //list.add(Message(userName: bubbleMessage.userName, message: Encrypt.decrypt(bubbleMessage.message.toString()), date: bubbleMessage.date, photoURL: bubbleMessage.photoURL, type: bubbleMessage.type));  
                              //Text(Encrypt.decrypt(bubbleMessage.message.toString()), style: const TextStyle(color: Couleurs.white, fontFamily: 'Glass Antiqua', overflow: TextOverflow.visible, fontSize: 16))
                            }else {
                              // for (var element in list) {
                              //   last!.messages!.insert(0,element);                        
                              // }                        
                              historicChat.add(BubbleMessageText(message: bubbleMessage,isSameUser: false,));    
                              if(bubbleMessage.date!.toDate().day != bubbleMessage.date!.toDate().day) historicChat.add(DividerData(date: bubbleMessage.date,)); 
                              list.clear(); 
                              last = bubbleMessage; 
                            } 
                          }else{
                            last = bubbleMessage;
                            historicChat.add(BubbleMessageText(message: last,isSameUser: false,));    
                          }
                          // if(messages.last == message) {
                          //   for (var element in list) {
                          //     last.messages!.insert(0,element);                        
                          //   }
                          //   if(last.date!.toDate().day != bubbleMessage.date!.toDate().day) historicChat.add(DividerData(date: last.date,)); 
                          //   historicChat.add(BubbleMessageText(message: last));    
                          //   historicChat.add(DividerData(date: bubbleMessage.date,)); 
                          // }
                                          
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
                  );
                }
                return Container();
              },
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [                
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Couleurs.greyVeryLight,
                        borderRadius: BorderRadius.all(Radius.circular(20.0),
                      ),
                    ),
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
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),               
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Couleurs.greyVeryLight,
                        borderRadius: BorderRadius.all(Radius.circular(20.0),
                      ),
                    ), 
                    child: IconButton(
                    onPressed: () {                      
                      _sendImage(args.contactChat!.chatId!);
                    }, 
                    icon: const Icon(Icons.camera_alt, color: Couleurs.white,),
                    splashColor: Couleurs.greyVeryLight,
                    ),
                  ),
                ),    
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Couleurs.greyVeryLight,
                        borderRadius: BorderRadius.all(Radius.circular(20.0),
                      ),
                    ), 
                    child: IconButton(
                    onPressed: () {                      
                      _sendVideo(args.contactChat!.chatId!);
                    }, 
                    icon: const Icon(Icons.attach_file, color: Couleurs.white,),
                    splashColor: Couleurs.greyVeryLight,
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
                      minWidth: 25,
                      onPressed: () => sendMessage(args.contactChat!.chatId!),
                      child: const Icon(Icons.send, color: Couleurs.white,size: 20),
                      )
                  )
                ),      
              ],
            )
          ],
        )
      ),
    );
  }

  Container modalBottomContent(double height, double width, Connection? contactChat,Usuario userCreate) {    
    String? userID = ref.read(authentication).getCurrentUser()?.uid;    
    return Container(
      decoration: const BoxDecoration(
        color: Couleurs.greyVeryLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25)
        )
      ),
      height: height * 0.66,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 15),
                child: Row(
                  children: [
                    Text(contactChat!.roomName!,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Glass Antiqua'
                      ),
                    ),
                    Visibility(visible: contactChat.userCreateID! == userID,child: IconButton(onPressed: () {
                      Navigator.pop(context);
                      _openDialogEditName(contactChat);
                    }, icon: const Icon(Icons.edit, color: Colors.grey,))),
                  ],
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
                          return ContainerUser(user: contactChat.users![index], userCreateID: contactChat.userCreateID!,userID: userID!,chatID: contactChat.chatId!,);
                        },
                      ),
                    ),
                    if(contactChat.userCreateID! != userID)...[
                      ButtonExitConnection(chatId: contactChat.chatId!,)
                    ] else ...[
                      ButtonDeleteConnection(chatId: contactChat.chatId!,) 
                    ]               
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
    ref.read(message).sendMessage(controller.text.trim(), chatId, MessageEnum.text);
    controller.clear();
  }

  void _openDialogEditName(Connection contactChat) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context, 
      pageBuilder: (context, animation, secondaryAnimation) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child)  => 
        ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: CustomAlertDialogEditName(contactChat: contactChat)
          ),
      ),      
    );
  }
  
  _sendImage(String chatId) async {
    File? file = await pickImageFromGallery(context);
    if(file != null){
      ref.read(message).sendImageGIF(file, chatId, MessageEnum.image);
    }
  }

  _sendVideo(String chatId) async {
    File? file = await pickVideoFromGallery(context);
    if(file!= null){
      ref.read(message).sendImageGIF(file, chatId, MessageEnum.video);
    }
  }
}

class ButtonExitConnection extends ConsumerStatefulWidget {
  final String chatId;
  const ButtonExitConnection({super.key, required this.chatId});

  @override
  ConsumerState<ButtonExitConnection> createState() => _ButtonExitConnectionState();
}

class _ButtonExitConnectionState extends ConsumerState<ButtonExitConnection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Material(
      color: Colors.redAccent,                
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),                    
      child: MaterialButton(
        height: 50,
        minWidth: double.infinity,
        onPressed: () async{
          try {
            await ref.read(message).exitInChat(widget.chatId).then((_) => Navigator.pushReplacementNamed(context, HomeScreen.id));                                                        
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                                                          
          }
        },
        child: const Text('Exit',
            style: TextStyle(
              color: Couleurs.white,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 22
            )
          ),
        )
      ),
    );
  }
}


class ButtonDeleteConnection extends ConsumerStatefulWidget {
  final String chatId;
  const ButtonDeleteConnection({super.key, required this.chatId});

  @override
  ConsumerState<ButtonDeleteConnection> createState() => _ButtonDeleteConnectionState();
}

class _ButtonDeleteConnectionState extends ConsumerState<ButtonDeleteConnection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Material(
      color: Colors.redAccent,                
      borderRadius: const BorderRadius.all(Radius.circular(50.0)),                    
      child: MaterialButton(
        height: 50,
        minWidth: double.infinity,
        onPressed: () async{
          try {
            Navigator.pushReplacementNamed(context, HomeScreen.id);
            await ref.read(message).deleteChat(widget.chatId); 
          } catch (e) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                                                          
          }
        },
        child: const Text('Delete Connection',
            style: TextStyle(
              color: Couleurs.white,fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 22
            )
          ),
        )
      ),
    );
  }
}


class DialogRemoveUser extends ConsumerStatefulWidget {
  final Usuario user;
  final String chatId;
  const DialogRemoveUser({super.key, required this.chatId, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DialogRemoveUserState();
}

class _DialogRemoveUserState extends ConsumerState<DialogRemoveUser> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Couleurs.greyDark,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text("Remove ${widget.user.name}?", style: const TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua', fontSize: 22),),
          ), 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.redAccent,                
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    minWidth: 65,
                    height: 50,
                    onPressed: () => Navigator.pop(context), 
                    child: const Text("No", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),)
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Couleurs.greyVeryLight,                
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    minWidth: 65,
                    height: 50,
                    onPressed: () async{
                      try {
                        await ref.read(message).removerUser(widget.chatId, widget.user.uid!).then((_) => Navigator.pushReplacementNamed(context, HomeScreen.id));                                                        
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                                                          
                      }
                    },
                    child: const Text("Yes", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),)
                  ),
                ),
              ),
            ],
          )                 
        ],
      ),
    );
  }
}

class DialogRemovedUser extends ConsumerStatefulWidget {
  const DialogRemovedUser({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DialogRemovedUserState();
}

class _DialogRemovedUserState extends ConsumerState<DialogRemovedUser> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      backgroundColor: Couleurs.greyDark,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("The connection is over for you", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua', fontSize: 22),),
          ), 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.redAccent,                
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              elevation: 5.0,
              child: MaterialButton(
                minWidth: 65,
                height: 50,
                onPressed: () => Navigator.pop(context), 
                child: const Text("Ok", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),)
              ),
            ),
          ),             
        ],
      ),
    );
  }
}


class CustomAlertDialogEditName extends ConsumerStatefulWidget {
  final Connection? contactChat;
  const CustomAlertDialogEditName({super.key, required this.contactChat});

  @override
  ConsumerState<CustomAlertDialogEditName> createState() => _CustomAlertDialogEditNameState();
}

class _CustomAlertDialogEditNameState extends ConsumerState<CustomAlertDialogEditName> {
  bool isLoading = false;    
  String? codeChat;
  final _formKey = GlobalKey<FormState>();
  late String newName;  
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Couleurs.greyDark,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Enter the new name", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),),
          ),
          Form(
            key: _formKey,
            child: TextFormField(              
              initialValue: widget.contactChat!.roomName,
              style: const TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),
              textAlign: TextAlign.center,    
              onChanged: (value) {
                newName = value;
              },                       
              decoration: const InputDecoration(
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter code';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: isLoading ? const CircularProgressIndicator(backgroundColor: Couleurs.greyVeryLight,strokeWidth: 3,):
            TextButton(            
              onPressed: () {
                setState(() {
                    isLoading = true;
                });
                if (_formKey.currentState!.validate()) {                                    
                  ref.read(message).updateNameConnection(widget.contactChat!.chatId!, newName).then((obj) async{
                    var contactChat = Connection.fromObject(obj);
                    await ref.read(authentication).getUsers(contactChat.userIds!).then((value) async {
                      contactChat.users = value;
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, ChatScreen.id, arguments: ChatScreen(contactChat: contactChat,));                             
                    });}
                  );
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text('Update', style: TextStyle(color: Couleurs.greyVeryLight, fontFamily: 'Glass Antiqua', fontSize: 20),)
            ),
          )
        ],
      ),
    );
  }

}


