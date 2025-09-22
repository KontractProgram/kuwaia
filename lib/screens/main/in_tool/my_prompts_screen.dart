import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../models/prompt.dart';
import '../../../models/tool.dart';
import '../../../system/constants.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/texts.dart';

class MyPromptsScreen extends StatefulWidget {
  final Tool tool;
  const MyPromptsScreen({super.key, required this.tool});

  @override
  State<MyPromptsScreen> createState() => _MyPromptsScreenState();
}

class _MyPromptsScreenState extends State<MyPromptsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileId = context.read<AuthProvider>().profile!.id;
      Provider.of<AiDiaryProvider>(context, listen: false).fetchPrompts(toolId: widget.tool.id, profileId: profileId);
    });
  }

  void _showAddPromptModal(BuildContext context) {
    final descriptionController = TextEditingController();
    final promptController = TextEditingController();
    final profileId = context.read<AuthProvider>().profile!.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              reusableText(
                text: "Add New Prompt",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLength: 150,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: promptController,
                maxLength: 1000,
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Prompt"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (descriptionController.text.isNotEmpty &&
                      promptController.text.isNotEmpty) {
                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .addPrompt(
                      description: descriptionController.text,
                      prompt: promptController.text,
                      toolId: widget.tool.id,
                      profileId: profileId,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save Prompt"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: leadingButton(context),
        title: reusableText(
            text: 'My Saved Prompts',
            color: AppColors.headingTextColor,
            fontSize: 16,
            maxLines: 1,
            fontWeight: FontWeight.w700
        ),
      ),

      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.02),
          child: Consumer<AiDiaryProvider>(
            builder: (context, aiDiaryProvider, _) {
              if (aiDiaryProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (aiDiaryProvider.error != null) {
                return Center(
                  child: Text(
                    aiDiaryProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final prompts = aiDiaryProvider.myPrompts ?? [];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        shortActionButton(
                          text: "+ Add Prompt",
                          size: size,
                          onPressed: () => _showAddPromptModal(context),
                        ),

                        SizedBox(height: size.height*0.02,),

                        // list of prompts in saved prompt widgets

                        if (prompts.isEmpty)
                          Center(
                            child: Lottie.asset(emptyBox, width: size.width*0.6,
                            ),
                          )
                        else
                          Column(
                            children: prompts.map((prompt) {
                              return savedPromptWidget(
                                description: prompt.description,
                                prompt: prompt.prompt,
                              );
                            }).toList(),
                          )
                      ],
                    )
                  ],
                ),
              );
            }
          )
        ),
      ),
    );
  }

}
