import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/providers/auth_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../models/in_tool/prompt.dart';
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

  void _showAddPromptModal({required BuildContext context, required Size size}) {
    final descriptionController = TextEditingController();
    final promptController = TextEditingController();
    final profileId = context.read<AuthProvider>().profile!.id;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: size.height * 0.9, // 90% of screen height
          decoration: BoxDecoration(
            color: AppColors.primaryBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.bodyTextColor.withAlpha(150), width: 2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.secondaryAccentColor, width: 2)
                  ),
                ),
                style: TextStyle(fontFamily: montserratRegular, color: AppColors.bodyTextColor, fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: promptController,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Prompt",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.bodyTextColor.withAlpha(150), width: 2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.secondaryAccentColor, width: 2)
                  ),
                ),
                style: TextStyle(fontFamily: montserratRegular, color: AppColors.bodyTextColor, fontSize: 16),
              ),
              const SizedBox(height: 16),
              longActionButton(
                text: "Save Prompt",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
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
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditPromptModal({required BuildContext context, required Size size, required Prompt prompt}) {
    final descriptionController = TextEditingController(text: prompt.description);
    final promptController = TextEditingController(text: prompt.prompt);
    final profileId = context.read<AuthProvider>().profile!.id;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: size.height * 0.9,
          decoration: BoxDecoration(
            color: AppColors.primaryBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                text: "Edit Prompt",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.bodyTextColor.withAlpha(150), width: 2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.secondaryAccentColor, width: 2)
                  ),
                ),
                style: TextStyle(fontFamily: montserratRegular, color: AppColors.bodyTextColor, fontSize: 16),
              ),
              SizedBox(height: 20),
              TextField(
                controller: promptController,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Prompt",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.bodyTextColor.withAlpha(150), width: 2)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: AppColors.secondaryAccentColor, width: 2)
                  ),
                ),
                style: TextStyle(fontFamily: montserratRegular, color: AppColors.bodyTextColor, fontSize: 16),
              ),
              const SizedBox(height: 16),

              longActionButton(
                text: "Save Changes",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () {
                  if (descriptionController.text.isNotEmpty &&
                      promptController.text.isNotEmpty) {

                    final newPrompt = Prompt(
                        id: prompt.id,
                        description: descriptionController.text,
                        prompt: promptController.text,
                        toolId: prompt.toolId
                    );

                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .updatePrompt(
                      prompt: newPrompt,
                      profileId: profileId,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _showDeletePromptDialog({ required BuildContext context, required Prompt prompt}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackgroundColor,
          title: reusableText(
            text: "Delete Prompt",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          content: reusableText(
            text: "Are you sure you want to delete prompt\"${prompt.description}\"?",
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              child: reusableText(text: "Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningColor,
              ),
              child: reusableText(text: "Delete"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final profileId = context.read<AuthProvider>().profile!.id;
      Provider.of<AiDiaryProvider>(context, listen: false).deletePrompt(prompt: prompt, profileId: profileId);
    }

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
        width: size.width*0.9,
        padding: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.01),
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
                        onPressed: () => _showAddPromptModal(context: context, size: size),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height*0.02,),

                  if (prompts.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                      [
                        SizedBox(height: size.height*0.2),
                        Lottie.asset(emptyBox, width: size.width*0.6),
                      ]
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: prompts.map((prompt) {
                        return savedPromptWidget(
                          description: prompt.description,
                          prompt: prompt.prompt,
                          onShare: () {},
                          onCopy: () async {
                            print('11111');
                            await Clipboard.setData(ClipboardData(text: prompt.prompt));
                            print('22222');
                            showToast('Prompt copied to clipboard');
                          },
                          onEdit: () => _showEditPromptModal(context: context, size: size, prompt: prompt),
                          onDelete: () => _showDeletePromptDialog(context: context, prompt: prompt)
                        );
                      }).toList(),
                    )
                ],
              ),
            );
          }
        )
      );
  }
}
