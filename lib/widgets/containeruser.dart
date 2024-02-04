// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/components/customsnackbar.dart';
import 'package:lechat/models/user_model.dart';
import 'package:lechat/service/message.dart';
import 'package:lechat/utils/couleurs.dart';

class ContainerUser extends StatefulWidget {
  final Usuario user;
  final String userCreateID;
  final String userID;
  final String chatID;
  const ContainerUser({super.key, required this.user, required this.userCreateID, required this.userID, required this.chatID});

  @override
  State<ContainerUser> createState() => _BubbleMessageState();
}

class _BubbleMessageState extends State<ContainerUser> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: GestureDetector(        
        onLongPress:  () { 
          if (widget.userCreateID == widget.userID && widget.userCreateID != widget.user.uid) {            
            _openDialogCreateRoom();
          }
        },
        child: Container(
          color: Couleurs.greyMedium,
          width: width * 0.30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  key: UniqueKey(),
                  imageUrl: widget.user.profilePic!,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                  placeholder: (context, url) => Container(color: Colors.black12,),
                ),
              ),
              Column(
                children: [
                  Row(    
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(widget.user.name!, style: const TextStyle(color: Couleurs.white, fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 16),),
                      ), 
                      Visibility(
                        visible: widget.userCreateID == widget.user.uid,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Couleurs.greyVeryLight,
                            border: Border.all(color: Couleurs.greyVeryLight),                        
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text('Creater', style: TextStyle(color: Couleurs.white, fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 12),),
                          )
                        ),
                      ),        
                    ],
                  ),  
                ],
              )
            ],
          ),
        ),
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
            child: DialogRemoveUser(user: widget.user,chatId: widget.chatID,)
          ),
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
                        await ref.read(message).removerUser(widget.chatId, widget.user.uid!).then((_) => Navigator.pop(context));                                                        
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
