import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/Group.dart';
import 'package:kuwaia/models/tools.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../system/constants.dart';

Widget toolCardWidget({
  required BuildContext context,
  required Tools tool,
  required Group group,
  required bool inDiary,
  required String logo,
  VoidCallback? onBookMarkPressed,
}){
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: AppColors.secondaryBackgroundColor,
    ),
    padding: EdgeInsets.all(8),
    margin: EdgeInsets.only(top: 15),
    child: ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.secondaryAccentColor,
        child: logo.isEmpty ? reusableText(
            text: tool.id.toString(),
            fontSize: 16,
            fontWeight: FontWeight.bold
        ) : Image.asset(logo, width: 50, fit: BoxFit.cover,),
      ),

      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: reusableText(
              text: tool.name,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // optional
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse(tool.visitLink)),
            child: FaIcon(
              FontAwesomeIcons.arrowUpRightFromSquare,
              color: AppColors.bodyTextColor,
              size: 16,
            ),
          ),
        ],
      ),


      subtitle: reusableText(
          text: '${group.name} Tools',
          fontSize: 14,
          color: AppColors.bodyTextColor.withAlpha(128),
          textAlign: TextAlign.start
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          GestureDetector(
            onTap: () {},
            child: Image.asset(youtubeLogo, width: 30, fit: BoxFit.cover,),
          ),

          SizedBox(width: 20,),

          GestureDetector(
            child: FaIcon(
                inDiary ? FontAwesomeIcons.solidBookmark : FontAwesomeIcons.bookmark,
                size: 20,
                color: AppColors.primaryAccentColor
            ),
            onTap: () async {
              if(inDiary) {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.secondaryBackgroundColor,
                      title: reusableText(text: "Remove Tool", fontWeight: FontWeight.w600, fontSize: 20),
                      content: reusableText(text: "Are you sure you want to remove ${tool.name} from your diary?", textAlign: TextAlign.start),
                      actions: [
                        TextButton(
                          child: reusableText(text: "Cancel"),
                          onPressed: () => context.pop(false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warningColor,
                          ),
                          child: reusableText(text: "Remove"),
                          onPressed: () => context.pop(true),
                        ),
                      ],
                    );
                  },
                );
                if (shouldDelete == true) onBookMarkPressed;
              } else {
                final addToDiary = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: AppColors.secondaryBackgroundColor,
                      title: reusableText(text: 'Add to Diary', fontWeight: FontWeight.w600, fontSize: 20),
                      content: reusableText(text: "Add ${tool.name} to your diary", textAlign: TextAlign.start),
                      actions: [
                        TextButton(
                          child: reusableText(text: "Cancel"),
                          onPressed: () => context.pop(false)
                        ),
                        ElevatedButton(
                          onPressed: () => context.pop(true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.confirmColor),
                          child: reusableText(text: "Confirm"),
                        )
                      ],
                    );
                  }
                );
                if (addToDiary == true) onBookMarkPressed;
              }

            },
          ),
          SizedBox(width: 10)
        ],
      ),
    ),
  );
}