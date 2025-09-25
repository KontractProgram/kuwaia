import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/in_tool/Video.dart';
import '../system/constants.dart';

class YoutubeVideoWidget extends StatefulWidget {
  final Video video;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const YoutubeVideoWidget({
    super.key,
    required this.video,
    this.onShare,
    this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late YoutubePlayerController _controller;
  String? _title;

  Future<void> _fetchYoutubeTitle(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      setState(() {
        _title = video.title;
      });
    } catch (e) {
      setState(() {
        _title = null; // fallback to "Untitled"
      });
    } finally {
      yt.close();
    }
  }

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.video.videoLink) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Fetch YouTube title async
    _fetchYoutubeTitle(widget.video.videoLink);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.secondaryBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// YouTube player
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.primaryAccentColor,
            ),
          ),

          const SizedBox(height: 8),

          /// Title beneath video (fetched via youtube_explode_dart)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: reusableText(
              text: _title ?? "Loading...",
              fontWeight: FontWeight.w600,
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ),

          /// Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: widget.onShare,
                icon: FaIcon(
                  FontAwesomeIcons.shareNodes,
                  size: 16,
                  color: AppColors.bodyTextColor.withAlpha(150),
                ),
              ),
              IconButton(
                onPressed: widget.onCopy,
                icon: FaIcon(
                  FontAwesomeIcons.copy,
                  size: 16,
                  color: AppColors.bodyTextColor.withAlpha(150),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 16,
                  color: AppColors.bodyTextColor.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
