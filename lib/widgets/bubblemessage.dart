import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lechat/models/message.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:intl/intl.dart';

class BubbleMessage extends StatefulWidget {
  final Message message;
  const BubbleMessage({super.key, required this.message});

  @override
  State<BubbleMessage> createState() => _BubbleMessageState();
}

class _BubbleMessageState extends State<BubbleMessage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: widget.message.photoURL!,
              fit: BoxFit.cover,
              height: 40,
              width: 40,
              placeholder: (context, url) => Container(color: Colors.black12,),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(    
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(widget.message.userName!, style: const TextStyle(color: Couleurs.white, fontWeight: FontWeight.bold,fontFamily: 'Glass Antiqua', fontSize: 16),),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(formatarDate(widget.message.date!), style: const TextStyle(color: Couleurs.primaryColor, fontFamily: 'Glass Antiqua', fontSize: 14),),
                  ),          
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(width: width * 0.8, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.message.messages!
                )),
              ),   
            ],
          )
        ],
      )
    );
  }
  
  String formatarDate(Timestamp? date) {
    
    var dia = DateFormat('dd/MM/yyyy ').format(date!.toDate());

    //today
    if(date.toDate().day == DateTime.now().day){
      dia = 'Hoje às ';
    }
    if(date.toDate().day == (DateTime.now().day - 1)){
      dia = 'Ontem às ';
    }

    var hora =  DateFormat('kk:mm').format(date.toDate());
    return dia+hora;
  }
}