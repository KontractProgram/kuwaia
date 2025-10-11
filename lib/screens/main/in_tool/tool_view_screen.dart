import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/widgets/buttons.dart';
import 'package:provider/provider.dart';
import '../../../models/tool.dart';
import '../../../system/constants.dart';
import '../../../widgets/texts.dart';
import 'log_details_screen.dart';
import 'my_notes_screen.dart';
import 'my_prompts_screen.dart';
import 'my_videos_screen.dart';
import 'official_use_case_screen.dart';


class ToolViewScreen extends StatefulWidget {
  final Tool tool;
  const ToolViewScreen({super.key, required this.tool});

  @override
  State<ToolViewScreen> createState() => _ToolViewScreenState();
}

class _ToolViewScreenState extends State<ToolViewScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool? isFavorite;

  final List<String> _labels = [
    'Prompts',
    'Notes',
    'Videos',
    'Use Case',
    'Log Details',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
    isFavorite = aiDiaryProvider.isToolAFavorite(widget.tool);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChipTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildChip(String label, int index) {
    final bool selected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onChipTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? AppColors.primaryAccentColor.withAlpha(53) : AppColors.bodyTextColor.withAlpha(53),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: reusableText(
          text: label,
          color: selected ? AppColors.primaryAccentColor : AppColors.bodyTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Pages: make sure these screens accept `tool` if needed
    final pages = <Widget>[
      MyPromptsScreen(tool: widget.tool),
      MyNotesScreen(tool: widget.tool),
      MyVideosScreen(tool: widget.tool),
      OfficialUseCaseScreen(tool: widget.tool), // shown for "Info"
      LogDetailsScreen(tool: widget.tool),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: reusableText(
          text: widget.tool.name,
          color: AppColors.headingTextColor,
          fontSize: 16,
          maxLines: 1,
          fontWeight: FontWeight.w700,
        ),

        actions: [
          isFavorite != null ? IconButton(
            onPressed: (){
              final aiDiaryProvider = Provider.of<AiDiaryProvider>(context, listen: false);
              setState(() {
                isFavorite = !isFavorite!;
                aiDiaryProvider.updateFavoriteStatus(toolId: widget.tool.id, isFavorite: isFavorite!);
              });
            },
            icon: isFavorite! ? FaIcon(FontAwesomeIcons.solidHeart, color: AppColors.dashaSignatureColor,) : FaIcon(FontAwesomeIcons.heart, color: AppColors.bodyTextColor,)
          ) : SizedBox.shrink(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Menu (Wrap of chips) right under AppBar
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(
                _labels.length,
                    (i) => _buildChip(_labels[i], i),
              ),
            ),

            // PageView that shows the selected screen
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                physics: const BouncingScrollPhysics(),
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
