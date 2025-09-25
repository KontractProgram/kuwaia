import 'package:flutter/material.dart';
import 'package:kuwaia/screens/main/in_tool/tool_updates_screen.dart';
import 'package:kuwaia/widgets/buttons.dart';
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

  final List<String> _labels = [
    'Prompts',
    'Notes',
    'Videos',
    'Info',
    'Log Details',
    'Updates',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
      ToolUpdatesScreen(tool: widget.tool),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Menu (Wrap of chips) right under AppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.01),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: List.generate(
                  _labels.length,
                      (i) => _buildChip(_labels[i], i),
                ),
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
