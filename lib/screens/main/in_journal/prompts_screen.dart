import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

class PromptsScreen extends StatefulWidget {
  const PromptsScreen({super.key});

  @override
  State<PromptsScreen> createState() => _PromptsScreenState();
}

class _PromptsScreenState extends State<PromptsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: reusableText(text: 'Prompts'),);
  }
}