import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/screens/main/nav/ai_diary_screen.dart';
import 'package:kuwaia/screens/main/nav/ai_journal_screen.dart';
import 'package:kuwaia/screens/main/nav/profile_screen.dart';
import 'package:kuwaia/screens/main/nav/shorts_screen.dart';
import 'package:kuwaia/screens/main/nav/tools_screen.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/others.dart';
import 'package:kuwaia/widgets/texts.dart';

class LandingNavScreen extends StatefulWidget {
  const LandingNavScreen({super.key});

  @override
  State<LandingNavScreen> createState() => _LandingNavScreenState();
}

class _LandingNavScreenState extends State<LandingNavScreen> {

  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    AiDiaryScreen(),
    ToolsScreen(),
    AiJournalScreen(),
    ShortsScreen(),
    ProfileScreen()
  ];

  static final List<String> _appBarTitles = ['AI Diary', 'Tools', 'AI Journal', 'Shorts', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: _selectedIndex == 3 ? true : false,
      extendBody: _selectedIndex == 3 ? true : false,
      appBar: AppBar(
        backgroundColor: _selectedIndex == 3 ? Colors.transparent : AppColors.primaryBackgroundColor,
        title: Center(child: reusableText(
          text: _appBarTitles.elementAt(_selectedIndex),
          color: AppColors.headingTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w700
        ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(
            horizontal: _selectedIndex == 3 ? 0 : size.width*0.05,
            vertical: 0//_selectedIndex == 3 ? 0 : size.height*0.02
          ),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,//AppColors.primaryBackgroundColor,
        fixedColor: AppColors.bodyTextColor.withAlpha(150),
        currentIndex: _selectedIndex,
        onTap: (int index){setState(() {_selectedIndex = index;});},
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/kuwaia_icons/main/aidiaryicon.png",
              width: 25,
              fit: BoxFit.cover,
            ),
            activeIcon: Image.asset(
              "assets/kuwaia_icons/main/aidiaryicon.png",
              width: 30,
              fit: BoxFit.cover,
            ),
            label: 'AI diary'
          ),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/kuwaia_icons/main/aitoolsicon.png",
                width: 25,
                fit: BoxFit.cover,
              ),
              activeIcon: Image.asset(
                "assets/kuwaia_icons/main/aitoolsicon.png",
                width: 30,
                fit: BoxFit.cover,
              ),
              label: 'Tools'
          ),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/kuwaia_icons/main/aijournalicon.png",
                width: 25,
                fit: BoxFit.cover,
              ),
              activeIcon: Image.asset(
                "assets/kuwaia_icons/main/aijournalicon.png",
                width: 30,
                fit: BoxFit.cover,
              ),
              label: 'AI Journal'
          ),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/kuwaia_icons/main/shorts.png",
                width: 25,
                fit: BoxFit.cover,
              ),
              activeIcon: Image.asset(
                "assets/kuwaia_icons/main/shorts.png",
                width: 30,
                fit: BoxFit.cover,
              ),
            label: 'Updates'
          ),
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/kuwaia_icons/main/profileicon.png",
                width: 25,
                fit: BoxFit.cover,
              ),
              activeIcon: Image.asset(
                "assets/kuwaia_icons/main/profileicon.png",
                width: 30,
                fit: BoxFit.cover,
              ),
              label: 'Profile'
          ),
        ],
      ),
    );
  }
}
