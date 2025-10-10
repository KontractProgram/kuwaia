import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DiaryToolLearningVideoScreen extends StatefulWidget {
  final String videoLink;
  const DiaryToolLearningVideoScreen({super.key, required this.videoLink});

  @override
  State<DiaryToolLearningVideoScreen> createState() => _SDiaryToolLearningVideoScreenState();
}

class _SDiaryToolLearningVideoScreenState extends State<DiaryToolLearningVideoScreen> {
  late String _videoId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _videoId = YoutubePlayer.convertUrlToId(widget.videoLink)!;
    });

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
          child: _videoId.isEmpty
            ? Center(child: CircularProgressIndicator(),)
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