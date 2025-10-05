import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../providers/shorts_provider.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    // Listen for scroll to bottom and load more
    // _pageController.addListener(() {
    //   final provider = context.read<ShortsProvider>();
    //   final currentPage = _pageController.page ?? 0;
    //
    //   if (currentPage >= provider.shorts.length - 2 && provider.hasMore) {
    //     provider.fetchShorts(loadMore: true);
    //   }
    // });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ShortsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.shorts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.shorts.isEmpty) {
          return const Center(child: Text('No shorts available'));
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: provider.shorts.length,
          itemBuilder: (context, index) {
            final short = provider.shorts[index];
            final videoId = YoutubePlayer.convertUrlToId(short.videoUrl);

            if (videoId == null) {
              return const Center(child: Text('Invalid video link'));
            }

            return YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: true,
                  loop: true,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
            );
          },
        );
      },
    );
  }
}