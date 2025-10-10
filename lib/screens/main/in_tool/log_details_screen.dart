import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/in_tool/log_details.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';
import '../../../models/tool.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/toast.dart';

class LogDetailsScreen extends StatefulWidget {
  final Tool tool;
  const LogDetailsScreen({super.key, required this.tool});

  @override
  State<LogDetailsScreen> createState() => _LogDetailsScreenState();
}

class _LogDetailsScreenState extends State<LogDetailsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiDiaryProvider>(context, listen: false).fetchLogDetails(toolId: widget.tool.id);
    });
  }

  void _showSetLogDetailsModal({required BuildContext context, required Size size, LogDetails? logDetails}) {
    final emailController = TextEditingController(text: logDetails != null ? logDetails.logEmail : '');
    final passHintController = TextEditingController(text: logDetails != null ? logDetails.logPasswordHint : '');
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
                  text: "Log Details",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  maxLength: 64,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Email",
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
                  controller: passHintController,
                  maxLength: 64,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Password Hint",
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
                  text: "Set Log Details",
                  size: size,
                  buttonColor: AppColors.primaryAccentColor,
                  textColor: AppColors.bodyTextColor,
                  onPressed: () {
                    if (validateEmail(emailController.text) == null &&
                        passHintController.text.isNotEmpty) {

                      if(logDetails != null) {
                        //update
                        final newLogDetails = LogDetails(
                            id: logDetails.id,
                            logEmail: emailController.text,
                            logPasswordHint: passHintController.text,
                            toolId: logDetails.toolId
                        );

                        Provider.of<AiDiaryProvider>(context, listen: false).updateLogDetails(ld: newLogDetails,);
                      } else {
                        //create
                        Provider.of<AiDiaryProvider>(context, listen: false)
                            .addLogDetails(
                          email: emailController.text,
                          logPasswordHint: passHintController.text,
                          toolId: widget.tool.id,
                        );
                      }

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

  Future<void> _showDeleteLogDetailsDialog({ required BuildContext context, required LogDetails logDetails}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBackgroundColor,
          title: reusableText(
            text: "Clear the log details",
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          content: reusableText(
            text: "Are you sure you want to permanently delete these details?",
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
      Provider.of<AiDiaryProvider>(context, listen: false).deleteLogDetails(ld: logDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
   final size = MediaQuery.of(context).size;


   return Consumer<AiDiaryProvider>(
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

       final logDetails = aiDiaryProvider.logDetails;

       return Container(
         width: size.width*0.9,
         height: 200,
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(20),
           color: AppColors.secondaryBackgroundColor,
         ),
         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
         margin: EdgeInsets.symmetric(horizontal: size.width*0.05, vertical: size.height*0.2),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 reusableText(text: 'Email', fontWeight: FontWeight.w500),
                 SizedBox(width: 35),

                 GestureDetector(
                   onTap: () => _showSetLogDetailsModal(context: context, size: size, logDetails: logDetails),
                   child: Container(
                     width: size.width*0.5,
                     height: 40,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: AppColors.bodyTextColor.withAlpha(100)
                     ),
                     child: Center(child: reusableText(text: logDetails != null ? logDetails.logEmail : 'Enter email', fontSize: 12, maxLines: 1)),
                   ),
                 ),
                 if(logDetails != null)
                   IconButton(
                     onPressed: () async {
                       await Clipboard.setData(ClipboardData(text: logDetails.logEmail));
                       showToast('Email copied to clipboard');
                     },
                     icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
                   )
               ],
             ),

             SizedBox(height: 20),

             Row(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 reusableText(text: 'Pass Hint', fontWeight: FontWeight.w500),
                 SizedBox(width: 5),
                 Container(
                   width: size.width*0.5,
                   height: 40,
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: AppColors.bodyTextColor.withAlpha(100)
                   ),
                   child: Center(child: reusableText(text: logDetails != null ? logDetails.logPasswordHint : 'Enter Password Hint', fontSize: 12, maxLines: 1)),
                 ),
                 if(logDetails != null)
                   IconButton(
                       onPressed: () async {
                         await Clipboard.setData(ClipboardData(text: logDetails.logPasswordHint));
                         showToast('Password hint copied to clipboard');
                       },
                       icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
                   )
               ],
             ),

             SizedBox(height: 16),

             if(logDetails != null)
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   IconButton(
                       onPressed: () => _showDeleteLogDetailsDialog(context: context, logDetails: logDetails),
                       icon: FaIcon(FontAwesomeIcons.trashCan, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
                   ),
                 ],
               )
           ],
         ),
       );
     }
   );
  }

}