import 'package:flutter/material.dart';
import 'package:kuwaia/widgets/texts.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: reusableText(text: 'News'),);
  }
}