import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      Provider.of<AiDiaryProvider>(context, listen: false).fetchVideos(toolId: widget.tool.id, profileId: profileId);
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
          height: size.height * 0.4, // 90% of screen height
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
                      profileId: profileId,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.9,

    );
  }

}