import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String dataSource;
  const VideoPlayerItem({super.key, required this.dataSource});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController controller;
  bool isplay = false;
  @override
  void initState() {    
    super.initState();
    controller = VideoPlayerController.network(widget.dataSource)..initialize().then((value) {
        controller.setVolume(1);
        controller.setLooping(true);
    });
  } 

  @override
  void dispose() {    
    super.dispose();
    controller.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 16,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _onTapPlay,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: VideoPlayer(controller)
            ),
          ),
          Visibility(
            visible: !isplay,
            child: const Align(
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_outline)
            ),
          )
        ],
      ),
    );
  }
  
  _onTapPlay() {
    if (isplay) {
      controller.pause();
    }else{
      controller.play();
    }
    setState(() {
      isplay = !isplay;
    });
  }
}