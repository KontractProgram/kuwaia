import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuwaia/models/community/freelancer.dart';
import 'package:kuwaia/providers/ai_journal_provider.dart';
import 'package:kuwaia/widgets/custom.dart';
import 'package:kuwaia/widgets/loading.dart';
import 'package:kuwaia/widgets/texts.dart';
import 'package:kuwaia/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../system/constants.dart';

class FreelancersScreen extends StatefulWidget {
  const FreelancersScreen({super.key});

  @override
  State<FreelancersScreen> createState() => _FreelancersScreenState();
}


class _FreelancersScreenState extends State<FreelancersScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchFreelancers();
    });
  }

  void _showFreelancerGalleryModal({required BuildContext context, required Size size, required Freelancer freelancer}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return FreelancerGalleryModalContent(
          freelancer: freelancer,
          size: size,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Consumer<AiJournalProvider>(
            builder: (context, aiJournalProvider, _) {
              if (aiJournalProvider.isLoading) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return promotionCardLoadingWidget(size: size);
                    }

                    return freelancerCardLoading(size: size);
                  }
                );
              }

              if (aiJournalProvider.error != null) {
                return Center(
                  child: Text(aiJournalProvider.error!,
                      style: TextStyle(color: AppColors.warningColor)),
                );
              }

              List<Freelancer> freelancers = aiJournalProvider.freelancers ?? [];
              if(freelancers.isNotEmpty) {
                freelancers.sort((a, b) => b.rating.compareTo(a.rating));
              }

              final promotions = aiJournalProvider.promotions ?? [];

              int count = freelancers.length;
              if(promotions.isNotEmpty) {
                count += 1;
              }

              if(freelancers.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Image.asset('assets/kuwaia_icons/main/freelancericon.png', width: size.width*0.6,),
                      reusableText(text: 'No freelancers available yet', fontSize: 20, fontWeight: FontWeight.bold)
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: count,
                itemBuilder: (context, index) {
                  if(count > freelancers.length) {
                    if (index == 0) {
                      // First item: promotion carousel
                      return PromotionCarousel(
                        promotions: promotions,
                        size: size,
                        onTap: (promotion) {
                          // find the freelancer that matches this promotion’s freelancer_id
                          final freelancer = freelancers.firstWhere(
                                (f) => f.id == promotion.freelancerId,
                            orElse: () => Freelancer.empty(), // define a safe fallback if needed
                          );

                          // only show modal if a valid freelancer was found
                          if (freelancer.id != 0) {
                            _showFreelancerGalleryModal(
                              context: context,
                              size: size,
                              freelancer: freelancer,
                            );
                          }
                        },
                      );
                    }


                    final freelancer = freelancers[index - 1];

                    return freelancerCard(
                        context: context,
                        size: size,
                        freelancer: freelancer,
                        onPressed: () => _showFreelancerGalleryModal(context: context, size: size, freelancer: freelancer)
                    );
                  }
                  else {
                    return freelancerCard(
                        context: context,
                        size: size,
                        freelancer: freelancers[index],
                        onPressed: () => _showFreelancerGalleryModal(context: context, size: size, freelancer: freelancers[index])
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}


class FreelancerGalleryModalContent extends StatefulWidget {
  final Freelancer freelancer;
  final Size size;

  const FreelancerGalleryModalContent({
    super.key,
    required this.freelancer,
    required this.size,
  });

  @override
  State<FreelancerGalleryModalContent> createState() => _FreelancerGalleryModalContentState();
}

class _FreelancerGalleryModalContentState extends State<FreelancerGalleryModalContent> {
  late final PageController _pageController;
  static const double _viewportFraction = 0.85;
  static const double _scaleFactor = 0.9;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AiJournalProvider>(context, listen: false).fetchGalleryByFreelancerId(widget.freelancer.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchEmailApp() async {
    final email = widget.freelancer.email;
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeFull('subject=Hello ${widget.freelancer.name}&body=Hi ${widget.freelancer.name},'),
    );
    print(emailUri);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      showToast('Could not open email app');
    }
  }

  Future<void> _copyEmailToClipboard() async {
    final email = widget.freelancer.email;

    // Copy the email address to the clipboard
    await Clipboard.setData(ClipboardData(text: email));

    // Show a toast/snackbar to let the user know it succeeded
    showToast('Email copied to clipboard'); // Assuming you have a showToast utility
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.size.height * 0.9, // 90% of screen height
          decoration: BoxDecoration(
            color: AppColors.secondaryBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Consumer<AiJournalProvider>(
            builder: (context, aiJournalProvider, _) {
              if (aiJournalProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (aiJournalProvider.error != null) {
                return Center(
                  child: Text(
                    aiJournalProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final images = aiJournalProvider.freelancerUrls ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: reusableText(text: widget.freelancer.name, fontWeight: FontWeight.bold, fontSize: 20)),

                    const SizedBox(height: 20),

                    images.isEmpty ? SizedBox.shrink() : WeightedImageCarousel(images: images, height: 250,),

                    const SizedBox(height: 24,),

                    reusableText(text: 'About Me', fontSize: 20, fontWeight: FontWeight.bold),

                    SizedBox(height: 16,),

                    reusableText(text: widget.freelancer.aboutMe, fontSize: 14, maxLines: 30, textAlign: TextAlign.start),

                  ],
                ),
              );
            }
          ),
        ),

        // Floating email button
        Positioned(
          bottom: 24,
          right: 24,
          // Use a Column to stack the two buttons
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important: don't take up full screen height
            crossAxisAlignment: CrossAxisAlignment.end, // Align buttons to the right
            children: [
              // 1. The original Email button
              FloatingActionButton.extended(
                backgroundColor: AppColors.dashaSignatureColor,
                icon: Icon(Icons.email_rounded, color: AppColors.bodyTextColor),
                label: reusableText(text: 'Email'),
                onPressed: _launchEmailApp,
              ),

              const SizedBox(height: 8), // Add a small space between the buttons

              // 2. The new Copy Email button
              SizedBox(
                height: 36, // Make it a bit smaller than the FAB
                child: FloatingActionButton.extended(
                  // Use a different color or style for visual separation
                  backgroundColor: AppColors.dashaSignatureColor.withOpacity(0.8),
                  elevation: 0, // Less prominent
                  icon: Icon(Icons.copy_rounded, size: 18, color: AppColors.bodyTextColor),
                  label: reusableText(text: 'Copy Email', fontSize: 14),
                  onPressed: _copyEmailToClipboard, // The new function
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}