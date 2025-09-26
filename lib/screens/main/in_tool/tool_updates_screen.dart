import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

import '../../../models/tool.dart';

class ToolUpdatesScreen extends StatefulWidget {
  final Tool tool;
  const ToolUpdatesScreen({super.key, required this.tool});

  @override
  State<ToolUpdatesScreen> createState() => _ToolUpdatesScreenState();
}

class _ToolUpdatesScreenState extends State<ToolUpdatesScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(child: reusableText(text: 'Updates page'),),
    );
  }
}