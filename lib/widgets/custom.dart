import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kuwaia/models/community/freelancer.dart';
import 'package:kuwaia/models/group.dart';
import 'package:kuwaia/models/in_tool/prompt.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tool.dart';
import '../system/constants.dart';
import 'buttons.dart';

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

/// AI DIARY WIDGET
Widget toolCardWidget({
  required BuildContext context,
  required Tool tool,
  required Group group,
  required bool inDiary,
  VoidCallback? onPressed,
  VoidCallback? onYoutubePressed,
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
        child: ClipOval(
            child: tool.imageUrl != null && tool.imageUrl!.isNotEmpty
                ? Image.network(tool.imageUrl!, width: 40, fit: BoxFit.cover,)
                : Image.asset(aiLogo, width: 40, fit: BoxFit.cover,)
        ),
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
            onTap: () async {
              final uri = Uri.parse(tool.visitLink);

              // Try to launch in default browser (external app)
              if (await canLaunchUrl(uri)) {
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );

                // If launching in external app fails, fallback to normal
                if (!launched) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                }
              } else {
                // Fallback: open with normal behavior
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              }
            },
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
            onTap: onYoutubePressed,
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
                onPressed: () => onShare?.call(),
                icon: FaIcon(FontAwesomeIcons.shareNodes, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onCopy?.call(),
                icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onEdit?.call(),
                icon: FaIcon(FontAwesomeIcons.penToSquare, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onDelete?.call(),
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
  required Size size,
  VoidCallback? onShare,
  VoidCallback? onCopy,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size.width*0.9,
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                onPressed: () => onShare?.call(),
                icon: FaIcon(FontAwesomeIcons.shareNodes, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onCopy?.call(),
                icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onEdit?.call(),
                icon: FaIcon(FontAwesomeIcons.penToSquare, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onDelete?.call(),
                icon: FaIcon(FontAwesomeIcons.trashCan, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),
          ],
        ),

        Divider(),
      ],
    ),
  );
}

///AI TOOL WIDGETS



///AI JOURNAL WIDGETS
Widget trendingToolsWidget({
  required BuildContext context,
  required Size size,
  required Tool tool,
  required Group group,
  required bool inDiary,
  int? loadingToolId,
  VoidCallback? onAddPressed,
}) {
  return Container(
    width: size.width * 0.9,
    padding: const EdgeInsets.all(4),
    margin: const EdgeInsets.only(top: 10, left: 7, right: 7),
    decoration: BoxDecoration(
      color: AppColors.secondaryBackgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: ListTile(
      title: reusableText(
        text: tool.name,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: reusableText(
        text: '${group.name} Tools',
        fontSize: 14,
        color: AppColors.bodyTextColor.withAlpha(128),
        textAlign: TextAlign.start,
      ),
      trailing: inDiary
          ? Container(
        width: size.width * 0.33,
        height: size.height * 0.06,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.confirmColor.withAlpha(50),
        ),
        child: Center(
          child: reusableText(
            text: 'In Diary',
            color: AppColors.confirmColor,
          ),
        ),
      )
          : (loadingToolId == tool.id
          ? shortLoadingButton(size: size)
          : shortActionButton(
        text: 'Add to Diary',
        size: size,
        onPressed: onAddPressed,
      )),
    ),
  );
}


Widget freelancerCard({
  required BuildContext context,
  required Size size,
  required Freelancer freelancer,
  VoidCallback? onPressed
}){
  return Container(
    width: size.width*0.9,
    padding: EdgeInsets.all(4),
    margin: EdgeInsets.only(top: 10, left: 7, right: 7),
    decoration: BoxDecoration(
      color: AppColors.secondaryBackgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: ListTile(
      onTap: onPressed,
      contentPadding: const EdgeInsets.all(0),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.secondaryBackgroundColor,
        child: ClipOval(child: Image.network(freelancer.imageUrl, fit: BoxFit.cover,)),
      ),

      title: reusableText(
        text: freelancer.name,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis, // optional
      ),

      subtitle: reusableText(
        text: freelancer.skill,
        fontSize: 14,
        color: AppColors.bodyTextColor.withAlpha(200),
        textAlign: TextAlign.start,
        maxLines: 2
      ),

      trailing: SizedBox(
        width: 50,
        height: 50,
        child: Column(
          children: [
            reusableText(text: 'Rating', color: AppColors.bodyTextColor.withAlpha(120), fontSize: 12),
            reusableText(text: '${freelancer.rating.toString()}/5')
          ],
        ),
      ),
    )
  );
}


Widget journalPromptWidget({
  required Prompt prompt,
  required String owner,
  required int likes,
  required bool isLiked,
  VoidCallback? onLikePressed,
  VoidCallback? onImport,
  VoidCallback? onCopy,
}) {
  return Container(
    margin: EdgeInsets.only(top: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reusableText(
          text: owner,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          textAlign: TextAlign.start,
          fontSize: 12,
          color: AppColors.primaryAccentColor
        ),

        reusableText(
            text: prompt.description,
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
              text: prompt.prompt,
              textAlign: TextAlign.start,
              fontSize: 12,
              maxLines: 4
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () => onImport?.call(),
                icon: FaIcon(FontAwesomeIcons.download, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onCopy?.call(),
                icon: FaIcon(FontAwesomeIcons.copy, size: 16, color: AppColors.bodyTextColor.withAlpha(150))
            ),

            IconButton(
                onPressed: () => onLikePressed?.call(),
                icon: isLiked
                    ? FaIcon(FontAwesomeIcons.solidHeart, size: 16, color: AppColors.dashaSignatureColor)
                    : FaIcon(FontAwesomeIcons.heart, size: 16, color: AppColors.bodyTextColor.withAlpha(150)),

            ),

            reusableText(text: likes.toString(), fontSize: 12, color: AppColors.bodyTextColor.withAlpha(150))
          ],
        ),

        Divider(color: AppColors.bodyTextColor.withAlpha(53), thickness: 1,),
      ],
    ),
  );
}

class WeightedImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const WeightedImageCarousel({
    super.key,
    required this.images,
    this.height = 250, // Default height of 250
  });

  @override
  State<WeightedImageCarousel> createState() => _WeightedImageCarouselState();
}

class _WeightedImageCarouselState extends State<WeightedImageCarousel> {
  late final PageController _pageController;

  // Constants for the weighted carousel
  static const double _viewportFraction = 0.85;
  static const double _scaleFactor = 0.9;

  @override
  void initState() {
    super.initState();
    // Controller and constants now live here, making the widget self-contained.
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;

              if (_pageController.hasClients && _pageController.position.hasContentDimensions) {
                try {
                  // Calculate the distance of the current page from the center
                  value = (_pageController.page! - index);
                } catch (e) {
                  // Fallback for initial build
                  value = 0.0;
                }
              } else {
                value = 0.0;
              }

              // Apply the custom scaling logic
              value = (1 - (value.abs() * _scaleFactor)).clamp(0.0, 1.0);
              final double finalScale = 0.85 + (value * 0.15); // Scales from 0.85 to 1.0

              return Center(
                child: Transform.scale(
                  scale: finalScale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(52),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: widget.height,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: widget.height,
                            color: Colors.transparent,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: widget.height,
                            color: Colors.red.shade100,
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.red)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PromotionCarousel extends StatefulWidget {
  final List<Freelancer> promotions;
  final Size size;
  final void Function(Freelancer) onTap;

  const PromotionCarousel({
    super.key,
    required this.promotions,
    required this.size,
    required this.onTap,
  });

  @override
  State<PromotionCarousel> createState() => _PromotionCarouselState();
}

class _PromotionCarouselState extends State<PromotionCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  late final Timer _timer;
  static const double _viewportFraction = 0.8;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (widget.promotions.isEmpty) return;
      int nextPage = (_currentIndex + 1) % widget.promotions.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.size.height * 0.25,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.promotions.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final freelancer = widget.promotions[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = ((_pageController.page ?? _currentIndex).toDouble() - index.toDouble());
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: GestureDetector(
                        onTap: () => widget.onTap(freelancer),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.secondaryBackgroundColor,
                            image: DecorationImage(
                              image: NetworkImage(freelancer.imageUrl),
                              fit: BoxFit.cover,
                            )
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.promotions.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? AppColors.primaryAccentColor
                    : AppColors.bodyTextColor.withAlpha(78),
              ),
            );
          }),
        ),
      ],
    );
  }
}

