import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:kuwaia/widgets/loading.dart';
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
          return Center(child: newsCardLoadingWidget(size: size));
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
            return _newsCard(context: context, news: news, size: size);
          },
        );
      },
    );
  }
}


Widget _newsCard({required BuildContext context, required News news, required Size size}) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 6,
    clipBehavior: Clip.hardEdge,
    color: AppColors.secondaryBackgroundColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                maxLines: 1
              ),

              const SizedBox(height: 8),

              // Title
              reusableText(
                text: news.title,
                fontWeight: FontWeight.bold,
                maxLines: 2,
                textAlign: TextAlign.start
              ),
              const SizedBox(height: 8),

              // Description
              reusableText(
                text: news.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                fontSize: 12,
                textAlign: TextAlign.start
              ),
              SizedBox(height: 8,),
              Center(
                child: shortActionButton(
                  text: 'Read More',
                  size: size,
                  buttonColor: Colors.transparent,
                  onPressed: () => context.push('/view_news', extra: {'news': news}),
                )
              ),
              SizedBox(height: 8,),

            ],
          ),
        ),
      ],
    ),
  );
}

