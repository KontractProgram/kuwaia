import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/group.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
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
          return Center(child: CircularProgressIndicator(color: AppColors.dashaSignatureColor,));
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

              const SizedBox(height: 10),

              // 🛠 Tools List
              filteredTools.isEmpty
                ? Container(
                padding: EdgeInsets.only(top: size.height*0.2),
                child: Lottie.asset(emptyDiary, width: size.width*0.6),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTools.length,
                  itemBuilder: (context, index) {
                    final tool = filteredTools[index];
                    final logo = 'assets/tool_logos/1.png';
                    final group = groups.firstWhere((g) => g.id == tool.groupId);

                    return toolCardWidget(
                      context: context,
                      tool: tool,
                      group: group,
                      logo: logo,
                      inDiary: true,
                      onPressed: () => context.push('/tool_view', extra: {'tool': tool}),
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