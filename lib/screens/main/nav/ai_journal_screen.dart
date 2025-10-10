import 'package:flutter/material.dart';
import 'package:kuwaia/screens/main/in_journal/freelancers_screen.dart';
import 'package:kuwaia/screens/main/in_journal/latest_screen.dart';
import 'package:kuwaia/screens/main/in_journal/news_screen.dart';
import 'package:kuwaia/screens/main/in_journal/prompts_screen.dart';
import 'package:kuwaia/screens/main/in_journal/trending_screen.dart';
import 'package:kuwaia/widgets/texts.dart';
import '../../../system/constants.dart';

class AiJournalScreen extends StatefulWidget {
  const AiJournalScreen({super.key});

  @override
  State<AiJournalScreen> createState() => _AiJournalScreenState();
}

class _AiJournalScreenState extends State<AiJournalScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  final List<String> _labels = [
    'Trending',
    'Latest',
    'News',
    'Prompts',
    'Freelancers'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
    final pages = <Widget>[
      TrendingScreen(),
      LatestScreen(),
      NewsScreen(),
      PromptsScreen(),
      FreelancersScreen()
    ];

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: List.generate(
            _labels.length,
                (i) => _buildChip(_labels[i], i),
          ),
        ),

        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            physics: const BouncingScrollPhysics(),
            children: pages,
          ),
        ),
      ],
    );
  }
}