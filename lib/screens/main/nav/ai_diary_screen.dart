import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/group.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/loading.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../system/constants.dart';

class AiDiaryScreen extends StatefulWidget {
  const AiDiaryScreen({super.key});

  @override
  State<AiDiaryScreen> createState() => _AiDiaryScreenState();
}

class _AiDiaryScreenState extends State<AiDiaryScreen> {

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {Provider.of<AiDiaryProvider>(context, listen: false).fetchDiary();});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AiDiaryProvider>(
      builder: (context, diaryProvider, _) {
        if (diaryProvider.isLoading) {
          return Column(children: List.generate(3, (_) => toolCardLoadingWidget(size: size)));
        }

        if (diaryProvider.error != null) {
          return Center(
            child: reusableText(
              text: 'Error: ${diaryProvider.error}',
              color: AppColors.warningColor,
            ),
          );
        }

        if (diaryProvider.diary == null || diaryProvider.diary!.isEmpty) {
          return const Center(
            child: Text('No tools found in your AI Diary yet.'),
          );
        }

        final allTools = diaryProvider.diary ?? [];
        final filteredTools = allTools.where((tool) {
          final query = _searchQuery.toLowerCase();
          return tool.name.toLowerCase().contains(query) ||
              tool.visitLink.toLowerCase().contains(query);
        }).toList();

        final favoriteTools = filteredTools
            .where((tool) => diaryProvider.isToolAFavorite(tool))
            .toList();

        final nonFavoriteTools = filteredTools
            .where((tool) => !diaryProvider.isToolAFavorite(tool))
            .toList();

        print('number of filtered tools ${filteredTools.length}');

        return SingleChildScrollView(
          child: Column(
            children: [
              // 🔍 Search box
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search tools...',
                  prefixIcon: const Icon(Icons.search),
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (favoriteTools.isNotEmpty) ...[
                reusableText(
                  text: 'Favorites',
                  color: AppColors.secondaryAccentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoriteTools.length,
                  itemBuilder: (context, index) {
                    final tool = favoriteTools[index];
                    final group =
                    groups.firstWhere((g) => g.id == tool.groupId);

                    return toolCardWidget(
                      context: context,
                      tool: tool,
                      group: group,
                      inDiary: true,
                      onPressed: () =>
                          context.push('/tool_view', extra: {'tool': tool}),
                      onBookMarkPressed: () {
                        diaryProvider.deleteToolFromDiary(toolId: tool.id);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Divider(thickness: 1, color: AppColors.bodyTextColor.withAlpha(200),),
                const SizedBox(height: 12,)
              ],

              // 🛠 Tools List
              nonFavoriteTools.isEmpty
                ? Container(
                padding: EdgeInsets.only(top: size.height*0.2),
                child: Lottie.asset(emptyDiary, width: size.width*0.6),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nonFavoriteTools.length,
                  itemBuilder: (context, index) {
                    final tool = nonFavoriteTools[index];
                    final group = groups.firstWhere((g) => g.id == tool.groupId);

                    return toolCardWidget(
                      context: context,
                      tool: tool,
                      group: group,
                      inDiary: true,
                      onPressed: () => context.push('/tool_view', extra: {'tool': tool}),
                      onYoutubePressed: () {
                        if(tool.learningLink.isNotEmpty && tool.learningLink.startsWith('https://youtube.com')) {
                          context.push('/diary_tool_learning_video', extra: {'videoLink', tool.learningLink});
                        }
                      },
                      onBookMarkPressed: () {
                        diaryProvider.deleteToolFromDiary(toolId: tool.id);
                      }
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