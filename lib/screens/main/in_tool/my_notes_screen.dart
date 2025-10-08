import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../models/in_tool/Note.dart';
import '../../../models/tool.dart';
import '../../../providers/auth_provider.dart';
import '../../../system/constants.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/custom.dart';
import '../../../widgets/texts.dart';
import '../../../widgets/toast.dart';

class MyNotesScreen extends StatefulWidget {
  final Tool tool;
  const MyNotesScreen({super.key, required this.tool});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiDiaryProvider>(context, listen: false).fetchNotes(toolId: widget.tool.id);
    });
  }

  void _showAddNoteModal(BuildContext context, Size size) {
    final noteController = TextEditingController();

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
                text: "Add New Note",
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                maxLength: 1000,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Note",
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
                text: "Save Note",
                size: size,
                buttonColor: AppColors.primaryAccentColor,
                textColor: AppColors.bodyTextColor,
                onPressed: () {
                  if (noteController.text.isNotEmpty) {
                    Provider.of<AiDiaryProvider>(context, listen: false)
                        .addNote(
                      note: noteController.text,
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

  void _showEditNoteModal({required BuildContext context, required Size size, required Note note}) {
    final noteController = TextEditingController(text: note.note);

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
                  text: "Edit Note",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: noteController,
                  maxLength: 1000,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Note",
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
                    if (noteController.text.isNotEmpty) {

                      final newNote = Note(
                          id: note.id,
                          note: noteController.text,
                          toolId: note.toolId
                      );

                      Provider.of<AiDiaryProvider>(context, listen: false)
                          .updateNote(
                        note: newNote,
                      );
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

  Future<void> _showDeleteNoteDialog({ required BuildContext context, required Note note}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackgroundColor,
          title: reusableText(
            text: "Delete Note",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          content: reusableText(
            text: "Are you sure you want to delete this note?",
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
      Provider.of<AiDiaryProvider>(context, listen: false).deleteNote(note: note);
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

          final notes = aiDiaryProvider.myNotes ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shortActionButton(
                      text: "+ Add Note",
                      size: size,
                      onPressed: () => _showAddNoteModal(context, size),
                    ),
                  ],
                ),
                SizedBox(height: size.height*0.02,),

                if (notes.isEmpty)
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
                    children: notes.map((note) {
                      return savedNoteWidget(
                        note: note.note,
                        size: size,
                        onCopy: () async {
                          await Clipboard.setData(ClipboardData(text: note.note));
                          showToast('Note copied to clipboard');
                        },
                        onEdit: () => _showEditNoteModal(context: context, size: size, note: note),
                        onDelete: () => _showDeleteNoteDialog(context: context, note: note)
                      );
                    }).toList(),
                  )
              ],
            )
          );
        },
      ),
    );
  }
}