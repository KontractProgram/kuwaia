import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: reusableText(text: 'Video'),);
  }
}