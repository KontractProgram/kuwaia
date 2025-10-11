import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DiaryToolLearningVideoScreen extends StatefulWidget {
  final String videoLink;
  const DiaryToolLearningVideoScreen({super.key, required this.videoLink});

  @override
  State<DiaryToolLearningVideoScreen> createState() => _DiaryToolLearningVideoScreenState();
}

class _DiaryToolLearningVideoScreenState extends State<DiaryToolLearningVideoScreen> {
  late final String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoLink);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: leadingButton(context),
      ),

      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.black,
          child: _videoId == null
            ? const Center(
              child: Text(
                'Invalid or unsupported YouTube link',
                style: TextStyle(color: Colors.white),
              ),
            )
            : YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: _videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                loop: true,
                mute: false,
              ),
            ),
            showVideoProgressIndicator: true,
          ),
        ),
      ),
    );
  }

}