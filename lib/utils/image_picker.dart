import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lechat/components/customsnackbar.dart';

Future<File?> pickImageFromGallery(BuildContext context) async {
  File? image;
  try {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      image = File(pickedImage.path);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: e.toString(), cor: Colors.lightBlueAccent)));                            
  }
  return image; 
} 