import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JournalVideoGroup {
  final int id;
  final String title;
  final String description;
  final IconData icon;

  JournalVideoGroup({
    required this.id,
    required this.title,
    required this.description,
    required this.icon
  });
}

final List<JournalVideoGroup> journalVideoGroups = [
  JournalVideoGroup(id: 1, title: 'AI News & Discussion', description: 'Stay updated with the latest breakthroughs and expert discussions in the AI space.', icon: FontAwesomeIcons.robot),
  JournalVideoGroup(id: 2, title: 'Creative AI Tutorials', description: 'Learn to create stunning visuals and videos with step-by-step guides for popular creative tools.', icon: FontAwesomeIcons.brush),
  JournalVideoGroup(id: 3, title: 'Build with AI', description: 'Boost your development skills by learning how to use AI as your coding and building companion.', icon: FontAwesomeIcons.code),
  JournalVideoGroup(id: 4, title: 'Make Money with AI', description: 'Discover practical ways to leverage AI for business, content creation, and new revenue streams.', icon: FontAwesomeIcons.coins),
  JournalVideoGroup(id: 5, title: 'AI Education', description: "Foundation-level courses and explainers from the world's leading AI educators.", icon: FontAwesomeIcons.graduationCap),
  JournalVideoGroup(id: 6, title: 'AI Podcast', description: 'Listen to in-depth conversations with the researchers and entrepreneurs building the future of AI.', icon: FontAwesomeIcons.podcast),
];