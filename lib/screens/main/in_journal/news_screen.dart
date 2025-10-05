import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import '../../../models/community/news.dart';
import '../../../providers/ai_journal_provider.dart';
import '../../../system/constants.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchNewsList();
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

        final newsList = aiJournalProvider.newsList ?? [];

        if (newsList.isEmpty) {
          return Center(child: reusableText(text: "No latest items yet."));
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: NewsCard(news: news, size: size),
            );
          },
        );
      },
    );
  }
}


class NewsCard extends StatelessWidget {
  final News news;
  final Size size;

  const NewsCard({super.key, required this.news, required this.size});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      color: AppColors.secondaryBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview from Supabase bucket
          if (news.imageUrl != null && news.imageUrl!.isNotEmpty)
            SizedBox(
              height: size.height * 0.25,
              width: double.infinity,
              child: Image.network(
                news.imageUrl!,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Release time
                reusableText(
                  text: 'Release Date: ${DateFormat.yMMMMd().format(news.releaseTime.toLocal())}',
                  fontSize: 12,
                  color: AppColors.bodyTextColor.withAlpha(200),
                ),

                const SizedBox(height: 6),

                reusableText(
                  text: news.owner,
                  fontSize: 12,
                  color: AppColors.primaryAccentColor,
                  fontWeight: FontWeight.bold,
                ),

                const SizedBox(height: 8),

                // Title
                reusableText(
                  text: news.title,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),

                // Description
                reusableText(
                  text: news.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 12,
                ),

                const SizedBox(height: 12),

                // Action buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/view_news', extra: {'news': news}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryAccentColor,
                      foregroundColor: AppColors.bodyTextColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: reusableText(text: "Read More", fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
