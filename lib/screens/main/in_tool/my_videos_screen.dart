import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:kuwaia/widgets/youtube_video.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../models/in_tool/Video.dart';
import '../../../models/tool.dart';
import '../../../providers/ai_diary_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../system/constants.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/texts.dart';

class MyVideosScreen extends StatefulWidget {
  final Tool tool;
  const MyVideosScreen({super.key, required this.tool});

  @override
  State<MyVideosScreen> createState() => _MyVideosScreenState();
}

class _MyVideosScreenState extends State<MyVideosScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileId = context.read<AuthProvider>().profile!.id;
      Provider.of<AiDiaryProvider>(context, listen: false).fetchVideos(toolId: widget.tool.id);
    });
  }

  void _showAddVideoLinkModal(BuildContext context, Size size) {
    final videoLinkController = TextEditingController();
    final profileId = context.read<AuthProvider>().profile!.id;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: size.height * 0.9, // 90% of screen height
          decoration: BoxDecoration(
            color: AppColors.primaryBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              reusableText(
                text: "Add New Video",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: videoLinkController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "Video Link",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.bodyTextColor.withAlpha(150), width: 2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.secondaryAccentColor, width: 2)
                  ),
                ),
                style: TextStyle(fontFamily: montserratRegular, color: AppColors.bodyTextColor, fontSize: 16),
              ),
              const SizedBox(height: 16),
              longActionButton(
                text: "Save Video",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () {
                  if (videoLinkController.text.isNotEmpty) {
                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .addVideo(
                      videoLink: videoLinkController.text,
                      toolId: widget.tool.id,
                    );
                    context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteVideoDialog({ required BuildContext context, required Video video}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackgroundColor,
          title: reusableText(
            text: "Delete Video",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          content: reusableText(
            text: "Are you sure you want to delete this video?",
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              child: reusableText(text: "Cancel"),
              onPressed: () => context.pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningColor,
              ),
              child: reusableText(text: "Delete"),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );


    if (confirmed == true) {
      final profileId = context.read<AuthProvider>().profile!.id;
      Provider.of<AiDiaryProvider>(context, listen: false).deleteVideo(video: video);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.9,
      padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.01),
      child: Consumer<AiDiaryProvider>(
        builder: (context, aiDiaryProvider, _) {
          if (aiDiaryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (aiDiaryProvider.error != null) {
            return Center(
              child: Text(
                aiDiaryProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final videos = aiDiaryProvider.myVideos ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shortActionButton(
                      text: "+ Add Video",
                      size: size,
                      onPressed: () => _showAddVideoLinkModal(context, size),
                    ),
                  ],
                ),

                SizedBox(height: size.height*0.02,),

                if (videos.isEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      SizedBox(height: size.height*0.2),
                      Lottie.asset(emptyBox, width: size.width*0.6),
                    ]
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: videos.map((video) {return YoutubeVideoWidget(
                      video: video,
                      onCopy: () async {
                        await Clipboard.setData(ClipboardData(text: video.videoLink));
                        showToast('Youtube link copied to clipboard');
                      },
                      onDelete: () => _showDeleteVideoDialog(context: context, video: video),
                    );}).toList(),
                  )
              ],
            ),
          );
        }
      ),

    );
  }

}