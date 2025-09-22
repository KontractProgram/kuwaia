import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../models/Group.dart';
import '../../../models/tool.dart';
import '../../../providers/tools_provider.dart';
import '../../../system/constants.dart';


class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ToolsProvider>(context, listen: false).fetchTools();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<ToolsProvider>(
      builder: (context, toolsProvider, _) {
        if (toolsProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: AppColors.dashaSignatureColor));
        }

        if (toolsProvider.error != null) {
          return Center(
            child: reusableText(
              text: 'Error: ${toolsProvider.error}',
              color: AppColors.warningColor,
            ),
          );
        }

        if (toolsProvider.allTools == null || toolsProvider.allTools!.isEmpty) {
          return const Center(
            child: Text('No tools found in the database for now.'),
          );
        }

        final allTools = toolsProvider.allTools ?? [];
        // Get the filtered groups based on the search query
        final filteredGroups = groups.where((group) {
          final query = _searchQuery.toLowerCase();

          // 1️⃣ Does the group itself match?
          final matchesGroup = group.name.toLowerCase().contains(query) ||
              group.description.toLowerCase().contains(query);

          // 2️⃣ Do any tools inside this group match?
          final matchesTool = allTools.any((tool) =>
          tool.groupId == group.id &&
              (tool.name.toLowerCase().contains(query) ||
                  tool.visitLink.toLowerCase().contains(query))
          );

          return matchesGroup || matchesTool;
        }).toList();



        return Column(
          children: [
            // 🔍 Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search categories or tools...',
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
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            const SizedBox(height: 10),

            // 🛠 Tools list
            filteredGroups.isEmpty
            ? Container(
              padding: EdgeInsets.only(top: size.height*0.2),
              child: Lottie.asset(emptyDiary, width: size.width*0.6),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];

                return singleTrailCardWidget(
                  leadingIcon: group.icon,
                  title: '${group.name} Tools',
                  subtitle: group.description,
                  onPressed: () {
                    final List<Tool> toolsInGroup = toolsProvider.getToolsByGroup(group.id);
                    context.push(
                        '/tools_in_group',
                        extra: {
                        'group': group,
                        'tools': toolsInGroup
                        },
                    );
                  }
                );
              },
            ),
          ],
        );
      },
    );
  }
}
