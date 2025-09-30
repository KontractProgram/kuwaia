import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

class LatestScreen extends StatefulWidget {
  const LatestScreen({super.key});

  @override
  State<LatestScreen> createState() => _LatestScreenState();
}

class _LatestScreenState extends State<LatestScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: reusableText(text: 'latest'),);
  }
}