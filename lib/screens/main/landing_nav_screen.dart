import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/screens/main/nav/ai_diary_screen.dart';
import 'package:kuwaia/screens/main/nav/profile_screen.dart';
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
    Text('AI Journal'),
    Text('Settings'),
    ProfileScreen()
  ];

  static final List<String> _appBarTitles = [
    'AI Diary',
    'Tools',
    'AI Journal',
    'Settings',
    'Profile'
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
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
          padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.02),
          child: SingleChildScrollView(child: _widgetOptions.elementAt(_selectedIndex)),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryBackgroundColor,
        fixedColor: AppColors.bodyTextColor.withAlpha(150),
        currentIndex: _selectedIndex,
        onTap: (int index){setState(() {_selectedIndex = index;});},
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: glowingIcon(
              icon: FontAwesomeIcons.bookOpenReader,
              isActive: false,
            ),
            activeIcon: glowingIcon(
              icon: FontAwesomeIcons.bookOpenReader,
              isActive: true,
            ),
            label: 'AI diary'
          ),
          BottomNavigationBarItem(
              icon: glowingIcon(
                icon: FontAwesomeIcons.wrench,
                isActive: false,
              ),
              activeIcon: glowingIcon(
                icon: FontAwesomeIcons.wrench,
                isActive: true,
              ),
              label: 'Tools'
          ),
          BottomNavigationBarItem(
              icon: glowingIcon(
                icon: FontAwesomeIcons.globe,
                isActive: false,
              ),
              activeIcon: glowingIcon(
                icon: FontAwesomeIcons.globe,
                isActive: true,
              ),
              label: 'AI Journal'
          ),
          BottomNavigationBarItem(
              icon: glowingIcon(
                icon: FontAwesomeIcons.gear,
                isActive: false,
              ),
              activeIcon: glowingIcon(
                icon: FontAwesomeIcons.gear,
                isActive: true,
              ),
              label: 'Settings'
          ),
          BottomNavigationBarItem(
              icon: glowingIcon(
                icon: FontAwesomeIcons.user,
                isActive: false,
              ),
              activeIcon: glowingIcon(
                icon: FontAwesomeIcons.user,
                isActive: true,
              ),
              label: 'Profile'
          ),
        ],
      ),
    );
  }
}
