import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lechat/models/user_model.dart';
import 'package:lechat/utils/couleurs.dart';

class ContainerUser extends StatefulWidget {
  final Usuario user;
  final bool isCreater;
  const ContainerUser({super.key, required this.user, required this.isCreater});

  @override
  State<ContainerUser> createState() => _BubbleMessageState();
}

class _BubbleMessageState extends State<ContainerUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
                    visible: widget.isCreater,
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
      )
    );
  }
}