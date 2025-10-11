import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
      Provider.of<AiDiaryProvider>(context, listen: false).fetchPrompts(toolId: widget.tool.id);
    });
  }

  void _showCreatePromptModal({required BuildContext context, required Size size}) {
    final descriptionController = TextEditingController();
    final promptController = TextEditingController();

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
                        .createPrompt(
                      description: descriptionController.text,
                      prompt: promptController.text,
                      toolId: widget.tool.id,
                    );
                    context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareToFriendModal({required BuildContext context, required Size size, required int promptId}) {
    final controller = TextEditingController();

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
                text: "Share To A Friend",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLength: 150,
                decoration: InputDecoration(
                  labelText: "Username",
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
                text: "Share",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () {
                  if (controller.text.isNotEmpty && validateUsername(controller.text) == null) {
                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .sharePromptToAFriend(senderId: 'senderid', receiverId: 'receiverid', promptId: promptId);
                    context.pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSharePromptModal({required BuildContext context, required Size size, required AiDiaryProvider aiDiaryProvider, required Prompt prompt}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
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
                text: "Share Prompt",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              longActionButton(
                text: "To a Friend",
                size: size,
                buttonColor: AppColors.secondaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () async {
                  context.pop();
                  _showShareToFriendModal(context: context, size: size, promptId: prompt.id);
                },
              ),
              const SizedBox(height: 8),
              longActionButton(
                text: "To Journal",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () async {
                  context.pop();
                  final promptInJournal = await aiDiaryProvider.sharePromptToJournal(prompt: prompt);
                  showToast(promptInJournal ? 'Your prompt has been made public' : 'Something went wrong try again later');
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
                      toolId: prompt.toolId,
                      ownerId: prompt.ownerId,
                      inJournal: prompt.inJournal ?? false
                    );

                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .updatePrompt(prompt: newPrompt);
                    context.pop();
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
              onPressed: () => context.pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningColor,
              ),
              child: reusableText(text: "Delete"),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final profileId = context.read<AuthProvider>().profile!.id;
      Provider.of<AiDiaryProvider>(context, listen: false).deletePrompt(prompt: prompt);
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
                        onPressed: () => _showCreatePromptModal(context: context, size: size),
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
                          onShare: () => _showSharePromptModal(context: context, size: size, aiDiaryProvider: aiDiaryProvider, prompt: prompt),
                          onCopy: () async {
                            await Clipboard.setData(ClipboardData(text: prompt.prompt));
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
