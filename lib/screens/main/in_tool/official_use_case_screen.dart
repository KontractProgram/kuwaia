import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

import '../../../models/tool.dart';

class OfficialUseCaseScreen extends StatefulWidget {
  final Tool tool;
  const OfficialUseCaseScreen({super.key, required this.tool});

  @override
  State<OfficialUseCaseScreen> createState() => _OfficialUseCaseScreenState();
}

class _OfficialUseCaseScreenState extends State<OfficialUseCaseScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(child: reusableText(text: 'Use case'),),
    );
  }

}