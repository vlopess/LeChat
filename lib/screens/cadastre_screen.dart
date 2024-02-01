import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/components/customsnackbar.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:lechat/utils/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// ignore: must_be_immutable
class CadastreScreen extends ConsumerStatefulWidget {
  static String id = 'Cadastre_screen';
  String? userName;
  String? urlProfile;
  CadastreScreen({super.key});

  @override
  ConsumerState<CadastreScreen> createState() => _CadastreScreenState();
}

class _CadastreScreenState extends ConsumerState<CadastreScreen> {
  File? image;  
  bool saving = false;
  //        urlProfile ?? 'https://th.bing.com/th/id/OIP.UY0H6jNLhhjKymJWT6HsPwHaHa?rs=1&pid=ImgDetMain';


  selectImage()async{
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void storeUserData() async {
    setState(() {
      saving = true;
    });
    try {
      if (widget.userName != null) {
        ref.read(authentication).saveUserData(name: widget.userName!, profileImage: image,profilePic: widget.urlProfile,context: context);
      }      
    } catch (e) {
      setState(() {
        saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                            
    }
  }
  @override
  void initState() {
    var user = ref.read(authentication).getCurrentUser();
    setState(() {
      widget.urlProfile = user!.photoURL;
      widget.userName = user.displayName;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;    
    return Scaffold(
      backgroundColor: Couleurs.blackCat,
      body: ModalProgressHUD(
        blur: 0 ,
        opacity:  0,
        progressIndicator: const RefreshProgressIndicator(color: Couleurs.blackCat, backgroundColor: Couleurs.greyDark,),        
        inAsyncCall: saving,
        child: SafeArea( 
          child: Center(
            child: Column(
              children: [
               Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    Padding(
                      padding: const  EdgeInsets.all(8.0),
                      child: image == null ? CircleAvatar(
                        backgroundImage: NetworkImage(widget.urlProfile ?? 'https://th.bing.com/th/id/OIP.UY0H6jNLhhjKymJWT6HsPwHaHa?rs=1&pid=ImgDetMain'),
                        radius: 64,
                      ) :
                      CircleAvatar(
                        backgroundImage: FileImage(image!),
                        radius: 64,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 110,
                      child: IconButton(                    
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: selectImage,
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        initialValue: widget.userName,
                        style: const TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                        maxLength: 20,                      
                        textAlign: TextAlign.center,                      
                        onChanged: (value) {
                            widget.userName = value;                  
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',                        
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
                    IconButton(
                      onPressed: storeUserData,
                      icon: const Icon(Icons.done),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }    
}