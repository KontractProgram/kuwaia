import 'package:flutter/material.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/loading.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../models/group.dart';
import '../../../system/constants.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  int? _loadingToolId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchTrendingTools();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AiJournalProvider>(
      builder: (context, aiJournalProvider, _) {
        if (aiJournalProvider.isLoading) {
          return Column(children: List.generate(2, (_) => trendingToolsLoadingWidget(size: size)));
        }

        if (aiJournalProvider.error != null) {
          return Center(
            child: Text(
              aiJournalProvider.error!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final trendingTools = aiJournalProvider.trendingTools ?? [];
        
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height*0.02,),
              if(trendingTools.isEmpty)
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      SizedBox(height: size.height*0.05),
                      Lottie.asset(threeDotsLoading, width: size.width*0.6),
                      reusableText(text: 'Trending tools coming up soon...')
                    ]
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trendingTools.length,
                  itemBuilder: (context, index) {
                    final tool = trendingTools[index];
                    final group = groups.firstWhere((g) => g.id == tool.groupId);
                    final bool inDiary = Provider.of<AiDiaryProvider>(context, listen: false).isToolInDiary(tool);

                    return trendingToolsWidget(
                      context: context,
                      size: size,
                      tool: tool,
                      group: group,
                      inDiary: inDiary,
                      onAddPressed: () async {
                        setState(() => _loadingToolId = tool.id);

                        await context.read<AiDiaryProvider>().addToolToDiary(tool: tool);

                        setState(() => _loadingToolId = null);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}