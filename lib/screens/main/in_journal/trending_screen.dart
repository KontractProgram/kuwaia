import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: reusableText(text: 'trending'),);
  }
}