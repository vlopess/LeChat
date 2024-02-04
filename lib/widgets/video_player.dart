import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  final String dataSource;
  const VideoPlayer({super.key, required this.dataSource});

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late CachedVideoPlayerController controller;
  bool isplay = false;
  @override
  void initState() {    
    super.initState();
    controller = CachedVideoPlayerController.network(widget.dataSource)..initialize().then((value) {
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
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _onTapPlay,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedVideoPlayer(controller)
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