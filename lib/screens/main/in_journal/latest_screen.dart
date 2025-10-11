import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kuwaia/widgets/loading.dart';
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
          return Center(child: latestCardLoadingWidget(size: size),);
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _LatestCard(latest: latest, size: size),
            );
          },
        );
      },
    );
  }
}


class _LatestCard extends StatefulWidget {
  final Latest latest;
  final Size size;

  const _LatestCard({required this.latest, required this.size});

  @override
  State<_LatestCard> createState() => _LatestCardState();
}

class _LatestCardState extends State<_LatestCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final inDiary = context.watch<AiDiaryProvider>().isToolInDiaryById(widget.latest.toolId!);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: widget.size.width * 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      color: AppColors.secondaryBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image preview from Supabase bucket
          if (widget.latest.imageUrl != null && widget.latest.imageUrl!.isNotEmpty)
            SizedBox(
              height: widget.size.height * 0.25,
              width: double.infinity,
              child: Image.network(
                widget.latest.imageUrl!,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Release time
                reusableText(
                  text: 'Release Date: ${DateFormat.yMMMMd().format(widget.latest.releaseTime.toLocal())}',
                  fontSize: 12,
                  color: AppColors.bodyTextColor.withAlpha(200),
                ),

                const SizedBox(height: 6),

                // Title
                reusableText(
                  text: widget.latest.title,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  textAlign: TextAlign.start
                ),
                const SizedBox(height: 8),

                // Description
                reusableText(
                  text: widget.latest.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 12,
                  textAlign: TextAlign.start
                ),
                const SizedBox(height: 8),

                // Tags
                if (widget.latest.tags != null && widget.latest.tags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.latest.tags!
                        .map((tag) => Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.dashaSignatureColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: reusableText(text: tag, color: AppColors.dashaSignatureColor, fontSize: 12),
                    ))
                        .toList(),
                  ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final uri = Uri.parse(widget.latest.visitLink);

                          // Try to launch in default browser (external app)
                          if (await canLaunchUrl(uri)) {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );

                            // If launching in external app fails, fallback to normal
                            if (!launched) {
                              await launchUrl(uri, mode: LaunchMode.platformDefault);
                            }
                          } else {
                            // Fallback: open with normal behavior
                            await launchUrl(uri, mode: LaunchMode.platformDefault);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryAccentColor,
                          foregroundColor: AppColors.bodyTextColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: reusableText(text: "Visit Site", fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: inDiary
                          ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.confirmColor.withAlpha(52),
                        ),
                        child: Center(
                          child: reusableText(
                            text: "In Diary",
                            color: AppColors.confirmColor,
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          setState(() => _isLoading = true);

                          final aiJournalProvider = context.read<AiJournalProvider>();
                          final aiDiaryProvider = context.read<AiDiaryProvider>();

                          try {
                            Tool? tool = await aiJournalProvider.fetchToolById(widget.latest.toolId!);
                            await aiDiaryProvider.addToolToDiary(tool: tool!);
                          } catch (e) {
                            print("Error adding tool: $e");
                          } finally {
                            if (!mounted) return;
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccentColor,
                          foregroundColor: AppColors.bodyTextColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.bodyTextColor, strokeWidth: 2))
                            : reusableText(text: "Add to Diary", fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}