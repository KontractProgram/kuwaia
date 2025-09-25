
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/group.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tool.dart';
import '../system/constants.dart';

Widget toolCardWidget({
  required BuildContext context,
  required Tool tool,
  required Group group,
  required bool inDiary,
  required String logo,
  VoidCallback? onPressed,
  VoidCallback? onBookMarkPressed,
}){
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.secondaryBackgroundColor,
      boxShadow: [
        BoxShadow(
          color: AppColors.bodyTextColor.withAlpha(150),
          blurRadius: 5,
          spreadRadius: 2,
        ),
      ],
    ),
    padding: EdgeInsets.all(4),
    margin: EdgeInsets.only(top: 10, left: 7, right: 7),
    child: ListTile(
      onTap: onPressed,
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.secondaryBackgroundColor,
        child: logo.isEmpty ? reusableText(
            text: tool.id.toString(),
            fontSize: 16,
            fontWeight: FontWeight.bold
        ) : ClipOval(child: Image.asset(logo, width: 50, fit: BoxFit.cover,)),
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
                if (shouldDelete == true) onBookMarkPressed?.call();
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
                          child: reusableText(text: "Confirm", color: AppColors.secondaryBackgroundColor),
                        )
                      ],
                    );
                  }
                );
                if (addToDiary == true) onBookMarkPressed?.call();
              }

            },
          ),
          SizedBox(width: 10)
        ],
      ),
    ),
  );
}

Widget singleTrailCardWidget({
  required IconData leadingIcon,
  required String title,
  String? subtitle,
  VoidCallback? onPressed,
  }){
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.secondaryBackgroundColor,
    ),
    margin: EdgeInsets.only(top: 10),
    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        leading: FaIcon(
            leadingIcon,
            color: AppColors.primaryAccentColor,
            size: 20
        ),
        title: reusableText(
            text: title,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis
        ),
        subtitle: subtitle != null
          ? reusableText(text: subtitle ?? '', color: AppColors.bodyTextColor.withAlpha(129), fontSize: 12, textAlign: TextAlign.start)
          : null,
        trailing: FaIcon(FontAwesomeIcons.chevronRight, color: AppColors.bodyTextColor.withAlpha(150),),
        onTap: onPressed
    ),
  );
}

Widget savedPromptWidget({
  required String description,
  required String prompt,
  VoidCallback? onShare,
  VoidCallback? onCopy,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reusableText(
          text: description,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          textAlign: TextAlign.start
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.secondaryBackgroundColor,
          ),
          child: reusableText(
            text: prompt,
            textAlign: TextAlign.start,
            fontSize: 12,
            maxLines: 4
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => onShare,
              icon: FaIcon(FontAwesomeIcons.shareNodes, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onCopy,
                icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onEdit,
                icon: FaIcon(FontAwesomeIcons.penToSquare, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onDelete,
                icon: FaIcon(FontAwesomeIcons.trashCan, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),
          ],
        ),

        Divider(color: AppColors.bodyTextColor.withAlpha(53), thickness: 1,),
      ],
    ),
  );
}

Widget savedNoteWidget({
  required String note,
  VoidCallback? onShare,
  VoidCallback? onCopy,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.secondaryBackgroundColor,
          ),
          child: reusableText(
              text: note,
              textAlign: TextAlign.start,
              fontSize: 12,
              maxLines: 4
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: (){},
                icon: FaIcon(FontAwesomeIcons.shareNodes, size: 20, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: (){},
                icon: FaIcon(FontAwesomeIcons.copy, size: 20, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: (){},
                icon: FaIcon(FontAwesomeIcons.penToSquare, size: 20, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: (){},
                icon: FaIcon(FontAwesomeIcons.trashCan, size: 20, color: AppColors.bodyTextColor.withAlpha(150))
            ),
          ],
        ),

        SizedBox(height: 5),
        Divider(),
      ],
    ),
  );
}

