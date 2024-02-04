import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/models/connection_chat_model.dart';
import 'package:lechat/screens/cadastre_screen.dart';
import 'package:lechat/screens/chat_screen.dart';
import 'package:lechat/screens/login_screen.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/service/message.dart';
import 'package:lechat/utils/couleurs.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String id = 'Home_screen';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin{
  late Animation<double> _animation;
  late AnimationController _animationController;
  User? loggedInUser;

  void getCurrentUser() async {    
    try {
      final user = ref.read(authentication).getCurrentUser();
      log(user.toString());
      if(user != null){
        loggedInUser = user;
      }
    } catch (e) {
      //log(e.toString());
    }
  }

  @override
  void initState(){        
    getCurrentUser();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);        
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleurs.greyDark,
      appBar: AppBar(
         foregroundColor: Colors.grey,          
          elevation: 0,
          backgroundColor: Couleurs.greyVeryLight,
          centerTitle: false,
          title: const Text(
            'Le Chat',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: 'Barlow'
            ),
          ),
          // actions: [
          //   // IconButton(
          //   //   icon: const Icon(Icons.search, color: Colors.grey),
          //   //   onPressed: () {},
          //   // ),
          //   // IconButton(
          //   //   icon: const Icon(Icons.more_vert, color: Colors.grey),
          //   //   onPressed: () {},
          //   // ),
          // ],
      ),
      drawer: Drawer(
        backgroundColor: Couleurs.greyDark,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          padding: EdgeInsets.zero,
          children:  [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Couleurs.greyVeryLight,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CachedNetworkImage(
                          key: UniqueKey(),
                          imageUrl: loggedInUser!.photoURL!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.black12,),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                  Text(loggedInUser!.displayName!, style: const TextStyle(fontSize: 25, fontFamily: 'Glass Antiqua')),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Settings', style: TextStyle(color: Couleurs.white)),
              onTap: () {
                Navigator.pushNamed(context, CadastreScreen.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_sharp),
              title: const Text('Sign Out', style: TextStyle(color: Couleurs.white)),
              onTap: () {
                ref.read(authentication).logout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen(),), (route) => false);
              },
            ),
          ],
        ),
      ),
      body: const ContactsList(),
      floatingActionButton: FloatingActionBubble(
        items: [
          Bubble(icon: Icons.group_add, iconColor: Couleurs.white, title: 'Create a room', titleStyle: const TextStyle(fontSize: 12, fontFamily: 'Barlow', fontWeight: FontWeight.bold), bubbleColor: Couleurs.greyVeryLight, onPress: () {_animationController.isCompleted ? _animationController.reverse(): _animationController.forward();_openDialogCreateRoom();}),
          Bubble(icon: Icons.group, iconColor: Couleurs.white, title: 'Join a room', titleStyle: const TextStyle(fontSize: 12, fontFamily: 'Barlow', fontWeight: FontWeight.bold), bubbleColor: Couleurs.greyVeryLight, onPress: () { _animationController.isCompleted ? _animationController.reverse(): _animationController.forward(); _openDialogJoinRoom();}),
        ],
        onPress: () => _animationController.isCompleted ? _animationController.reverse(): _animationController.forward(),
        iconColor: Couleurs.white,
        backGroundColor: Couleurs.greyVeryLight,
        animation: _animation,
        iconData: Icons.message,
      )
    );
  }

  void _openDialogCreateRoom() {
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
            child: const CustomAlertDialogCreateRoom()
          ),
      ),      
    );
  }

  void _openDialogJoinRoom() {
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
            child: const CustomAlertDialogJoinRoom()
          ),
      ),      
    );
  }
}


class CustomAlertDialogJoinRoom extends ConsumerStatefulWidget {
  const CustomAlertDialogJoinRoom({super.key});

  @override
  ConsumerState<CustomAlertDialogJoinRoom> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends ConsumerState<CustomAlertDialogJoinRoom> {
  bool isLoading = false;    
  String? codeChat;
  Map<String, String?> hasCodeOrUser = {};
  final _formKey = GlobalKey<FormState>();  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Couleurs.greyDark,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Enter the room code", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              style: const TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),
              textAlign: TextAlign.center,
              onChanged:(value) async{
                codeChat = value;
                hasCodeOrUser = await ref.read(message).existsCodeOrUser(value);                     
              },              
              decoration: const InputDecoration(
                hintText: 'Enter code',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                                        
                hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
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
                return hasCodeOrUser['value'];
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
                  log(hasCodeOrUser.toString());
                  hasCodeOrUser['id'] ?? '';
                  ref.read(message).enterInChat(hasCodeOrUser['id']!).then((obj) async { 
                    var contactChat = Connection.fromObject(obj);
                    await ref.read(authentication).getUsers(contactChat.userIds!).then((value) async {
                      contactChat.users = value;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreen(contactChat: contactChat,));                             
                    });
                  });                  
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: const Text('Enter now', style: TextStyle(color: Couleurs.greyVeryLight, fontFamily: 'Glass Antiqua', fontSize: 20),)
            ),
          )
        ],
      ),
    );
  }

}


class CustomAlertDialogCreateRoom extends ConsumerStatefulWidget {
  const CustomAlertDialogCreateRoom({super.key});

  @override
  ConsumerState<CustomAlertDialogCreateRoom> createState() => _CustomAlertDialogCreateRoomState();
}

class _CustomAlertDialogCreateRoomState extends ConsumerState<CustomAlertDialogCreateRoom> {
  bool isLoading = false;    
  bool showCode = false;    
  late String _roomName;
  final _formKey = GlobalKey<FormState>();  
  String? code;  
  bool iscopied = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Couleurs.greyDark,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: Text("Create Room", style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),),
          ),
          Visibility(
            visible: !showCode,
            child: Form(
              key: _formKey,
              child: TextFormField(
                style: const TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),
                textAlign: TextAlign.center,
                onChanged:(value) {
                  _roomName = value;
                },              
                decoration: const InputDecoration(
                  hintText: 'Enter room name',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                                        
                  hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
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
                    return 'Please room name';
                  }
                  return null;
                },
              ),
            ),
          ),
          Visibility(
            visible: !showCode,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: isLoading? const CircularProgressIndicator(backgroundColor: Couleurs.greyVeryLight,strokeWidth: 3,):
              TextButton(
                onPressed: () async {                              
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });   
                    await ref.read(message).createChat(_roomName).then((value) {
                      setState(() {
                        isLoading = false;
                        showCode = true;
                        code = value;
                      });
                      //Navigator.pop(context);
                    });
                  }
                  
                },
                child: const Text('Create')
              ),
            ),
          ),
          Visibility(
            visible: showCode,
            child: Container(
              decoration: BoxDecoration(
                color: Couleurs.blackCat,
                borderRadius: BorderRadius.circular(8.0),                                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,              
                children: [
                  const Text("Code:", style: TextStyle(fontSize: 25, fontFamily: 'Glass Antiqua', color: Couleurs.white)),
                  SelectionArea(child: Text(code.toString(), style: const TextStyle(fontSize: 25, fontFamily: 'Glass Antiqua', color: Couleurs.white),)),
                  IconButton(
                    onPressed: () async{
                      await Clipboard.setData(ClipboardData(text: code.toString()));
                      setState(() {
                        iscopied = true;
                      });
                    },
                    icon: Icon(iscopied ? Icons.check :  Icons.copy)
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


class ContactsList extends ConsumerStatefulWidget {
  const ContactsList({super.key});

  @override
  ConsumerState<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends ConsumerState<ContactsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ref.read(message).getAllChats(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(color: Couleurs.greyVeryLight,));
        }
        if (snapshot.hasData) {          
          var chatList = snapshot.data!.docs.reversed;
          List<ContainerContact> chats = [];
          for (var element in chatList) {
            var chat = Connection.fromObject(element);
            chats.add(ContainerContact(contactChat: chat));
          }
          return ListView(
            physics: const BouncingScrollPhysics(), 
            children: chats.reversed.toList(), 
          );
        }
        return Container();
      },
    );
  }
}

class ContainerContact extends ConsumerStatefulWidget {
  final Connection contactChat;
  const ContainerContact({super.key, required this.contactChat});

  @override
  ConsumerState<ContainerContact> createState() => _ContainerContactState();
}

class _ContainerContactState extends ConsumerState<ContainerContact> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Material(
            color: Couleurs.greyDark,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            elevation: 5.0,
            child: MaterialButton(
              onPressed: () async{
                await ref.read(authentication).getUsers(widget.contactChat.userIds!).then((value) async {
                  widget.contactChat.users = value;
                  Navigator.pushNamed(context, ChatScreen.id, arguments: ChatScreen(contactChat: widget.contactChat,));                             
                });
              },
              child: ListTile(
                title: Text(
                  widget.contactChat.roomName!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Couleurs.white
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    widget.contactChat.lastMessage?? "",
                    style: const TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis, color: Couleurs.white),
                  ),
                ),
                trailing: Text(
                  widget.contactChat.date!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

