import 'package:flutter/material.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../models/update_model.dart';
import '../../../providers/updates_provider.dart';
import '../../../widgets/toast.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdatesScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Add the listener for infinite scroll
    _pageController.addListener(_scrollListener);
  }

  // Unified scroll listener for infinite scroll
  void _scrollListener() {
    final provider = Provider.of<UpdatesProvider>(context, listen: false);
    final currentPage = _pageController.page ?? 0;

    // Load more when 2 items away from the end, only if more items exist
    if (provider.hasMore && !provider.isLoading &&
        currentPage >= provider.updates.length - 2) {
      provider.fetchUpdates(loadMore: true);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<UpdatesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.updates.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.updates.isEmpty) {
          return const Center(child: Text('No updates available'));
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: provider.updates.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.updates.length) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ));
            }

            final update = provider.updates[index];

            if(update.isYoutubeLink){
              final videoId = YoutubePlayer.convertUrlToId(update.contentUrl);

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
            }
            else {
              return NonYoutubeCard(update: update);
            }

          },
        );
      },
    );
  }
}



class NonYoutubeCard extends StatefulWidget {
  final UpdateModel update;

  const NonYoutubeCard({super.key, required this.update});

  @override
  State<NonYoutubeCard> createState() => _NonYoutubeCardState();
}

class _NonYoutubeCardState extends State<NonYoutubeCard> {
  late VideoPlayerController _videoController;
  bool _isVideo = false;
  bool _isInitialized = false;

  // Helper function to check for common video extensions
  bool _isContentVideo(String url) {
    final lowerCaseUrl = url.toLowerCase();
    return lowerCaseUrl.endsWith('.mp4') ||
        lowerCaseUrl.endsWith('.mov') ||
        lowerCaseUrl.endsWith('.webm') ||
        lowerCaseUrl.endsWith('.mkv');
  }

  @override
  void initState() {
    super.initState();
    _isVideo = _isContentVideo(widget.update.contentUrl);

    if (_isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.update.contentUrl))
        ..initialize().then((_) {
          // Ensure the video is ready, set to loop, and play
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _videoController.setLooping(true);
            _videoController.play();
          }
        }).catchError((e) {
          // Handle error if video fails to load (e.g., fallback to image)
          debugPrint('Error loading video: $e');
          if (mounted) {
            setState(() {
              _isVideo = false; // Fallback to displaying it as a broken image
              _isInitialized = true;
            });
          }
        });
    } else {
      _isInitialized = true; // Content is an image, so it's "initialized"
    }
  }

  @override
  void dispose() {
    if (_isVideo) {
      _videoController.dispose();
    }
    super.dispose();
  }

  Future<void> _launchRedirectUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showToast("Can't visit site");
    }
  }

  Widget _buildMediaWidget() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isVideo) {
      // Video Player UI
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
      );
    } else {
      // Image UI (Default for non-video files)
      return Image.network(
        widget.update.contentUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 50, color: Colors.white70),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The Main Content Card (80% width, 70% height)
          Container(
            width: size.width * 0.80,
            height: size.height * 0.65,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // MEDIA WIDGET (Image or Video)
                  _buildMediaWidget(),

                  // Title overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.update.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // The Action Button
          if (widget.update.redirectUrl != null && widget.update.redirectUrl!.isNotEmpty)
            SizedBox(
              width: size.width * 0.80,
              child: ElevatedButton.icon(
                onPressed: () => _launchRedirectUrl(widget.update.redirectUrl!),
                icon: const Icon(Icons.public, color: Colors.white), // icon color
                label: reusableText(
                  text: 'Learn More',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // text color
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccentColor, // main background color
                  foregroundColor: Colors.white, // text + ripple color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4, // optional subtle shadow
                ),
              ),
            )
        ],
      ),
    );
  }
}