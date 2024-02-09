import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lechat/models/message.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:intl/intl.dart';
import 'package:lechat/utils/message_enum.dart';
import 'package:lechat/widgets/video_player.dart';

class BubbleMessageText extends StatefulWidget {
  final Message message;
  final bool isSameUser;
  const BubbleMessageText({super.key, required this.message, required this.isSameUser});

  @override
  State<BubbleMessageText> createState() => _BubbleMessageTextState();
}

class _BubbleMessageTextState extends State<BubbleMessageText> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(       
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: !widget.isSameUser,
            child: ClipRRect(
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
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: !widget.isSameUser,
                child: Row(    
                  mainAxisSize: MainAxisSize.min,
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(
                  //height: height, 
                  width: width * 0.8,
                  child: widget.message.type?.description == MessageEnum.text.description ?
                  Text(widget.message.message!,style: const TextStyle(color: Couleurs.white, fontFamily: 'Glass Antiqua', overflow: TextOverflow.visible, fontSize: 16)):
                  widget.message.type?.description == MessageEnum.image.description ?
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5), 
                    child: ClipRRect(borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      key: UniqueKey(),
                      imageUrl: widget.message.message!,
                      fit: BoxFit.cover,
                      //placeholder: (context, url) => Container(color: Colors.black12),
                      progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(width: 10,height: 10,child: CircularProgressIndicator(color: Couleurs.primaryColor,value: downloadProgress.progress)),
                      ),
                    ),
                  ): 
                  widget.message.type?.description == MessageEnum.video.description ? 
                  VideoPlayerItem(dataSource: widget.message.message!): 
                  widget.message.type?.description == MessageEnum.gif.description ? 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5), 
                    child: ClipRRect(borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      key: UniqueKey(),
                      imageUrl: widget.message.message!,
                      fit: BoxFit.cover,
                      //placeholder: (context, url) => Container(color: Colors.black12),
                      progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(width: 10,height: 10,child: CircularProgressIndicator(color: Couleurs.primaryColor,value: downloadProgress.progress)),
                      ),
                    ),
                  ):
                  const Text('data'),
                ),
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