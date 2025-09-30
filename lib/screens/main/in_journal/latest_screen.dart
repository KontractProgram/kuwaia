import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/community/latest.dart';
import '../../../models/tool.dart';
import '../../../providers/ai_diary_provider.dart';
import '../../../providers/ai_journal_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../system/constants.dart';

class LatestScreen extends StatefulWidget {
  const LatestScreen({super.key});

  @override
  State<LatestScreen> createState() => _LatestScreenState();
}

class _LatestScreenState extends State<LatestScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchLatestList();
    });
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AiJournalProvider>(
      builder: (context, aiJournalProvider, _) {
        if (aiJournalProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (aiJournalProvider.error != null) {
          return Center(
            child: Text(aiJournalProvider.error!,
                style: TextStyle(color: AppColors.warningColor)),
          );
        }

        final latestList = aiJournalProvider.latestList ?? [];

        if (latestList.isEmpty) {
          return Center(child: reusableText(text: "No latest items yet."));
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: latestList.length,
          itemBuilder: (context, index) {
            final latest = latestList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: _LatestCard(latest: latest, size: size),
            );
          },
        );
      },
    );
  }
}


class _LatestCard extends StatelessWidget {
  final Latest latest;
  final Size size;

  const _LatestCard({required this.latest, required this.size});

  @override
  Widget build(BuildContext context) {
    final inDiary = context.read<AiDiaryProvider>().isToolInDiaryById(latest.toolId!);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview from Supabase bucket
          if (latest.imageId != null && latest.imageId!.isNotEmpty)
            SizedBox(
              height: size.height * 0.25,
              width: double.infinity,
              child: Image.network(
                "${AppConstants.supabaseBucketUrl}/${latest.imageId!}",
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Release time
                reusableText(
                  text: latest.releaseTime.toLocal().toString(),
                  fontSize: 12,
                  color: AppColors.bodyTextColor.withAlpha(200),
                ),
                const SizedBox(height: 6),

                // Title
                reusableText(
                  text: latest.title,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                const SizedBox(height: 8),

                // Description
                reusableText(
                  text: latest.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 14,
                ),
                const SizedBox(height: 10),

                // Tags
                if (latest.tags != null && latest.tags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: latest.tags!
                        .map((tag) => Chip(
                      label: Text(tag,
                          style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.dashaSignatureColor.withAlpha(25),
                    ))
                        .toList(),
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>  launchUrl(Uri.parse(latest.visitLink)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryAccentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Visit Site"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: inDiary
                          ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.confirmColor.withOpacity(0.2),
                        ),
                        child: Center(
                          child: reusableText(
                            text: "In Diary",
                            color: AppColors.confirmColor,
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () async {
                          final profileId = context.read<AuthProvider>().profile!.id;
                          final Tool tool = context.read<AiJournalProvider>().fetchToolById(latest.toolId!) as Tool;
                          print('TOOL: ${tool.id}, name ${tool.name}');

                          await context.read<AiDiaryProvider>().addToolToDiary(profileId: profileId, tool: tool);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Add to Diary"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}