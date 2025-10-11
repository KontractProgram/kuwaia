import 'package:flutter/material.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/loading.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../system/constants.dart';

class PromptsScreen extends StatefulWidget {
  const PromptsScreen({super.key});

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchJournalPrompts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.9,
      padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.01),
      child: Consumer<AiJournalProvider>(
        builder: (context, aiJournalProvider, _) {
          if (aiJournalProvider.isLoading) {
            return journalPromptLoadingWidget();
          }

          if (aiJournalProvider.error != null) {
            return Center(
              child: Text(
                aiJournalProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final prompts = aiJournalProvider.journalPrompts ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                if (prompts.isEmpty)
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      [
                        SizedBox(height: size.height*0.2),
                        Lottie.asset(emptyBox, width: size.width*0.6),
                        reusableText(text: 'There are no community prompts yet')
                      ]
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: prompts.map((prompt) {
                      final isLiked = aiJournalProvider.userLikesPrompt(prompt.id);
                      final likes = aiJournalProvider.getLikes(prompt.id);

                      return journalPromptWidget(
                        prompt: prompt,
                        owner: aiJournalProvider.getOwnerByPromptId(prompt.id),
                        isLiked: isLiked,
                        likes: likes,
                        onLikePressed: () async {
                          if(isLiked) {
                            await aiJournalProvider.unlikePrompt(promptId: prompt.id);
                          } else {
                            await aiJournalProvider.likePrompt(promptId: prompt.id);
                          }
                        }
                      );
                    }).toList(),
                  )
              ],
            ),
          );
        }
      )
    );
  }
}
