import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kuwaia/providers/ai_diary_provider.dart';
import 'package:kuwaia/system/constants.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:provider/provider.dart';

import '../../../models/tool.dart';
import '../../../widgets/toast.dart';

class LogDetailsScreen extends StatefulWidget {
  final Tool tool;
  const LogDetailsScreen({super.key, required this.tool});

  @override
  State<LogDetailsScreen> createState() => _LogDetailsScreenState();
}

class _LogDetailsScreenState extends State<LogDetailsScreen> {
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

         final logDetails = aiDiaryProvider.logDetails;

         return Container(
           width: size.width*0.9,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(20),
             color: AppColors.secondaryBackgroundColor,
           ),
           padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                   reusableText(text: 'Email', fontWeight: FontWeight.w600, fontSize: 20),
                   SizedBox(width: 5),
                   Container(
                     width: size.width*0.5,
                     height: 40,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: AppColors.primaryBackgroundColor
                     ),
                     child: reusableText(text: logDetails != null ? logDetails.logEmail : '', fontSize: 14),
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
                   reusableText(text: 'Password Hint', fontWeight: FontWeight.w600, fontSize: 20),
                   SizedBox(width: 5),
                   Container(
                     width: size.width*0.5,
                     height: 40,
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         color: AppColors.primaryBackgroundColor
                     ),
                     child: reusableText(text: logDetails != null ? logDetails.logEmail : '', fontSize: 14),
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
             ],
           ),
         );
       }
     ),
   );
  }

}