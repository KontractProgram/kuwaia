import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/Group.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);

      aiDiaryProvider.fetchDiary(authProvider.profile!.id);

    });
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

        return Column(
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
                  final logo = '';
                  final group = groups.firstWhere((g) => g.id == tool.groupId);

                  return toolCardWidget(
                    context: context,
                    tool: tool,
                    group: group,
                    logo: logo,
                    inDiary: true,
                    onBookMarkPressed: () {
                      final auth = context.read<AuthProvider>();
                      diaryProvider.deleteToolFromDiary(profileId: auth.profile!.id, toolId: tool.id);
                    }
                  );

                  // return Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(15),
                  //     color: AppColors.secondaryBackgroundColor,
                  //   ),
                  //   padding: EdgeInsets.all(8),
                  //   margin: EdgeInsets.only(top: 15),
                  //   child: ListTile(
                  //     contentPadding: const EdgeInsets.all(0),
                  //     leading: CircleAvatar(
                  //       radius: 25,
                  //       backgroundColor: AppColors.secondaryAccentColor,
                  //       child: logo.isEmpty ? reusableText(
                  //           text: tool.id.toString(),
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.bold
                  //       ) : Image.asset(logo, width: 50, fit: BoxFit.cover,),
                  //     ),
                  //
                  //     title: Row(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       mainAxisAlignment: MainAxisAlignment.start,
                  //       children: [
                  //         Flexible(
                  //           child: reusableText(
                  //             text: tool.name,
                  //             fontWeight: FontWeight.w600,
                  //             textAlign: TextAlign.start,
                  //             maxLines: 2,
                  //             overflow: TextOverflow.ellipsis, // optional
                  //           ),
                  //         ),
                  //         const SizedBox(width: 5),
                  //         GestureDetector(
                  //           onTap: () => launchUrl(Uri.parse(tool.visitLink)),
                  //           child: FaIcon(
                  //             FontAwesomeIcons.arrowUpRightFromSquare,
                  //             color: AppColors.bodyTextColor,
                  //             size: 16,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //
                  //
                  //     subtitle: reusableText(
                  //         text: '${group.name} Tools',
                  //         fontSize: 14,
                  //         color: AppColors.bodyTextColor.withAlpha(128),
                  //         textAlign: TextAlign.start
                  //     ),
                  //
                  //     trailing: Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //
                  //         GestureDetector(
                  //             onTap: () {},
                  //             child: Image.asset(youtubeLogo, width: 30, fit: BoxFit.cover,),
                  //         ),
                  //
                  //         SizedBox(width: 20,),
                  //
                  //         GestureDetector(
                  //           child: FaIcon(FontAwesomeIcons.solidBookmark, size: 20, color: AppColors.primaryAccentColor),
                  //           onTap: () async {
                  //             final shouldDelete = await showDialog<bool>(
                  //               context: context,
                  //               builder: (context) {
                  //                 return AlertDialog(
                  //                   backgroundColor: AppColors.secondaryBackgroundColor,
                  //                   title: reusableText(text: "Remove Tool", fontWeight: FontWeight.w600, fontSize: 20),
                  //                   content: reusableText(text: "Are you sure you want to remove ${tool.name} from your diary?", textAlign: TextAlign.start),
                  //                   actions: [
                  //                     TextButton(
                  //                       child: reusableText(text: "Cancel"),
                  //                       onPressed: () => context.pop(false),
                  //                     ),
                  //                     ElevatedButton(
                  //                       style: ElevatedButton.styleFrom(
                  //                         backgroundColor: AppColors.warningColor,
                  //                       ),
                  //                       child: reusableText(text: "Remove"),
                  //                       onPressed: () => context.pop(true),
                  //                     ),
                  //                   ],
                  //                 );
                  //               },
                  //             );
                  //
                  //             if (shouldDelete == true) {
                  //               final auth = context.read<AuthProvider>();
                  //               diaryProvider.deleteToolFromDiary(
                  //                 profileId: auth.profile!.id,
                  //                 toolId: tool.id,
                  //               );
                  //             }
                  //           },
                  //         ),
                  //         SizedBox(width: 10,)
                  //       ],
                  //     ),
                  //   ),
                  // );
                },
              ),
          ],
        );
      },
    );
  }

}